// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of resolution;

/// The state of constants in resolutions.
enum ConstantState {
  /// Expressions are not required to be constants.
  NON_CONSTANT,

  /// Expressions are required to be constants.
  ///
  /// For instance the values of a constant list literal.
  CONSTANT,

  /// Expressions are required to be constants and parameter references are
  /// also considered constant.
  ///
  /// This is used for resolving constructor initializers of constant
  /// constructors.
  CONSTANT_INITIALIZER,
}

/**
 * Core implementation of resolution.
 *
 * Do not subclass or instantiate this class outside this library
 * except for testing.
 */
class ResolverVisitor extends MappingVisitor<ResolutionResult> {
  /**
   * The current enclosing element for the visited AST nodes.
   *
   * This field is updated when nested closures are visited.
   */
  Element enclosingElement;

  /// Whether we are in a context where `this` is accessible (this will be false
  /// in static contexts, factory methods, and field initializers).
  bool inInstanceContext;
  bool inCheckContext;
  bool inCatchBlock;
  ConstantState constantState;

  Scope scope;
  ClassElement currentClass;
  ExpressionStatement currentExpressionStatement;

  /// `true` if a [Send] or [SendSet] is visited as the prefix of member access.
  /// For instance `Class` in `Class.staticField` or `prefix.Class` in
  /// `prefix.Class.staticMethod()`.
  bool sendIsMemberAccess = false;

  StatementScope statementScope;
  int allowedCategory = ElementCategory.VARIABLE | ElementCategory.FUNCTION
      | ElementCategory.IMPLIES_TYPE;

  /**
   * Record of argument nodes to JS_INTERCEPTOR_CONSTANT for deferred
   * processing.
   */
  Set<Node> argumentsToJsInterceptorConstant = null;

  /// When visiting the type declaration of the variable in a [ForIn] loop,
  /// the initializer of the variable is implicit and we should not emit an
  /// error when verifying that all final variables are initialized.
  bool allowFinalWithoutInitializer = false;

  /// The nodes for which variable access and mutation must be registered in
  /// order to determine when the static type of variables types is promoted.
  Link<Node> promotionScope = const Link<Node>();

  bool isPotentiallyMutableTarget(Element target) {
    if (target == null) return false;
    return (target.isVariable || target.isParameter) &&
      !(target.isFinal || target.isConst);
  }

  // TODO(ahe): Find a way to share this with runtime implementation.
  static final RegExp symbolValidationPattern =
      new RegExp(r'^(?:[a-zA-Z$][a-zA-Z$0-9_]*\.)*(?:[a-zA-Z$][a-zA-Z$0-9_]*=?|'
                 r'-|'
                 r'unary-|'
                 r'\[\]=|'
                 r'~|'
                 r'==|'
                 r'\[\]|'
                 r'\*|'
                 r'/|'
                 r'%|'
                 r'~/|'
                 r'\+|'
                 r'<<|'
                 r'>>|'
                 r'>=|'
                 r'>|'
                 r'<=|'
                 r'<|'
                 r'&|'
                 r'\^|'
                 r'\|'
                 r')$');

  ResolverVisitor(Compiler compiler,
                  Element element,
                  ResolutionRegistry registry,
                  {bool useEnclosingScope: false})
    : this.enclosingElement = element,
      // When the element is a field, we are actually resolving its
      // initial value, which should not have access to instance
      // fields.
      inInstanceContext = (element.isInstanceMember && !element.isField)
          || element.isGenerativeConstructor,
      this.currentClass = element.isClassMember ? element.enclosingClass
                                             : null,
      this.statementScope = new StatementScope(),
      scope = useEnclosingScope
          ? Scope.buildEnclosingScope(element) : element.buildScope(),
      // The type annotations on a typedef do not imply type checks.
      // TODO(karlklose): clean this up (dartbug.com/8870).
      inCheckContext = compiler.enableTypeAssertions &&
          !element.isLibrary &&
          !element.isTypedef &&
          !element.enclosingElement.isTypedef,
      inCatchBlock = false,
      constantState = element.isConst
          ? ConstantState.CONSTANT : ConstantState.NON_CONSTANT,
      super(compiler, registry);

  CoreTypes get coreTypes => compiler.coreTypes;

  AsyncMarker get currentAsyncMarker {
    if (enclosingElement is FunctionElement) {
      FunctionElement function = enclosingElement;
      return function.asyncMarker;
    }
    return AsyncMarker.SYNC;
  }

  Element reportLookupErrorIfAny(Element result, Node node, String name) {
    if (!Elements.isUnresolved(result)) {
      if (!inInstanceContext && result.isInstanceMember) {
        compiler.reportError(
            node, MessageKind.NO_INSTANCE_AVAILABLE, {'name': name});
        return new ErroneousElementX(MessageKind.NO_INSTANCE_AVAILABLE,
                                     {'name': name},
                                     name, enclosingElement);
      } else if (result.isAmbiguous) {
        AmbiguousElement ambiguous = result;
        compiler.reportError(
            node, ambiguous.messageKind, ambiguous.messageArguments);
        ambiguous.diagnose(enclosingElement, compiler);
        return new ErroneousElementX(ambiguous.messageKind,
                                     ambiguous.messageArguments,
                                     name, enclosingElement);
      }
    }
    return result;
  }

  // Create, or reuse an already created, target element for a statement.
  JumpTarget getOrDefineTarget(Node statement) {
    JumpTarget element = registry.getTargetDefinition(statement);
    if (element == null) {
      element = new JumpTargetX(statement,
                                   statementScope.nestingLevel,
                                   enclosingElement);
      registry.defineTarget(statement, element);
    }
    return element;
  }

  doInCheckContext(action()) {
    bool wasInCheckContext = inCheckContext;
    inCheckContext = true;
    var result = action();
    inCheckContext = wasInCheckContext;
    return result;
  }

  doInPromotionScope(Node node, action()) {
    promotionScope = promotionScope.prepend(node);
    var result = action();
    promotionScope = promotionScope.tail;
    return result;
  }

  inStaticContext(action(),
                  {bool inConstantInitializer: false}) {
    bool wasInstanceContext = inInstanceContext;
    ConstantState oldConstantState = constantState;
    constantState = inConstantInitializer
        ? ConstantState.CONSTANT_INITIALIZER
        : constantState;
    inInstanceContext = false;
    var result = action();
    inInstanceContext = wasInstanceContext;
    constantState = oldConstantState;
    return result;
  }

  ResolutionResult visitInStaticContext(Node node,
                                        {bool inConstantInitializer: false}) {
    return inStaticContext(
        () => visit(node),
        inConstantInitializer: inConstantInitializer);
  }

  /// Execute [action] where the constant state is `ConstantState.CONSTANT` if
  /// not already `ConstantState.CONSTANT_INITIALIZER`.
  inConstantContext(action()) {
    ConstantState oldConstantState = constantState;
    if (constantState != ConstantState.CONSTANT_INITIALIZER) {
      constantState = ConstantState.CONSTANT;
    }
    var result = action();
    constantState = oldConstantState;
    return result;
  }

  /// Visit [node] where the constant state is `ConstantState.CONSTANT` if
  /// not already `ConstantState.CONSTANT_INITIALIZER`.
  ResolutionResult visitInConstantContext(Node node) {
    ResolutionResult result = inConstantContext(() => visit(node));
    assert(invariant(node, result != null,
        message: "No resolution result for $node."));

    return result;
  }

  ErroneousElement reportAndCreateErroneousElement(
      Node node,
      String name,
      MessageKind kind,
      Map arguments,
      {bool isError: false}) {
    if (isError) {
      compiler.reportError(node, kind, arguments);
    } else {
      compiler.reportWarning(node, kind, arguments);
    }
    // TODO(ahe): Use [allowedCategory] to synthesize a more precise subclass
    // of [ErroneousElementX]. For example, [ErroneousFieldElementX],
    // [ErroneousConstructorElementX], etc.
    return new ErroneousElementX(kind, arguments, name, enclosingElement);
  }

  /// Report a warning or error on an unresolved access in non-instance context.
  ///
  /// The [ErroneousElement] corresponding to the message is returned.
  ErroneousElement reportCannotResolve(Node node, String name) {
    assert(invariant(node, !inInstanceContext,
        message: "ResolverVisitor.reportCannotResolve must not be called in "
                 "instance context."));

    // We report an error within initializers because `this` is implicitly
    // accessed when unqualified identifiers are not resolved.  For
    // details, see section 16.14.3 of the spec (2nd edition):
    //   An unqualified invocation `i` of the form `id(a1, ...)`
    //   ...
    //   If `i` does not occur inside a top level or static function, `i`
    //   is equivalent to `this.id(a1 , ...)`.
    bool inInitializer =
        enclosingElement.isGenerativeConstructor ||
        (enclosingElement.isInstanceMember && enclosingElement.isField);
    MessageKind kind;
    Map arguments = {'name': name};
    if (inInitializer) {
      kind = MessageKind.CANNOT_RESOLVE_IN_INITIALIZER;
    } else if (name == 'await') {
      var functionName = enclosingElement.name;
      if (functionName == '') {
        kind = MessageKind.CANNOT_RESOLVE_AWAIT_IN_CLOSURE;
      } else {
        kind = MessageKind.CANNOT_RESOLVE_AWAIT;
        arguments['functionName'] = functionName;
      }
    } else {
      kind = MessageKind.CANNOT_RESOLVE;
    }
    registry.registerThrowNoSuchMethod();
    return reportAndCreateErroneousElement(
        node, name, kind, arguments, isError: inInitializer);
  }

  ResolutionResult visitIdentifier(Identifier node) {
    if (node.isThis()) {
      if (!inInstanceContext) {
        error(node, MessageKind.NO_INSTANCE_AVAILABLE, {'name': node});
      }
      return const NoneResult();
    } else if (node.isSuper()) {
      if (!inInstanceContext) {
        error(node, MessageKind.NO_SUPER_IN_STATIC);
      }
      if ((ElementCategory.SUPER & allowedCategory) == 0) {
        error(node, MessageKind.INVALID_USE_OF_SUPER);
      }
      return const NoneResult();
    } else {
      String name = node.source;
      Element element = lookupInScope(compiler, node, scope, name);
      if (Elements.isUnresolved(element) && name == 'dynamic') {
        // TODO(johnniwinther): Remove this hack when we can return more complex
        // objects than [Element] from this method.
        element = compiler.typeClass;
        // Set the type to be `dynamic` to mark that this is a type literal.
        registry.setType(node, const DynamicType());
      }
      element = reportLookupErrorIfAny(element, node, name);
      if (element == null) {
        if (!inInstanceContext) {
          element = reportCannotResolve(node, name);
        }
      } else if (element.isErroneous) {
        // Use the erroneous element.
      } else {
        if ((element.kind.category & allowedCategory) == 0) {
          element = reportAndCreateErroneousElement(
              node, name, MessageKind.GENERIC,
              // TODO(ahe): Improve error message. Need UX input.
              {'text': "is not an expression $element"});
        }
      }
      if (!Elements.isUnresolved(element) && element.isClass) {
        ClassElement classElement = element;
        classElement.ensureResolved(compiler);
      }
      if (element != null) {
        registry.useElement(node, element);
        if (element.isPrefix) {
          return new PrefixResult(element, null);
        } else if (element.isClass && sendIsMemberAccess) {
          return new PrefixResult(null, element);
        }
        return new ElementResult(element);
      }
      return const NoneResult();
    }
  }

  TypeResult visitTypeAnnotation(TypeAnnotation node) {
    DartType type = resolveTypeAnnotation(node);
    if (inCheckContext) {
      registry.registerIsCheck(type);
    }
    return new TypeResult(type);
  }

  bool isNamedConstructor(Send node) => node.receiver != null;

  Selector getRedirectingThisOrSuperConstructorSelector(Send node) {
    if (isNamedConstructor(node)) {
      String constructorName = node.selector.asIdentifier().source;
      return new Selector.callConstructor(
          constructorName,
          enclosingElement.library);
    } else {
      return new Selector.callDefaultConstructor();
    }
  }

  FunctionElement resolveConstructorRedirection(FunctionElementX constructor) {
    FunctionExpression node = constructor.parseNode(compiler);

    // A synthetic constructor does not have a node.
    if (node == null) return null;
    if (node.initializers == null) return null;
    Link<Node> initializers = node.initializers.nodes;
    if (!initializers.isEmpty &&
        Initializers.isConstructorRedirect(initializers.head)) {
      Selector selector =
          getRedirectingThisOrSuperConstructorSelector(initializers.head);
      final ClassElement classElement = constructor.enclosingClass;
      return classElement.lookupConstructor(selector.name);
    }
    return null;
  }

  void setupFunction(FunctionExpression node, FunctionElement function) {
    Element enclosingElement = function.enclosingElement;
    if (node.modifiers.isStatic &&
        enclosingElement.kind != ElementKind.CLASS) {
      compiler.reportError(node, MessageKind.ILLEGAL_STATIC);
    }

    scope = new MethodScope(scope, function);
    // Put the parameters in scope.
    FunctionSignature functionParameters = function.functionSignature;
    Link<Node> parameterNodes = (node.parameters == null)
        ? const Link<Node>() : node.parameters.nodes;
    functionParameters.forEachParameter((ParameterElementX element) {
      // TODO(karlklose): should be a list of [FormalElement]s, but the actual
      // implementation uses [Element].
      List<Element> optionals = functionParameters.optionalParameters;
      if (!optionals.isEmpty && element == optionals.first) {
        NodeList nodes = parameterNodes.head;
        parameterNodes = nodes.nodes;
      }
      if (element.isOptional) {
        if (element.initializer != null) {
          ResolutionResult result = visitInConstantContext(element.initializer);
          if (result.isConstant) {
            element.constant = result.constant;
          }
        } else {
          element.constant = new NullConstantExpression();
        }
      }
      VariableDefinitions variableDefinitions = parameterNodes.head;
      Node parameterNode = variableDefinitions.definitions.nodes.head;
      // Field parameters (this.x) are not visible inside the constructor. The
      // fields they reference are visible, but must be resolved independently.
      if (element.isInitializingFormal) {
        registry.useElement(parameterNode, element);
      } else {
        LocalParameterElementX parameterElement = element;
        defineLocalVariable(parameterNode, parameterElement);
        addToScope(parameterElement);
      }
      parameterNodes = parameterNodes.tail;
    });
    addDeferredAction(enclosingElement, () {
      functionParameters.forEachOptionalParameter(
          (ParameterElementX parameter) {
        parameter.constant =
            compiler.resolver.constantCompiler.compileConstant(parameter);
      });
    });
    if (inCheckContext) {
      functionParameters.forEachParameter((ParameterElement element) {
        registry.registerIsCheck(element.type);
      });
    }
  }

  ResolutionResult visitCascade(Cascade node) {
    visit(node.expression);
    return const NoneResult();
  }

  ResolutionResult visitCascadeReceiver(CascadeReceiver node) {
    visit(node.expression);
    return const NoneResult();
  }

  ResolutionResult visitIn(Node node, Scope nestedScope) {
    Scope oldScope = scope;
    scope = nestedScope;
    ResolutionResult result = visit(node);
    scope = oldScope;
    return result;
  }

  /**
   * Introduces new default targets for break and continue
   * before visiting the body of the loop
   */
  void visitLoopBodyIn(Loop loop, Node body, Scope bodyScope) {
    JumpTarget element = getOrDefineTarget(loop);
    statementScope.enterLoop(element);
    visitIn(body, bodyScope);
    statementScope.exitLoop();
    if (!element.isTarget) {
      registry.undefineTarget(loop);
    }
  }

  ResolutionResult visitBlock(Block node) {
    visitIn(node.statements, new BlockScope(scope));
    return const NoneResult();
  }

  ResolutionResult visitDoWhile(DoWhile node) {
    visitLoopBodyIn(node, node.body, new BlockScope(scope));
    visit(node.condition);
    return const NoneResult();
  }

  ResolutionResult visitEmptyStatement(EmptyStatement node) {
    return const NoneResult();
  }

  ResolutionResult visitExpressionStatement(ExpressionStatement node) {
    ExpressionStatement oldExpressionStatement = currentExpressionStatement;
    currentExpressionStatement = node;
    visit(node.expression);
    currentExpressionStatement = oldExpressionStatement;
    return const NoneResult();
  }

  ResolutionResult visitFor(For node) {
    Scope blockScope = new BlockScope(scope);
    visitIn(node.initializer, blockScope);
    visitIn(node.condition, blockScope);
    visitIn(node.update, blockScope);
    visitLoopBodyIn(node, node.body, blockScope);
    return const NoneResult();
  }

  ResolutionResult visitFunctionDeclaration(FunctionDeclaration node) {
    assert(node.function.name != null);
    visitFunctionExpression(node.function, inFunctionDeclaration: true);
    return const NoneResult();
  }


  /// Process a local function declaration or an anonymous function expression.
  ///
  /// [inFunctionDeclaration] is `true` when the current node is the immediate
  /// child of a function declaration.
  ///
  /// This is used to distinguish local function declarations from anonymous
  /// function expressions.
  ResolutionResult visitFunctionExpression(
      FunctionExpression node,
      {bool inFunctionDeclaration: false}) {
    bool doAddToScope = inFunctionDeclaration;
    if (!inFunctionDeclaration && node.name != null) {
      compiler.reportError(
          node.name,
          MessageKind.NAMED_FUNCTION_EXPRESSION,
          {'name': node.name});
    }
    visit(node.returnType);
    String name;
    if (node.name == null) {
      name = "";
    } else {
      name = node.name.asIdentifier().source;
    }
    LocalFunctionElementX function = new LocalFunctionElementX(
        name, node, ElementKind.FUNCTION, Modifiers.EMPTY,
        enclosingElement);
    ResolverTask.processAsyncMarker(compiler, function, registry);
    function.functionSignatureCache = SignatureResolver.analyze(
        compiler,
        node.parameters,
        node.returnType,
        function,
        registry,
        createRealParameters: true,
        isFunctionExpression: !inFunctionDeclaration);
    checkLocalDefinitionName(node, function);
    registry.defineFunction(node, function);
    if (doAddToScope) {
      addToScope(function);
    }
    Scope oldScope = scope; // The scope is modified by [setupFunction].
    setupFunction(node, function);

    Element previousEnclosingElement = enclosingElement;
    enclosingElement = function;
    // Run the body in a fresh statement scope.
    StatementScope oldStatementScope = statementScope;
    statementScope = new StatementScope();
    visit(node.body);
    statementScope = oldStatementScope;

    scope = oldScope;
    enclosingElement = previousEnclosingElement;

    registry.registerClosure(function);
    registry.registerInstantiatedClass(compiler.functionClass);
    return const NoneResult();
  }

  ResolutionResult visitIf(If node) {
    doInPromotionScope(node.condition.expression, () => visit(node.condition));
    doInPromotionScope(node.thenPart,
        () => visitIn(node.thenPart, new BlockScope(scope)));
    visitIn(node.elsePart, new BlockScope(scope));
    return const NoneResult();
  }

  ResolutionResult resolveSend(Send node) {
    Selector selector = resolveSelector(node, null);
    if (node.isSuperCall) registry.registerSuperUse(node);

    if (node.receiver == null) {
      // If this send is of the form "assert(expr);", then
      // this is an assertion.
      if (selector.isAssert) {
        internalError(node, "Unexpected assert: $node");
      }

      return node.selector.accept(this);
    }

    var oldCategory = allowedCategory;
    allowedCategory |= ElementCategory.PREFIX | ElementCategory.SUPER;

    bool oldSendIsMemberAccess = sendIsMemberAccess;
    int oldAllowedCategory = allowedCategory;

    // Conditional sends like `e?.foo` treat the receiver as an expression.  So
    // `C?.foo` needs to be treated like `(C).foo`, not like C.foo. Prefixes and
    // super are not allowed on their own in that context.
    if (node.isConditional) {
      sendIsMemberAccess = false;
      allowedCategory =
          ElementCategory.VARIABLE |
          ElementCategory.FUNCTION |
          ElementCategory.IMPLIES_TYPE;
    }
    ResolutionResult resolvedReceiver = visit(node.receiver);
    if (node.isConditional) {
      sendIsMemberAccess = oldSendIsMemberAccess;
      allowedCategory = oldAllowedCategory;
    }

    allowedCategory = oldCategory;

    Element target;
    String name = node.selector.asIdentifier().source;
    if (identical(name, 'this')) {
      error(node.selector, MessageKind.THIS_PROPERTY);
      return const NoneResult();
    } else if (node.isSuperCall) {
      if (node.isOperator) {
        if (isUserDefinableOperator(name)) {
          name = selector.name;
        } else {
          error(node.selector, MessageKind.ILLEGAL_SUPER_SEND, {'name': name});
          return const NoneResult();
        }
      }
      if (!inInstanceContext) {
        error(node.receiver, MessageKind.NO_INSTANCE_AVAILABLE, {'name': name});
        return const NoneResult();
      }
      if (currentClass.supertype == null) {
        // This is just to guard against internal errors, so no need
        // for a real error message.
        error(node.receiver, MessageKind.GENERIC,
              {'text': "Object has no superclass"});
        return const NoneResult();
      }
      // TODO(johnniwinther): Ensure correct behavior if currentClass is a
      // patch.
      target = currentClass.lookupSuperByName(selector.memberName);
      // [target] may be null which means invoking noSuchMethod on
      // super.
      if (target == null) {
        target = reportAndCreateErroneousElement(
            node, name, MessageKind.NO_SUCH_SUPER_MEMBER,
            {'className': currentClass.name, 'memberName': name});
        // We still need to register the invocation, because we might
        // call [:super.noSuchMethod:] which calls
        // [JSInvocationMirror._invokeOn].
        registry.registerDynamicInvocation(
            new UniverseSelector(selector, null));
        registry.registerSuperNoSuchMethod();
      }
    } else if (Elements.isUnresolved(resolvedReceiver.element)) {
      return const NoneResult();
    } else if (resolvedReceiver.element.isClass) {
      ClassElement receiverClass = resolvedReceiver.element;
      receiverClass.ensureResolved(compiler);
      if (node.isOperator) {
        // When the resolved receiver is a class, we can have two cases:
        //  1) a static send: C.foo, or
        //  2) an operator send, where the receiver is a class literal: 'C + 1'.
        // The following code that looks up the selector on the resolved
        // receiver will treat the second as the invocation of a static operator
        // if the resolved receiver is not null.
        return const NoneResult();
      }
      MembersCreator.computeClassMembersByName(
          compiler, receiverClass.declaration, name);
      target = receiverClass.lookupLocalMember(name);
      if (target == null || target.isInstanceMember) {
        registry.registerThrowNoSuchMethod();
        // TODO(johnniwinther): With the simplified [TreeElements] invariant,
        // try to resolve injected elements if [currentClass] is in the patch
        // library of [receiverClass].

        // TODO(karlklose): this should be reported by the caller of
        // [resolveSend] to select better warning messages for getters and
        // setters.
        MessageKind kind = (target == null)
            ? MessageKind.MEMBER_NOT_FOUND
            : MessageKind.MEMBER_NOT_STATIC;
        return new ElementResult(reportAndCreateErroneousElement(
            node, name, kind,
            {'className': receiverClass.name, 'memberName': name}));
      } else if (isPrivateName(name) &&
                 target.library != enclosingElement.library) {
        registry.registerThrowNoSuchMethod();
        return new ElementResult(reportAndCreateErroneousElement(
            node, name, MessageKind.PRIVATE_ACCESS,
            {'libraryName': target.library.getLibraryOrScriptName(),
             'name': name}));
      }
    } else if (resolvedReceiver.element.isPrefix) {
      PrefixElement prefix = resolvedReceiver.element;
      target = prefix.lookupLocalMember(name);
      if (Elements.isUnresolved(target)) {
        registry.registerThrowNoSuchMethod();
        return new ElementResult(reportAndCreateErroneousElement(
            node, name, MessageKind.NO_SUCH_LIBRARY_MEMBER,
            {'libraryName': prefix.name, 'memberName': name}));
      } else if (target.isAmbiguous) {
        registry.registerThrowNoSuchMethod();
        AmbiguousElement ambiguous = target;
        target = reportAndCreateErroneousElement(
            node, name, ambiguous.messageKind, ambiguous.messageArguments);
        ambiguous.diagnose(enclosingElement, compiler);
        return new ElementResult(target);
      } else if (target.kind == ElementKind.CLASS) {
        ClassElement classElement = target;
        classElement.ensureResolved(compiler);
      }
    }
    return new ResolutionResult.forElement(target);
  }

  static Selector computeSendSelector(Send node,
                                      LibraryElement library,
                                      Element element) {
    // First determine if this is part of an assignment.
    bool isSet = node.asSendSet() != null;

    if (node.isIndex) {
      return isSet ? new Selector.indexSet() : new Selector.index();
    }

    if (node.isOperator) {
      String source = node.selector.asOperator().source;
      String string = source;
      if (identical(string, '!') ||
          identical(string, '&&') || identical(string, '||') ||
          identical(string, 'is') || identical(string, 'as') ||
          identical(string, '?') || identical(string, '??') ||
          identical(string, '>>>')) {
        return null;
      }
      String op = source;
      if (!isUserDefinableOperator(source)) {
        op = Elements.mapToUserOperatorOrNull(source);
      }
      if (op == null) {
        // Unsupported operator. An error has been reported during parsing.
        return new Selector.call(
            source, library, node.argumentsNode.slowLength(), []);
      }
      return node.arguments.isEmpty
          ? new Selector.unaryOperator(op)
          : new Selector.binaryOperator(op);
    }

    Identifier identifier = node.selector.asIdentifier();
    if (node.isPropertyAccess) {
      assert(!isSet);
      return new Selector.getter(identifier.source, library);
    } else if (isSet) {
      return new Selector.setter(identifier.source, library);
    }

    // Compute the arity and the list of named arguments.
    int arity = 0;
    List<String> named = <String>[];
    for (Link<Node> link = node.argumentsNode.nodes;
        !link.isEmpty;
        link = link.tail) {
      Expression argument = link.head;
      NamedArgument namedArgument = argument.asNamedArgument();
      if (namedArgument != null) {
        named.add(namedArgument.name.source);
      }
      arity++;
    }

    if (element != null && element.isConstructor) {
      return new Selector.callConstructor(
          element.name, library, arity, named);
    }

    // If we're invoking a closure, we do not have an identifier.
    return (identifier == null)
        ? new Selector.callClosure(arity, named)
        : new Selector.call(identifier.source, library, arity, named);
  }

  Selector resolveSelector(Send node, Element element) {
    LibraryElement library = enclosingElement.library;
    Selector selector = computeSendSelector(node, library, element);
    if (selector != null) registry.setSelector(node, selector);
    return selector;
  }

  ArgumentsResult resolveArguments(NodeList list) {
    if (list == null) return null;
    bool isValidAsConstant = true;
    List<ResolutionResult> argumentResults = <ResolutionResult>[];
    bool oldSendIsMemberAccess = sendIsMemberAccess;
    sendIsMemberAccess = false;
    Map<String, Node> seenNamedArguments = new Map<String, Node>();
    int argumentCount = 0;
    List<String> namedArguments = <String>[];
    for (Link<Node> link = list.nodes; !link.isEmpty; link = link.tail) {
      Expression argument = link.head;
      ResolutionResult result = visit(argument);
      if (!result.isConstant) {
        isValidAsConstant = false;
      }
      argumentResults.add(result);

      NamedArgument namedArgument = argument.asNamedArgument();
      if (namedArgument != null) {
        String source = namedArgument.name.source;
        namedArguments.add(source);
        if (seenNamedArguments.containsKey(source)) {
          reportDuplicateDefinition(
              source,
              argument,
              seenNamedArguments[source]);
          isValidAsConstant = false;
        } else {
          seenNamedArguments[source] = namedArgument;
        }
      } else if (!seenNamedArguments.isEmpty) {
        error(argument, MessageKind.INVALID_ARGUMENT_AFTER_NAMED);
        isValidAsConstant = false;
      }
      argumentCount++;
    }
    sendIsMemberAccess = oldSendIsMemberAccess;
    return new ArgumentsResult(
        new CallStructure(argumentCount, namedArguments),
        argumentResults,
        isValidAsConstant: isValidAsConstant);
  }

  void registerTypeLiteralAccess(Send node, Element target) {
    // Set the type of the node to [Type] to mark this send as a
    // type literal.
    DartType type;

    // TODO(johnniwinther): Remove this hack when we can pass more complex
    // information between methods than resolved elements.
    if (target == compiler.typeClass && node.receiver == null) {
      // Potentially a 'dynamic' type literal.
      type = registry.getType(node.selector);
    }
    if (type == null) {
      if (target.isTypedef || target.isClass) {
        TypeDeclarationElement typeDeclaration = target;
        typeDeclaration.computeType(compiler);
        type = typeDeclaration.rawType;
      } else {
        TypeVariableElement typeVariable = target;
        type = typeVariable.type;
      }
    }
    registry.registerTypeLiteral(node, type);

    if (!target.isTypeVariable) {
      // Don't try to make constants of calls and assignments to type literals.
      if (!node.isCall && node.asSendSet() == null) {
        analyzeConstantDeferred(node, enforceConst: false);
      } else {
        // The node itself is not a constant but we register the selector (the
        // identifier that refers to the class/typedef) as a constant.
        if (node.receiver != null) {
          // This is a hack for the case of prefix.Type, we need to store
          // the element on the selector, so [analyzeConstant] can build
          // the type literal from the selector.
          registry.useElement(node.selector, target);
        }
        analyzeConstantDeferred(node.selector, enforceConst: false);
      }
    }
  }

  /// Check that access to `super` is currently allowed.
  bool checkSuperAccess(Send node) {
    if (!inInstanceContext) {
      compiler.reportError(node, MessageKind.NO_SUPER_IN_STATIC);
      return false;
    }
    if (node.isConditional) {
      // `super?.foo` is not allowed.
      compiler.reportError(node, MessageKind.INVALID_USE_OF_SUPER);
      return false;
    }
    if (currentClass.supertype == null) {
      // This is just to guard against internal errors, so no need
      // for a real error message.
      compiler.reportError(node, MessageKind.GENERIC,
            {'text': "Object has no superclass"});
      return false;
    }
    registry.registerSuperUse(node);
    return true;
  }

  /// Check that access to `this` is currently allowed.
  bool checkThisAccess(Send node) {
    if (!inInstanceContext) {
      compiler.reportError(node, MessageKind.NO_THIS_AVAILABLE);
      return false;
    }
    return true;
  }

  /// Compute the [AccessSemantics] corresponding to a super access of [target].
  AccessSemantics computeSuperAccessSemantics(Spannable node, Element target) {
    if (target.isErroneous) {
      return new StaticAccess.unresolvedSuper(target);
    } else if (target.isGetter) {
      return new StaticAccess.superGetter(target);
    } else if (target.isSetter) {
      return new StaticAccess.superSetter(target);
    } else if (target.isField) {
      if (target.isFinal) {
        return new StaticAccess.superFinalField(target);
      } else {
        return new StaticAccess.superField(target);
      }
    } else {
      assert(invariant(node, target.isFunction,
          message: "Unexpected super target '$target'."));
      return new StaticAccess.superMethod(target);
    }
  }

  /// Compute the [AccessSemantics] corresponding to a local access of [target].
  AccessSemantics computeLocalAccessSemantics(Spannable node,
                                              LocalElement target) {
    if (target.isParameter) {
      if (target.isFinal || target.isConst) {
        return new StaticAccess.finalParameter(target);
      } else {
        return new StaticAccess.parameter(target);
      }
    } else if (target.isVariable) {
      if (target.isFinal || target.isConst) {
        return new StaticAccess.finalLocalVariable(target);
      } else {
        return new StaticAccess.localVariable(target);
      }
    } else {
      assert(invariant(node, target.isFunction,
          message: "Unexpected local target '$target'."));
      return new StaticAccess.localFunction(target);
    }
  }

  /// Compute the [AccessSemantics] corresponding to a static or toplevel access
  /// of [target].
  AccessSemantics computeStaticOrTopLevelAccessSemantics(
      Spannable node,
      Element target) {

    target = target.declaration;
    if (target.isErroneous) {
      // This handles elements with parser errors.
      // TODO(johnniwinther): Elements with parse error should not set
      // [isErroneous] to `true`.
      return new StaticAccess.unresolved(target);
    }
    if (target.isStatic) {
      if (target.isGetter) {
        return new StaticAccess.staticGetter(target);
      } else if (target.isSetter) {
        return new StaticAccess.staticSetter(target);
      } else if (target.isField) {
        if (target.isFinal || target.isConst) {
          return new StaticAccess.finalStaticField(target);
        } else {
          return new StaticAccess.staticField(target);
        }
      } else {
        assert(invariant(node, target.isFunction,
            message: "Unexpected static target '$target'."));
        return new StaticAccess.staticMethod(target);
      }
     } else {
       assert(invariant(node, target.isTopLevel,
           message: "Unexpected statically resolved target '$target'."));
       if (target.isGetter) {
         return new StaticAccess.topLevelGetter(target);
       } else if (target.isSetter) {
         return new StaticAccess.topLevelSetter(target);
       } else if (target.isField) {
         if (target.isFinal) {
           return new StaticAccess.finalTopLevelField(target);
         } else {
           return new StaticAccess.topLevelField(target);
         }
       } else {
         assert(invariant(node, target.isFunction,
             message: "Unexpected top level target '$target'."));
         return new StaticAccess.topLevelMethod(target);
       }
     }
  }

  /// Compute the [AccessSemantics] for accessing the name of [selector] on the
  /// super class.
  ///
  /// If no matching super member is found and error is reported and
  /// `noSuchMethod` on `super` is registered. Furthermore, if [alternateName]
  /// is provided, the [AccessSemantics] corresponding to the alternate name is
  /// returned. For instance, the access of a super setter for an unresolved
  /// getter:
  ///
  ///     class Super {
  ///       set name(_) {}
  ///     }
  ///     class Sub extends Super {
  ///       foo => super.name; // Access to the setter.
  ///     }
  ///
  AccessSemantics computeSuperAccessSemanticsForSelector(
      Spannable node,
      Selector selector,
      {Name alternateName}) {

    Name name = selector.memberName;
    // TODO(johnniwinther): Ensure correct behavior if currentClass is a
    // patch.
    Element target = currentClass.lookupSuperByName(name);
    // [target] may be null which means invoking noSuchMethod on super.
    if (target == null) {
      Element error = reportAndCreateErroneousElement(
          node, name.text, MessageKind.NO_SUCH_SUPER_MEMBER,
          {'className': currentClass.name, 'memberName': name});
      if (alternateName != null) {
        target = currentClass.lookupSuperByName(alternateName);
      }
      if (target == null) {
        // If a setter wasn't resolved, use the [ErroneousElement].
        target = error;
      }
      // We still need to register the invocation, because we might
      // call [:super.noSuchMethod:] which calls [JSInvocationMirror._invokeOn].
      registry.registerDynamicInvocation(new UniverseSelector(selector, null));
      registry.registerSuperNoSuchMethod();
    }
    return computeSuperAccessSemantics(node, target);
  }

  /// Resolve [node] as a subexpression that is _not_ the prefix of a member
  /// access. For instance `a` in `a + b`, as opposed to `a` in `a.b`.
  ResolutionResult visitExpression(Node node) {
    bool oldSendIsMemberAccess = sendIsMemberAccess;
    sendIsMemberAccess = false;
    ResolutionResult result = visit(node);
    sendIsMemberAccess = oldSendIsMemberAccess;
    return result;
  }

  /// Resolve [node] as a subexpression that _is_ the prefix of a member access.
  /// For instance `a` in `a.b`, as opposed to `a` in `a + b`.
  ResolutionResult visitExpressionPrefix(Node node) {
    int oldAllowedCategory = allowedCategory;
    bool oldSendIsMemberAccess = sendIsMemberAccess;
    allowedCategory |= ElementCategory.PREFIX | ElementCategory.SUPER;
    sendIsMemberAccess = true;
    ResolutionResult result = visit(node);
    sendIsMemberAccess = oldSendIsMemberAccess;
    allowedCategory = oldAllowedCategory;
    return result;
  }

  /// Resolved [node] as a subexpression that is the prefix of a conditional
  /// access. For instance `a` in `a?.b`.
  // TODO(johnniwinther): Is this equivalent to [visitExpression]?
  ResolutionResult visitConditionalPrefix(Node node) {
    // Conditional sends like `e?.foo` treat the receiver as an expression.  So
    // `C?.foo` needs to be treated like `(C).foo`, not like C.foo. Prefixes and
    // super are not allowed on their own in that context.
    int oldAllowedCategory = allowedCategory;
    bool oldSendIsMemberAccess = sendIsMemberAccess;
    sendIsMemberAccess = false;
    allowedCategory =
        ElementCategory.VARIABLE |
        ElementCategory.FUNCTION |
        ElementCategory.IMPLIES_TYPE;
    ResolutionResult result = visit(node);
    sendIsMemberAccess = oldSendIsMemberAccess;
    allowedCategory = oldAllowedCategory;
    return result;
  }

  /// Handle a type test expression, like `a is T` and `a is! T`.
  ResolutionResult handleIs(Send node) {
    Node expression = node.receiver;
    visitExpression(expression);

    // TODO(johnniwinther): Use seen type tests to avoid registration of
    // mutation/access to unpromoted variables.

    Send notTypeNode = node.arguments.head.asSend();
    DartType type;
    SendStructure sendStructure;
    if (notTypeNode != null) {
      // `e is! T`.
      Node typeNode = notTypeNode.receiver;
      type = resolveTypeAnnotation(typeNode);
      sendStructure = new IsNotStructure(type);
    } else {
      // `e is T`.
      Node typeNode = node.arguments.head;
      type = resolveTypeAnnotation(typeNode);
      sendStructure = new IsStructure(type);
    }
    registry.registerIsCheck(type);
    registry.registerSendStructure(node, sendStructure);
    return const NoneResult();
  }

  /// Handle a type cast expression, like `a as T`.
  ResolutionResult handleAs(Send node) {
    Node expression = node.receiver;
    visitExpression(expression);

    Node typeNode = node.arguments.head;
    DartType type = resolveTypeAnnotation(typeNode);
    registry.registerAsCheck(type);
    registry.registerSendStructure(node, new AsStructure(type));
    return const NoneResult();
  }

  /// Handle the unary expression of an unresolved unary operator [text], like
  /// the no longer supported `+a`.
  ResolutionResult handleUnresolvedUnary(Send node, String text) {
    Node expression = node.receiver;
    if (node.isSuperCall) {
      checkSuperAccess(node);
    } else {
      visitExpression(expression);
    }

    registry.registerSendStructure(node, const InvalidUnaryStructure());
    return const NoneResult();
  }

  /// Handle the unary expression of a user definable unary [operator], like
  /// `-a`, and `-super`.
  ResolutionResult handleUserDefinableUnary(Send node, UnaryOperator operator) {
    ResolutionResult result = const NoneResult();
    Node expression = node.receiver;
    Selector selector = operator.selector;
    // TODO(johnniwinther): Remove this when all information goes through the
    // [SendStructure].
    registry.setSelector(node, selector);

    AccessSemantics semantics;
    if (node.isSuperCall) {
      if (checkSuperAccess(node)) {
        semantics = computeSuperAccessSemanticsForSelector(node, selector);
        // TODO(johnniwinther): Add information to [AccessSemantics] about
        // whether it is erroneous.
        if (semantics.kind == AccessKind.SUPER_METHOD) {
          registry.registerStaticUse(semantics.element.declaration);
        }
        // TODO(johnniwinther): Remove this when all information goes through
        // the [SendStructure].
        registry.useElement(node, semantics.element);
      }
    } else {
      ResolutionResult expressionResult = visitExpression(expression);
      semantics = new DynamicAccess.dynamicProperty(expression);
      registry.registerDynamicInvocation(new UniverseSelector(selector, null));

      if (expressionResult.isConstant) {
        bool isValidConstant;
        ConstantExpression expressionConstant = expressionResult.constant;
        DartType knownExpressionType =
            expressionConstant.getKnownType(coreTypes);
        switch (operator.kind) {
          case UnaryOperatorKind.COMPLEMENT:
            isValidConstant =
                knownExpressionType == coreTypes.intType;
            break;
          case UnaryOperatorKind.NEGATE:
            isValidConstant =
                knownExpressionType == coreTypes.intType ||
                knownExpressionType == coreTypes.doubleType;
            break;
          case UnaryOperatorKind.NOT:
            internalError(node,
                "Unexpected user definable unary operator: $operator");
        }
        if (isValidConstant) {
          // TODO(johnniwinther): Handle potentially invalid constant
          // expressions.
          ConstantExpression constant =
              new UnaryConstantExpression(operator, expressionConstant);
          registry.setConstant(node, constant);
          result = new ConstantResult(node, constant);
        }
      }
    }
    if (semantics != null) {
      // TODO(johnniwinther): Support invalid super access as an
      // [AccessSemantics].
      registry.registerSendStructure(node,
          new UnaryStructure(semantics, operator));
    }
    return result;
  }

  /// Handle a not expression, like `!a`.
  ResolutionResult handleNot(Send node, UnaryOperator operator) {
    assert(invariant(node, operator.kind == UnaryOperatorKind.NOT));

    Node expression = node.receiver;
    ResolutionResult result = visitExpression(expression);
    registry.registerSendStructure(node,
        new NotStructure(new DynamicAccess.dynamicProperty(expression)));

    if (result.isConstant) {
      ConstantExpression expressionConstant = result.constant;
      if (expressionConstant.getKnownType(coreTypes) == coreTypes.boolType) {
        // TODO(johnniwinther): Handle potentially invalid constant expressions.
        ConstantExpression constant =
            new UnaryConstantExpression(operator, expressionConstant);
        registry.setConstant(node, constant);
        return new ConstantResult(node, constant);
      }
    }

    return const NoneResult();
  }

  /// Handle a logical and expression, like `a && b`.
  ResolutionResult handleLogicalAnd(Send node) {
    Node left = node.receiver;
    Node right = node.arguments.head;
    ResolutionResult leftResult =
        doInPromotionScope(left, () => visitExpression(left));
    ResolutionResult rightResult =
        doInPromotionScope(right, () => visitExpression(right));
    registry.registerSendStructure(node, const LogicalAndStructure());

    if (leftResult.isConstant && rightResult.isConstant) {
      ConstantExpression leftConstant = leftResult.constant;
      ConstantExpression rightConstant = rightResult.constant;
      if (leftConstant.getKnownType(coreTypes) == coreTypes.boolType &&
          rightConstant.getKnownType(coreTypes) == coreTypes.boolType) {
        // TODO(johnniwinther): Handle potentially invalid constant expressions.
        ConstantExpression constant = new BinaryConstantExpression(
            leftConstant,
            BinaryOperator.LOGICAL_AND,
            rightConstant);
        registry.setConstant(node, constant);
        return new ConstantResult(node, constant);
      }
    }

    return const NoneResult();
  }

  /// Handle a logical or expression, like `a || b`.
  ResolutionResult handleLogicalOr(Send node) {
    Node left = node.receiver;
    Node right = node.arguments.head;
    ResolutionResult leftResult = visitExpression(left);
    ResolutionResult rightResult = visitExpression(right);
    registry.registerSendStructure(node, const LogicalOrStructure());

    if (leftResult.isConstant && rightResult.isConstant) {
      ConstantExpression leftConstant = leftResult.constant;
      ConstantExpression rightConstant = rightResult.constant;
      if (leftConstant.getKnownType(coreTypes) == coreTypes.boolType &&
          rightConstant.getKnownType(coreTypes) == coreTypes.boolType) {
        // TODO(johnniwinther): Handle potentially invalid constant expressions.
        ConstantExpression constant = new BinaryConstantExpression(
            leftConstant,
            BinaryOperator.LOGICAL_OR,
            rightConstant);
        registry.setConstant(node, constant);
        return new ConstantResult(node, constant);
      }
    }
    return const NoneResult();
  }

  /// Handle an if-null expression, like `a ?? b`.
  ResolutionResult handleIfNull(Send node) {
    Node left = node.receiver;
    Node right = node.arguments.head;
    visitExpression(left);
    visitExpression(right);
    registry.registerSendStructure(node, const IfNullStructure());
    return const NoneResult();
  }

  /// Handle the binary expression of an unresolved binary operator [text], like
  /// the no longer supported `a === b`.
  ResolutionResult handleUnresolvedBinary(Send node, String text) {
    Node left = node.receiver;
    Node right = node.arguments.head;
    if (node.isSuperCall) {
      checkSuperAccess(node);
    } else {
      visitExpression(left);
    }
    visitExpression(right);
    registry.registerSendStructure(node, const InvalidBinaryStructure());
    return const NoneResult();
  }

  /// Handle the binary expression of a user definable binary [operator], like
  /// `a + b`, `super + b`, `a == b` and `a != b`.
  ResolutionResult handleUserDefinableBinary(Send node,
                                             BinaryOperator operator) {
    ResolutionResult result = const NoneResult();
    Node left = node.receiver;
    Node right = node.arguments.head;
    AccessSemantics semantics;
    Selector selector;
    if (operator.kind == BinaryOperatorKind.INDEX) {
      selector = new Selector.index();
    } else {
      selector = new Selector.binaryOperator(operator.selectorName);
    }
    // TODO(johnniwinther): Remove this when all information goes through the
    // [SendStructure].
    registry.setSelector(node, selector);

    if (node.isSuperCall) {
      if (checkSuperAccess(node)) {
        semantics = computeSuperAccessSemanticsForSelector(node, selector);
        // TODO(johnniwinther): Add information to [AccessSemantics] about
        // whether it is erroneous.
        if (semantics.kind == AccessKind.SUPER_METHOD) {
          registry.registerStaticUse(semantics.element.declaration);
        }
        // TODO(johnniwinther): Remove this when all information goes through
        // the [SendStructure].
        registry.useElement(node, semantics.element);
      }
      visitExpression(right);
    } else {
      ResolutionResult leftResult = visitExpression(left);
      ResolutionResult rightResult = visitExpression(right);
      registry.registerDynamicInvocation(new UniverseSelector(selector, null));
      semantics = new DynamicAccess.dynamicProperty(left);

      if (leftResult.isConstant && rightResult.isConstant) {
        bool isValidConstant;
        ConstantExpression leftConstant = leftResult.constant;
        ConstantExpression rightConstant = rightResult.constant;
        DartType knownLeftType = leftConstant.getKnownType(coreTypes);
        DartType knownRightType = rightConstant.getKnownType(coreTypes);
        switch (operator.kind) {
          case BinaryOperatorKind.EQ:
          case BinaryOperatorKind.NOT_EQ:
            isValidConstant =
                (knownLeftType == coreTypes.intType ||
                 knownLeftType == coreTypes.doubleType ||
                 knownLeftType == coreTypes.stringType ||
                 knownLeftType == coreTypes.boolType ||
                 knownLeftType == coreTypes.nullType) &&
                (knownRightType == coreTypes.intType ||
                 knownRightType == coreTypes.doubleType ||
                 knownRightType == coreTypes.stringType ||
                 knownRightType == coreTypes.boolType ||
                 knownRightType == coreTypes.nullType);
            break;
          case BinaryOperatorKind.ADD:
            isValidConstant =
                (knownLeftType == coreTypes.intType ||
                 knownLeftType == coreTypes.doubleType ||
                 knownLeftType == coreTypes.stringType) &&
                (knownRightType == coreTypes.intType ||
                 knownRightType == coreTypes.doubleType ||
                 knownRightType == coreTypes.stringType);
            break;
          case BinaryOperatorKind.SUB:
          case BinaryOperatorKind.MUL:
          case BinaryOperatorKind.DIV:
          case BinaryOperatorKind.IDIV:
          case BinaryOperatorKind.MOD:
          case BinaryOperatorKind.GTEQ:
          case BinaryOperatorKind.GT:
          case BinaryOperatorKind.LTEQ:
          case BinaryOperatorKind.LT:
            isValidConstant =
                (knownLeftType == coreTypes.intType ||
                 knownLeftType == coreTypes.doubleType) &&
                (knownRightType == coreTypes.intType ||
                 knownRightType == coreTypes.doubleType);
            break;
          case BinaryOperatorKind.SHL:
          case BinaryOperatorKind.SHR:
          case BinaryOperatorKind.AND:
          case BinaryOperatorKind.OR:
          case BinaryOperatorKind.XOR:
            isValidConstant =
                knownLeftType == coreTypes.intType &&
                knownRightType == coreTypes.intType;
            break;
          case BinaryOperatorKind.INDEX:
            isValidConstant = false;
            break;
          case BinaryOperatorKind.LOGICAL_AND:
          case BinaryOperatorKind.LOGICAL_OR:
          case BinaryOperatorKind.IF_NULL:
            internalError(node, "Unexpected binary operator '${operator}'.");
            break;
        }
        if (isValidConstant) {
          // TODO(johnniwinther): Handle potentially invalid constant
          // expressions.
          ConstantExpression constant = new BinaryConstantExpression(
              leftResult.constant,
              operator,
              rightResult.constant);
          registry.setConstant(node, constant);
          result = new ConstantResult(node, constant);
        }
      }
    }

    if (semantics != null) {
      // TODO(johnniwinther): Support invalid super access as an
      // [AccessSemantics].
      SendStructure sendStructure;
      switch (operator.kind) {
        case BinaryOperatorKind.EQ:
          sendStructure = new EqualsStructure(semantics);
          break;
        case BinaryOperatorKind.NOT_EQ:
          sendStructure = new NotEqualsStructure(semantics);
          break;
        case BinaryOperatorKind.INDEX:
          sendStructure = new IndexStructure(semantics);
          break;
        case BinaryOperatorKind.ADD:
        case BinaryOperatorKind.SUB:
        case BinaryOperatorKind.MUL:
        case BinaryOperatorKind.DIV:
        case BinaryOperatorKind.IDIV:
        case BinaryOperatorKind.MOD:
        case BinaryOperatorKind.SHL:
        case BinaryOperatorKind.SHR:
        case BinaryOperatorKind.GTEQ:
        case BinaryOperatorKind.GT:
        case BinaryOperatorKind.LTEQ:
        case BinaryOperatorKind.LT:
        case BinaryOperatorKind.AND:
        case BinaryOperatorKind.OR:
        case BinaryOperatorKind.XOR:
          sendStructure = new BinaryStructure(semantics, operator);
          break;
        case BinaryOperatorKind.LOGICAL_AND:
        case BinaryOperatorKind.LOGICAL_OR:
        case BinaryOperatorKind.IF_NULL:
          internalError(node, "Unexpected binary operator '${operator}'.");
          break;
      }
      registry.registerSendStructure(node, sendStructure);
    }
    return result;
  }

  /// Handle an invocation of an expression, like `(){}()` or `(foo)()`.
  ResolutionResult handleExpressionInvoke(Send node) {
    assert(invariant(node, node.isCall,
        message: "Unexpected expression: $node"));
    Node expression = node.selector;
    visitExpression(expression);
    CallStructure callStructure =
        resolveArguments(node.argumentsNode).callStructure;
    Selector selector = callStructure.callSelector;
    // TODO(johnniwinther): Remove this when all information goes through the
    // [SendStructure].
    registry.setSelector(node, selector);
    registry.registerDynamicInvocation(new UniverseSelector(selector, null));
    registry.registerSendStructure(node,
        new InvokeStructure(new AccessSemantics.expression(), selector));
    return const NoneResult();
  }

  /// Handle a, possibly invalid, assertion, like `assert(cond)` or `assert()`.
  ResolutionResult handleAssert(Send node) {
    assert(invariant(node, node.isCall,
        message: "Unexpected assert: $node"));
    // If this send is of the form "assert(expr);", then
    // this is an assertion.

    CallStructure callStructure =
        resolveArguments(node.argumentsNode).callStructure;
    SendStructure sendStructure = const AssertStructure();
    if (callStructure.argumentCount != 1) {
      compiler.reportError(
          node.selector,
          MessageKind.WRONG_NUMBER_OF_ARGUMENTS_FOR_ASSERT,
          {'argumentCount': callStructure.argumentCount});
      sendStructure = const InvalidAssertStructure();
    } else if (callStructure.namedArgumentCount != 0) {
      compiler.reportError(
          node.selector,
          MessageKind.ASSERT_IS_GIVEN_NAMED_ARGUMENTS,
          {'argumentCount': callStructure.namedArgumentCount});
      sendStructure = const InvalidAssertStructure();
    }
    registry.registerAssert(node);
    registry.registerSendStructure(node, sendStructure);
    return const AssertResult();
  }

  /// Handle access of a property of [name] on `this`, like `this.name` and
  /// `this.name()`, or `name` and `name()` in instance context.
  ResolutionResult handleThisPropertyAccess(Send node, Name name) {
    AccessSemantics semantics = new AccessSemantics.thisProperty();
    return handleDynamicAccessSemantics(node, name, semantics);
  }

  /// Handle access on `this`, like `this()` and `this` when it is parsed as a
  /// [Send] node.
  ResolutionResult handleThisAccess(Send node) {
    AccessSemantics accessSemantics = new AccessSemantics.thisAccess();
    if (node.isCall) {
      CallStructure callStructure =
          resolveArguments(node.argumentsNode).callStructure;
      Selector selector = callStructure.callSelector;
      // TODO(johnniwinther): Handle invalid this access as an
      // [AccessSemantics].
      if (checkThisAccess(node)) {
        registry.registerDynamicInvocation(
            new UniverseSelector(selector, null));
        registry.registerSendStructure(node,
            new InvokeStructure(accessSemantics, selector));
      }
      // TODO(johnniwinther): Remove this when all information goes through
      // the [SendStructure].
      registry.setSelector(node, selector);
    } else {
      // TODO(johnniwinther): Handle get of `this` when it is a [Send] node.
      internalError(node, "Unexpected node '$node'.");
    }
    return const NoneResult();
  }

  /// Handle access of a super property, like `super.foo` and `super.foo()`.
  ResolutionResult handleSuperPropertyAccess(Send node, Name name) {
    Element target;
    Selector selector;
    CallStructure callStructure = CallStructure.NO_ARGS;
    if (node.isCall) {
      callStructure =
          resolveArguments(node.argumentsNode).callStructure;
      selector = new Selector(SelectorKind.CALL, name, callStructure);
    } else {
      selector = new Selector(SelectorKind.GETTER, name, callStructure);
    }
    if (checkSuperAccess(node)) {
      AccessSemantics semantics = computeSuperAccessSemanticsForSelector(
          node, selector, alternateName: name.setter);
      if (node.isCall) {
        bool isIncompatibleInvoke = false;
        switch (semantics.kind) {
          case AccessKind.SUPER_METHOD:
            MethodElementX superMethod = semantics.element;
            superMethod.computeSignature(compiler);
            if (!callStructure.signatureApplies(
                    superMethod.functionSignature)) {
              registry.registerThrowNoSuchMethod();
              registry.registerDynamicInvocation(
                  new UniverseSelector(selector, null));
              registry.registerSuperNoSuchMethod();
              isIncompatibleInvoke = true;
            } else {
              registry.registerStaticInvocation(semantics.element);
            }
            break;
          case AccessKind.SUPER_FIELD:
          case AccessKind.SUPER_FINAL_FIELD:
          case AccessKind.SUPER_GETTER:
            registry.registerStaticUse(semantics.element);
            selector = callStructure.callSelector;
            registry.registerDynamicInvocation(
                new UniverseSelector(selector, null));
            break;
          case AccessKind.SUPER_SETTER:
          case AccessKind.UNRESOLVED_SUPER:
            // NoSuchMethod registered in [computeSuperSemantics].
            break;
          default:
            internalError(node, "Unexpected super property access $semantics.");
            break;
        }
        registry.registerSendStructure(node,
            isIncompatibleInvoke
                ? new IncompatibleInvokeStructure(semantics, selector)
                : new InvokeStructure(semantics, selector));
      } else {
        switch (semantics.kind) {
          case AccessKind.SUPER_METHOD:
            // TODO(johnniwinther): Method this should be registered as a
            // closurization.
            registry.registerStaticUse(semantics.element);
            break;
          case AccessKind.SUPER_FIELD:
          case AccessKind.SUPER_FINAL_FIELD:
          case AccessKind.SUPER_GETTER:
            registry.registerStaticUse(semantics.element);
            break;
          case AccessKind.SUPER_SETTER:
          case AccessKind.UNRESOLVED_SUPER:
            // NoSuchMethod registered in [computeSuperSemantics].
            break;
          default:
            internalError(node, "Unexpected super property access $semantics.");
            break;
        }
        registry.registerSendStructure(node,
            new GetStructure(semantics, selector));
      }
      target = semantics.element;
    }

    // TODO(johnniwinther): Remove these when all information goes through
    // the [SendStructure].
    registry.useElement(node, target);
    registry.setSelector(node, selector);
    return const NoneResult();
  }

  /// Handle a [Send] whose selector is an [Operator], like `a && b`, `a is T`,
  /// `a + b`, and `~a`.
  ResolutionResult handleOperatorSend(Send node) {
    String operatorText = node.selector.asOperator().source;
    if (operatorText == 'is') {
      return handleIs(node);
    } else if (operatorText  == 'as') {
      return handleAs(node);
    } else if (node.arguments.isEmpty) {
      UnaryOperator operator = UnaryOperator.parse(operatorText);
      if (operator == null) {
        return handleUnresolvedUnary(node, operatorText);
      } else {
        switch (operator.kind) {
          case UnaryOperatorKind.NOT:
            return handleNot(node, operator);
          case UnaryOperatorKind.COMPLEMENT:
          case UnaryOperatorKind.NEGATE:
            assert(invariant(node, operator.isUserDefinable,
                message: "Unexpected unary operator '${operator}'."));
            return handleUserDefinableUnary(node, operator);
        }
      }
    } else {
      BinaryOperator operator = BinaryOperator.parse(operatorText);
      if (operator == null) {
        return handleUnresolvedBinary(node, operatorText);
      } else {
        switch (operator.kind) {
          case BinaryOperatorKind.LOGICAL_AND:
            return handleLogicalAnd(node);
          case BinaryOperatorKind.LOGICAL_OR:
            return handleLogicalOr(node);
          case BinaryOperatorKind.IF_NULL:
            return handleIfNull(node);
          case BinaryOperatorKind.EQ:
          case BinaryOperatorKind.NOT_EQ:
          case BinaryOperatorKind.INDEX:
          case BinaryOperatorKind.ADD:
          case BinaryOperatorKind.SUB:
          case BinaryOperatorKind.MUL:
          case BinaryOperatorKind.DIV:
          case BinaryOperatorKind.IDIV:
          case BinaryOperatorKind.MOD:
          case BinaryOperatorKind.SHL:
          case BinaryOperatorKind.SHR:
          case BinaryOperatorKind.GTEQ:
          case BinaryOperatorKind.GT:
          case BinaryOperatorKind.LTEQ:
          case BinaryOperatorKind.LT:
          case BinaryOperatorKind.AND:
          case BinaryOperatorKind.OR:
          case BinaryOperatorKind.XOR:
            return handleUserDefinableBinary(node, operator);
        }
      }
    }
  }

  /// Handle qualified access to an unresolved static class member, like `a.b`
  /// or `a.b()` where `a` is a class and `b` is unresolved.
  ResolutionResult handleUnresolvedStaticMemberAccess(
      Send node, Name name, ClassElement receiverClass) {
    // TODO(johnniwinther): Share code with [handleStaticInstanceMemberAccess]
    // and [handlePrivateStaticMemberAccess].
    registry.registerThrowNoSuchMethod();
    // TODO(johnniwinther): Produce a different error if [name] is resolves to
    // a constructor.

    // TODO(johnniwinther): With the simplified [TreeElements] invariant,
    // try to resolve injected elements if [currentClass] is in the patch
    // library of [receiverClass].

    // TODO(karlklose): this should be reported by the caller of
    // [resolveSend] to select better warning messages for getters and
    // setters.
    ErroneousElement error = reportAndCreateErroneousElement(
        node, name.text, MessageKind.MEMBER_NOT_FOUND,
        {'className': receiverClass.name, 'memberName': name.text});
    // TODO(johnniwinther): Add an [AccessSemantics] for unresolved static
    // member access.
    return handleErroneousAccess(
        node, name, error, new StaticAccess.unresolved(error));
  }

  /// Handle qualified access of an instance member, like `a.b` or `a.b()` where
  /// `a` is a class and `b` is a non-static member.
  ResolutionResult handleStaticInstanceMemberAccess(
      Send node, Name name, ClassElement receiverClass, Element member) {

    registry.registerThrowNoSuchMethod();
    // TODO(johnniwinther): With the simplified [TreeElements] invariant,
    // try to resolve injected elements if [currentClass] is in the patch
    // library of [receiverClass].

    // TODO(karlklose): this should be reported by the caller of
    // [resolveSend] to select better warning messages for getters and
    // setters.
    ErroneousElement error = reportAndCreateErroneousElement(
        node, name.text, MessageKind.MEMBER_NOT_STATIC,
        {'className': receiverClass.name, 'memberName': name});

    // TODO(johnniwinther): Add an [AccessSemantics] for statically accessed
    // instance members.
    return handleErroneousAccess(
        node, name, error, new StaticAccess.unresolved(error));
  }

  /// Handle qualified access of an inaccessible private static class member,
  /// like `a._b` or `a.b()` where `a` is class, `_b` is static member of `a`
  /// but `a` is not defined in the current library.
  ResolutionResult handlePrivateStaticMemberAccess(
      Send node, Name name, ClassElement receiverClass, Element member) {
    registry.registerThrowNoSuchMethod();
    ErroneousElement error = reportAndCreateErroneousElement(
        node, name.text, MessageKind.PRIVATE_ACCESS,
        {'libraryName': member.library.getLibraryOrScriptName(),
         'name': name});
    // TODO(johnniwinther): Add an [AccessSemantics] for unresolved static
    // member access.
    return handleErroneousAccess(
        node, name, error, new StaticAccess.unresolved(error));
  }

  /// Handle qualified access to a static member, like `a.b` or `a.b()` where
  /// `a` is a class and `b` is a static member of `a`.
  ResolutionResult handleStaticMemberAccess(
      Send node, Name memberName, ClassElement receiverClass) {
    String name = memberName.text;
    receiverClass.ensureResolved(compiler);
    if (node.isOperator) {
      // When the resolved receiver is a class, we can have two cases:
      //  1) a static send: C.foo, or
      //  2) an operator send, where the receiver is a class literal: 'C + 1'.
      // The following code that looks up the selector on the resolved
      // receiver will treat the second as the invocation of a static operator
      // if the resolved receiver is not null.
      return const NoneResult();
    }
    MembersCreator.computeClassMembersByName(
        compiler, receiverClass.declaration, name);
    Element member = receiverClass.lookupLocalMember(name);
    if (member == null) {
      return handleUnresolvedStaticMemberAccess(
          node, memberName, receiverClass);
    } else if (member.isAmbiguous) {
      return handleAmbiguousSend(node, memberName, member);
    } else if (member.isInstanceMember) {
      return handleStaticInstanceMemberAccess(
          node, memberName, receiverClass, member);
    } else if (memberName.isPrivate && memberName.library != member.library) {
      return handlePrivateStaticMemberAccess(
          node, memberName, receiverClass, member);
    } else {
      return handleStaticOrTopLevelAccess(node, memberName, member);
    }
  }

  /// Handle access to a type literal of type variable [element]. Like `T` or
  /// `T()` where 'T' is type variable.
  // TODO(johnniwinther): Remove [name] when [Selector] is not required for the
  // the [GetStructure].
  // TODO(johnniwinther): Remove [element] when it is no longer needed for
  // evaluating constants.
  ResolutionResult handleTypeVariableTypeLiteralAccess(
      Send node,
      Name name,
      TypeVariableElement element) {
    if (!Elements.hasAccessToTypeVariables(enclosingElement)) {
      compiler.reportError(node,
          MessageKind.TYPE_VARIABLE_WITHIN_STATIC_MEMBER,
          {'typeVariableName': node.selector});
      // TODO(johnniwinther): Add another access semantics for this.
    }
    registry.registerClassUsingVariableExpression(element.enclosingClass);
    registry.registerTypeVariableExpression();

    AccessSemantics semantics =
        new StaticAccess.typeParameterTypeLiteral(element);
    registry.useElement(node, element);
    registry.registerTypeLiteral(node, element.type);

    if (node.isCall) {
      CallStructure callStructure =
          resolveArguments(node.argumentsNode).callStructure;
      Selector selector = callStructure.callSelector;
      // TODO(johnniwinther): Remove this when all information goes through
      // the [SendStructure].
      registry.setSelector(node, selector);

      registry.registerSendStructure(node,
          new InvokeStructure(semantics, selector));
    } else {
      // TODO(johnniwinther): Avoid the need for a [Selector] here.
      registry.registerSendStructure(node,
          new GetStructure(semantics,
              new Selector(SelectorKind.GETTER, name, CallStructure.NO_ARGS)));
    }
    return const NoneResult();
  }

  /// Handle access to a constant type literal of [type].
  // TODO(johnniwinther): Remove [name] when [Selector] is not required for the
  // the [GetStructure].
  // TODO(johnniwinther): Remove [element] when it is no longer needed for
  // evaluating constants.
  ResolutionResult handleConstantTypeLiteralAccess(
      Send node,
      Name name,
      TypeDeclarationElement element,
      DartType type,
      ConstantAccess semantics) {
    registry.useElement(node, element);
    registry.registerTypeLiteral(node, type);

    if (node.isCall) {
      CallStructure callStructure =
          resolveArguments(node.argumentsNode).callStructure;
      Selector selector = callStructure.callSelector;
      // TODO(johnniwinther): Remove this when all information goes through
      // the [SendStructure].
      registry.setSelector(node, selector);

      // The node itself is not a constant but we register the selector (the
      // identifier that refers to the class/typedef) as a constant.
      registry.useElement(node.selector, element);
      analyzeConstantDeferred(node.selector, enforceConst: false);

      registry.registerSendStructure(node,
          new InvokeStructure(semantics, selector));
      return const NoneResult();
    } else {
      analyzeConstantDeferred(node, enforceConst: false);

      // TODO(johnniwinther): Avoid the need for a [Selector] here.
      registry.registerSendStructure(node,
          new GetStructure(semantics,
              new Selector(SelectorKind.GETTER, name, CallStructure.NO_ARGS)));
      return new ConstantResult(node, semantics.constant);
    }
  }

  /// Handle access to a type literal of a typedef. Like `F` or
  /// `F()` where 'F' is typedef.
  ResolutionResult handleTypedefTypeLiteralAccess(
      Send node,
      Name name,
      TypedefElement typdef) {
    typdef.ensureResolved(compiler);
    DartType type = typdef.rawType;
    ConstantExpression constant = new TypeConstantExpression(type);
    AccessSemantics semantics = new ConstantAccess.typedefTypeLiteral(constant);
    return handleConstantTypeLiteralAccess(node, name, typdef, type, semantics);
  }

  /// Handle access to a type literal of the type 'dynamic'. Like `dynamic` or
  /// `dynamic()`.
  ResolutionResult handleDynamicTypeLiteralAccess(Send node) {
    DartType type = const DynamicType();
    ConstantExpression constant = new TypeConstantExpression(
        // TODO(johnniwinther): Use [type] when evaluation of constants is done
        // directly on the constant expressions.
        node.isCall ? coreTypes.typeType : type);
    AccessSemantics semantics = new ConstantAccess.dynamicTypeLiteral(constant);
    return handleConstantTypeLiteralAccess(
        node, const PublicName('dynamic'), compiler.typeClass, type, semantics);
  }

  /// Handle access to a type literal of a class. Like `C` or
  /// `C()` where 'C' is class.
  ResolutionResult handleClassTypeLiteralAccess(
      Send node,
      Name name,
      ClassElement cls) {
    DartType type = cls.rawType;
    ConstantExpression constant = new TypeConstantExpression(type);
    AccessSemantics semantics = new ConstantAccess.classTypeLiteral(constant);
    return handleConstantTypeLiteralAccess(node, name, cls, type, semantics);
  }

  /// Handle a [Send] that resolves to a [prefix]. Like `prefix` in
  /// `prefix.Class` or `prefix` in `prefix()`, the latter being a compile time
  /// error.
  ResolutionResult handleClassSend(
      Send node,
      Name name,
      ClassElement cls) {
    cls.ensureResolved(compiler);
    if (sendIsMemberAccess) {
      registry.useElement(node, cls);
      return new PrefixResult(null, cls);
    } else {
      // `C` or `C()` where 'C' is a class.
      return handleClassTypeLiteralAccess(node, name, cls);
    }
  }

  /// Compute a [DeferredPrefixStructure] for [node].
  ResolutionResult handleDeferredAccess(
      Send node,
      PrefixElement prefix,
      ResolutionResult result) {
    assert(invariant(node, prefix.isDeferred,
        message: "Prefix $prefix is not deferred."));
    SendStructure sendStructure = registry.getSendStructure(node);
    assert(invariant(node, sendStructure !=  null,
        message: "No SendStructure for $node."));
    registry.registerSendStructure(node,
        new DeferredPrefixStructure(prefix, sendStructure));
    if (result.isConstant) {
      ConstantExpression constant =
          new DeferredConstantExpression(result.constant, prefix);
      registry.setConstant(node, constant);
      result = new ConstantResult(node, constant);
    }
    return result;
  }

  /// Handle qualified [Send] where the receiver resolves to a [prefix],
  /// like `prefix.toplevelFunction()` or `prefix.Class.staticField` where
  /// `prefix` is a library prefix.
  ResolutionResult handleLibraryPrefixSend(
      Send node, PrefixElement prefix, Name name) {
    ResolutionResult result;
    Element member = prefix.lookupLocalMember(name.text);
    if (member == null) {
      registry.registerThrowNoSuchMethod();
      Element error = reportAndCreateErroneousElement(
          node, name.text, MessageKind.NO_SUCH_LIBRARY_MEMBER,
          {'libraryName': prefix.name, 'memberName': name});
      result = handleUnresolvedAccess(node, name, error);
    } else {
      result = handleResolvedSend(node, name, member);
    }
    if (result.kind == ResultKind.PREFIX) {
      // [member] is a class prefix of a static access like `prefix.Class` of
      // `prefix.Class.foo`. No need to call [handleDeferredAccess]; it will
      // called on the parent `prefix.Class.foo` node.
      result = new PrefixResult(prefix, result.element);
    } else if (prefix.isDeferred &&
               (member == null || !member.isDeferredLoaderGetter)) {
      result = handleDeferredAccess(node, prefix, result);
    }
    return result;
  }

  /// Handle a [Send] that resolves to a [prefix]. Like `prefix` in
  /// `prefix.Class` or `prefix` in `prefix()`, the latter being a compile time
  /// error.
  ResolutionResult handleLibraryPrefix(
      Send node,
      Name name,
      PrefixElement prefix) {
    if ((ElementCategory.PREFIX & allowedCategory) == 0) {
      ErroneousElement error = reportAndCreateErroneousElement(
          node,
          name.text,
          MessageKind.PREFIX_AS_EXPRESSION,
          {'prefix': name},
          isError: true);
      return handleErroneousAccess(
          node, name, error, new StaticAccess.invalid(error));
    }
    if (prefix.isDeferred) {
      // TODO(johnniwinther): Remove this when deferred access is detected
      // through a [SendStructure].
      registry.useElement(node.selector, prefix);
    }
    registry.useElement(node, prefix);
    return new PrefixResult(prefix, null);
  }

  /// Handle qualified [Send] where the receiver resolves to an [Element], like
  /// `a.b` where `a` is a prefix or a class.
  ResolutionResult handlePrefixSend(
      Send node, Name name, PrefixResult prefixResult) {
    Element element = prefixResult.element;
    if (element.isPrefix) {
      return handleLibraryPrefixSend(node, element, name);
    } else {
      assert(element.isClass);
      ResolutionResult result = handleStaticMemberAccess(node, name, element);
      if (prefixResult.isDeferred) {
        result = handleDeferredAccess(node, prefixResult.prefix, result);
      }
      return result;
    }
  }

  /// Handle dynamic access of [semantics].
  ResolutionResult handleDynamicAccessSemantics(
      Send node, Name name, AccessSemantics semantics) {
    SendStructure sendStructure;
    Selector selector;
    if (node.isCall) {
      CallStructure callStructure =
          resolveArguments(node.argumentsNode).callStructure;
      selector = new Selector(SelectorKind.CALL, name, callStructure);
      registry.registerDynamicInvocation(
          new UniverseSelector(selector, null));
      sendStructure = new InvokeStructure(semantics, selector);
    } else {
      assert(invariant(node, node.isPropertyAccess));
      selector = new Selector(
          SelectorKind.GETTER, name, CallStructure.NO_ARGS);
      registry.registerDynamicGetter(
          new UniverseSelector(selector, null));
      sendStructure = new GetStructure(semantics, selector);
    }
    registry.registerSendStructure(node, sendStructure);
    // TODO(johnniwinther): Remove this when all information goes through
    // the [SendStructure].
    registry.setSelector(node, selector);
    return const NoneResult();
  }

  /// Handle dynamic property access, like `a.b` or `a.b()` where `a` is not a
  /// prefix or class.
  ResolutionResult handleDynamicPropertyAccess(Send node, Name name) {
    AccessSemantics semantics =
        new DynamicAccess.dynamicProperty(node.receiver);
    return handleDynamicAccessSemantics(node, name, semantics);
  }

  /// Handle conditional access, like `a?.b` or `a?.b()`.
  ResolutionResult handleConditionalAccess(Send node, Name name) {
    Node receiver = node.receiver;
    visitConditionalPrefix(receiver);
    AccessSemantics semantics =
        new DynamicAccess.ifNotNullProperty(receiver);
    return handleDynamicAccessSemantics(node, name, semantics);
  }

  /// Handle `this` as a qualified property, like `a.this`.
  ResolutionResult handleQualifiedThisAccess(Send node, Name name) {
    ErroneousElement error = reportAndCreateErroneousElement(
        node.selector,
        name.text,
        MessageKind.THIS_PROPERTY, {},
        isError: true);
    AccessSemantics accessSemantics = new StaticAccess.invalid(error);
    return handleErroneousAccess(node, name, error, accessSemantics);
  }

  /// Handle a qualified [Send], that is where the receiver is non-null, like
  /// `a.b`, `a.b()`, `this.a()` and `super.a()`.
  ResolutionResult handleQualifiedSend(Send node) {
    Identifier selector = node.selector.asIdentifier();
    String text = selector.source;
    Name name = new Name(text, enclosingElement.library);
    if (text == 'this') {
      return handleQualifiedThisAccess(node, name);
    } else if (node.isSuperCall) {
      return handleSuperPropertyAccess(node, name);
    } else if (node.receiver.isThis()) {
      if (checkThisAccess(node)) {
        return handleThisPropertyAccess(node, name);
      }
      // TODO(johnniwinther): Handle invalid this access as an
      // [AccessSemantics].
      return const NoneResult();
    } else if (node.isConditional) {
      return handleConditionalAccess(node, name);
    }
    ResolutionResult result = visitExpressionPrefix(node.receiver);
    if (result.kind == ResultKind.PREFIX) {
      return handlePrefixSend(node, name, result);
    } else {
      // TODO(johnniwinther): Use the `element` of [result].
      return handleDynamicPropertyAccess(node, name);
    }
  }

  /// Handle access unresolved access to [name] in a non-instance context.
  ResolutionResult handleUnresolvedAccess(
        Send node, Name name, Element element) {
    // TODO(johnniwinther): Support unresolved top level access as an
    // [AccessSemantics].
    AccessSemantics accessSemantics = new StaticAccess.unresolved(element);
    return handleErroneousAccess(node, name, element, accessSemantics);
  }

  /// Handle erroneous access of [element] of the given [accessSemantics].
  ResolutionResult handleErroneousAccess(
      Send node, Name name, Element element, AccessSemantics accessSemantics) {
    SendStructure sendStructure;
    Selector selector;
    if (node.isCall) {
      CallStructure callStructure =
          resolveArguments(node.argumentsNode).callStructure;
      selector = new Selector(SelectorKind.CALL, name, callStructure);
      registry.registerDynamicInvocation(
          new UniverseSelector(selector, null));
      sendStructure = new InvokeStructure(accessSemantics, selector);
    } else {
      assert(invariant(node, node.isPropertyAccess));
      selector = new Selector(
          SelectorKind.GETTER, name, CallStructure.NO_ARGS);
      registry.registerDynamicGetter(
          new UniverseSelector(selector, null));
      sendStructure = new GetStructure(accessSemantics, selector);
    }
    // TODO(johnniwinther): Remove this when all information goes through
    // the [SendStructure].
    registry.setSelector(node, selector);
    registry.useElement(node, element);
    registry.registerSendStructure(node, sendStructure);
    return const NoneResult();
  }

  /// Handle access to an ambiguous element, that is, a name imported twice.
  ResolutionResult handleAmbiguousSend(
      Send node,
      Name name,
      AmbiguousElement element) {

    ErroneousElement error = reportAndCreateErroneousElement(
        node,
        name.text,
        element.messageKind,
        element.messageArguments);
    element.diagnose(enclosingElement, compiler);
    registry.registerThrowNoSuchMethod();

    // TODO(johnniwinther): Support ambiguous access as an [AccessSemantics].
    AccessSemantics accessSemantics = new StaticAccess.unresolved(error);
    return handleErroneousAccess(node, name, error, accessSemantics);
  }

  /// Handle access of an instance [member] from a non-instance context.
  ResolutionResult handleStaticInstanceSend(
      Send node, Name name, MemberElement member) {
    compiler.reportError(
        node, MessageKind.NO_INSTANCE_AVAILABLE, {'name': member.name});
    ErroneousElement error = new ErroneousElementX(
        MessageKind.NO_INSTANCE_AVAILABLE,
        {'name': name},
        name.text,
        enclosingElement);

    // TODO(johnniwinther): Support static instance access as an
    // [AccessSemantics].
    AccessSemantics accessSemantics = new StaticAccess.unresolved(error);
    return handleErroneousAccess(node, name, error, accessSemantics);
  }

  /// Handle access of a parameter, local variable or local function.
  ResolutionResult handleLocalAccess(Send node, Name name, Element element) {
    ResolutionResult result = const NoneResult();
    AccessSemantics semantics = computeLocalAccessSemantics(node, element);
    Selector selector;
    if (node.isCall) {
      CallStructure callStructure =
          resolveArguments(node.argumentsNode).callStructure;
      selector = new Selector(SelectorKind.CALL, name, callStructure);
      bool isIncompatibleInvoke = false;
      switch (semantics.kind) {
        case AccessKind.LOCAL_FUNCTION:
          LocalFunctionElementX function = semantics.element;
          function.computeSignature(compiler);
          if (!callStructure.signatureApplies(function.functionSignature)) {
            registry.registerThrowNoSuchMethod();
            registry.registerDynamicInvocation(
                new UniverseSelector(selector, null));
            isIncompatibleInvoke = true;
          }
          break;
        case AccessKind.PARAMETER:
        case AccessKind.FINAL_PARAMETER:
        case AccessKind.LOCAL_VARIABLE:
        case AccessKind.FINAL_LOCAL_VARIABLE:
          selector = callStructure.callSelector;
          registry.registerDynamicInvocation(
              new UniverseSelector(selector, null));
          break;
        default:
          internalError(node,
              "Unexpected local access $semantics.");
          break;
      }
      registry.registerSendStructure(node,
          isIncompatibleInvoke
              ? new IncompatibleInvokeStructure(semantics, selector)
              : new InvokeStructure(semantics, selector));
    } else {
      switch (semantics.kind) {
        case AccessKind.LOCAL_VARIABLE:
        case AccessKind.LOCAL_FUNCTION:
          result = new ElementResult(element);
          break;
        case AccessKind.PARAMETER:
        case AccessKind.FINAL_PARAMETER:
          if (constantState == ConstantState.CONSTANT_INITIALIZER) {
            ParameterElement parameter = element;
            if (parameter.isNamed) {
              result = new ConstantResult(
                  node,
                  new NamedArgumentReference(parameter.name),
                  element: element);
            } else {
              result = new ConstantResult(
                  node,
                  new PositionalArgumentReference(
                      parameter.functionDeclaration.parameters.indexOf(
                          parameter)),
                  element: element);
            }
          } else {
            result = new ElementResult(element);
          }
          break;
        case AccessKind.FINAL_LOCAL_VARIABLE:
          if (element.isConst) {
            result = new ConstantResult(
                node,
                new VariableConstantExpression(element),
                element: element);
          } else {
            result = new ElementResult(element);
          }
          break;
        default:
          internalError(node,
              "Unexpected local access $semantics.");
          break;
      }
      selector = new Selector(SelectorKind.GETTER, name, CallStructure.NO_ARGS);
      registry.registerSendStructure(node,
          new GetStructure(semantics, selector));
    }

    // TODO(johnniwinther): Remove these when all information goes through
    // the [SendStructure].
    registry.useElement(node, element);
    registry.setSelector(node, selector);

    registerPotentialAccessInClosure(node, element);

    return result;
  }

  /// Handle access of a static or top level [element].
  ResolutionResult handleStaticOrTopLevelAccess(
        Send node, Name name, Element element) {
    ResolutionResult result = const NoneResult();
    MemberElement member;
    if (element.isAbstractField) {
      AbstractFieldElement abstractField = element;
      if (abstractField.getter != null) {
        member = abstractField.getter;
      } else {
        member = abstractField.setter;
      }
    } else {
      member = element;
    }
    // TODO(johnniwinther): Needed to provoke a parsing and with it discovery
    // of parse errors to make [element] erroneous. Fix this!
    member.computeType(compiler);


    if (member == compiler.mirrorSystemGetNameFunction &&
        !compiler.mirrorUsageAnalyzerTask.hasMirrorUsage(enclosingElement)) {
      compiler.reportHint(
          node.selector, MessageKind.STATIC_FUNCTION_BLOAT,
          {'class': compiler.mirrorSystemClass.name,
           'name': compiler.mirrorSystemGetNameFunction.name});
    }

    Selector selector;
    AccessSemantics semantics =
        computeStaticOrTopLevelAccessSemantics(node, member);
    if (node.isCall) {
      ArgumentsResult argumentsResult =
          resolveArguments(node.argumentsNode);
      CallStructure callStructure = argumentsResult.callStructure;
      selector = new Selector(SelectorKind.CALL, name, callStructure);

      bool isIncompatibleInvoke = false;
      switch (semantics.kind) {
        case AccessKind.STATIC_METHOD:
        case AccessKind.TOPLEVEL_METHOD:
          MethodElement method = semantics.element;
          method.computeType(compiler);
          if (!callStructure.signatureApplies(method.functionSignature)) {
            registry.registerThrowNoSuchMethod();
            registry.registerDynamicInvocation(
                new UniverseSelector(selector, null));
            isIncompatibleInvoke = true;
          } else {
            registry.registerStaticUse(semantics.element);
            handleForeignCall(node, semantics.element, selector);
            if (method == compiler.identicalFunction &&
                argumentsResult.isValidAsConstant) {
              result = new ConstantResult(node,
                  new IdenticalConstantExpression(
                      argumentsResult.argumentResults[0].constant,
                      argumentsResult.argumentResults[1].constant));
            }
          }
          break;
        case AccessKind.STATIC_FIELD:
        case AccessKind.FINAL_STATIC_FIELD:
        case AccessKind.STATIC_GETTER:
        case AccessKind.TOPLEVEL_FIELD:
        case AccessKind.FINAL_TOPLEVEL_FIELD:
        case AccessKind.TOPLEVEL_GETTER:
          registry.registerStaticUse(semantics.element);
          selector = callStructure.callSelector;
          registry.registerDynamicInvocation(
              new UniverseSelector(selector, null));
          break;
        case AccessKind.STATIC_SETTER:
        case AccessKind.TOPLEVEL_SETTER:
        case AccessKind.UNRESOLVED:
          registry.registerThrowNoSuchMethod();
          member = reportAndCreateErroneousElement(
              node.selector, name.text,
              MessageKind.CANNOT_RESOLVE_GETTER, const {});
          break;
        default:
          internalError(node,
              "Unexpected statically resolved access $semantics.");
          break;
      }
      registry.registerSendStructure(node,
          isIncompatibleInvoke
              ? new IncompatibleInvokeStructure(semantics, selector)
              : new InvokeStructure(semantics, selector));
    } else {
      selector = new Selector(SelectorKind.GETTER, name, CallStructure.NO_ARGS);
      switch (semantics.kind) {
        case AccessKind.STATIC_METHOD:
        case AccessKind.TOPLEVEL_METHOD:
          // TODO(johnniwinther): Method this should be registered as a
          // closurization.
          registry.registerStaticUse(semantics.element);
          registry.registerGetOfStaticFunction(semantics.element);
          break;
        case AccessKind.STATIC_FIELD:
        case AccessKind.FINAL_STATIC_FIELD:
        case AccessKind.STATIC_GETTER:
        case AccessKind.TOPLEVEL_FIELD:
        case AccessKind.FINAL_TOPLEVEL_FIELD:
        case AccessKind.TOPLEVEL_GETTER:
          registry.registerStaticUse(semantics.element);
          break;
        case AccessKind.STATIC_SETTER:
        case AccessKind.TOPLEVEL_SETTER:
        case AccessKind.UNRESOLVED:
          registry.registerThrowNoSuchMethod();
          member = reportAndCreateErroneousElement(
              node.selector, name.text,
              MessageKind.CANNOT_RESOLVE_GETTER, const {});
          break;
        default:
          internalError(node,
              "Unexpected statically resolved access $semantics.");
          break;
      }
      registry.registerSendStructure(node,
          new GetStructure(semantics, selector));
      if (member.isConst) {
        FieldElement field = member;
        result = new ConstantResult(
            node, new VariableConstantExpression(field), element: field);
      } else {
        result = new ElementResult(member);
      }
    }

    // TODO(johnniwinther): Remove these when all information goes through
    // the [SendStructure].
    registry.useElement(node, member);
    registry.setSelector(node, selector);

    return result;
  }

  /// Handle access to resolved [element].
  ResolutionResult handleResolvedSend(Send node, Name name, Element element) {
    if (element.isAmbiguous) {
      return handleAmbiguousSend(node, name, element);
    }
    if (element.isErroneous) {
      // This handles elements with parser errors.
      // TODO(johnniwinther): Elements with parse error should not set
      // [isErroneous] to `true`.
      assert(invariant(node, element is! ErroneousElement,
          message: "Unexpected erroneous element $element."));
      return handleErroneousAccess(node, name, element,
          new StaticAccess.unresolved(element));
    }
    if (element.isInstanceMember) {
      if (inInstanceContext) {
        // TODO(johnniwinther): Maybe use the found [element].
        return handleThisPropertyAccess(node, name);
      } else {
        return handleStaticInstanceSend(node, name, element);
      }
    }
    if (element.isClass) {
      // `C`, `C()`, or 'C.b` where 'C' is a class.
      return handleClassSend(node, name, element);
    } else if (element.isTypedef) {
      // `F` or `F()` where 'F' is a typedef.
      return handleTypedefTypeLiteralAccess(node, name, element);
    } else if (element.isTypeVariable) {
      return handleTypeVariableTypeLiteralAccess(node, name, element);
    } else if (element.isPrefix) {
      return handleLibraryPrefix(node, name, element);
    } else if (element.isLocal) {
      return handleLocalAccess(node, name, element);
    } else if (element.isStatic || element.isTopLevel) {
      return handleStaticOrTopLevelAccess(node, name, element);
    }
    return internalError(node, "Unexpected resolved send: $element");
  }

  /// Handle an unqualified [Send], that is where the `node.receiver` is null,
  /// like `a`, `a()`, `this()`, `assert()`, and `(){}()`.
  ResolutionResult handleUnqualifiedSend(Send node) {
    Identifier selector = node.selector.asIdentifier();
    if (selector == null) {
      // `(){}()` and `(foo)()`.
      return handleExpressionInvoke(node);
    }
    String text = selector.source;
    if (text == 'assert') {
      // `assert()`.
      return handleAssert(node);
    } else if (text == 'this') {
      // `this()`.
      return handleThisAccess(node);
    }
    // `name` or `name()`
    Name name = new Name(text, enclosingElement.library);
    Element element = lookupInScope(compiler, node, scope, text);
    if (element == null) {
      if (text == 'dynamic') {
        // `dynamic` or `dynamic()` where 'dynamic' is not declared in the
        // current scope.
        return handleDynamicTypeLiteralAccess(node);
      } else if (inInstanceContext) {
        // Implicitly `this.name`.
        return handleThisPropertyAccess(node, name);
      } else {
        // Create [ErroneousElement] for unresolved access.
        ErroneousElement error = reportCannotResolve(node, text);
        return handleUnresolvedAccess(node, name, error);
      }
    } else {
      return handleResolvedSend(node, name, element);
    }
  }

  ResolutionResult visitSend(Send node) {
    if (node.isOperator) {
      // `a && b`, `a + b`, `-a`, or `a is T`.
      return handleOperatorSend(node);
    } else if (node.receiver != null) {
      // `a.b`.
      return handleQualifiedSend(node);
    } else {
      // `a`.
      return handleUnqualifiedSend(node);
    }
  }

  /// Register read access of [target] inside a closure.
  void registerPotentialAccessInClosure(Send node, Element target) {
    if (isPotentiallyMutableTarget(target)) {
      if (enclosingElement != target.enclosingElement) {
        for (Node scope in promotionScope) {
          registry.setAccessedByClosureIn(scope, target, node);
        }
      }
    }
  }

  // TODO(johnniwinther): Move this to the backend resolution callbacks.
  void handleForeignCall(Send node, Element target, Selector selector) {
    if (target != null && compiler.backend.isForeign(target)) {
      if (selector.name == 'JS') {
        registry.registerJsCall(node, this);
      } else if (selector.name == 'JS_EMBEDDED_GLOBAL') {
        registry.registerJsEmbeddedGlobalCall(node, this);
      } else if (selector.name == 'JS_BUILTIN') {
        registry.registerJsBuiltinCall(node, this);
      } else if (selector.name == 'JS_INTERCEPTOR_CONSTANT') {
        if (!node.argumentsNode.isEmpty) {
          Node argument = node.argumentsNode.nodes.head;
          if (argumentsToJsInterceptorConstant == null) {
            argumentsToJsInterceptorConstant = new Set<Node>();
          }
          argumentsToJsInterceptorConstant.add(argument);
        }
      }
    }
  }

  /// Callback for native enqueuer to parse a type.  Returns [:null:] on error.
  DartType resolveTypeFromString(Node node, String typeName) {
    Element element = lookupInScope(compiler, node, scope, typeName);
    if (element == null) return null;
    if (element is! ClassElement) return null;
    ClassElement cls = element;
    cls.ensureResolved(compiler);
    return cls.computeType(compiler);
  }

  /// Handle index operations like `a[b] = c`, `a[b] += c`, and `a[b]++`.
  ResolutionResult handleIndexSendSet(SendSet node) {
    String operatorText = node.assignmentOperator.source;
    Node receiver = node.receiver;
    Node index = node.arguments.head;
    visitExpression(receiver);
    visitExpression(index);
    if (node.isPrefix || node.isPostfix) {
      // `a[b]++` or `++a[b]`.
      IncDecOperator operator = IncDecOperator.parse(operatorText);
      AccessSemantics semantics = new DynamicAccess.dynamicProperty(receiver);
      Selector getterSelector = new Selector.index();
      Selector setterSelector = new Selector.indexSet();
      Selector operatorSelector =
          new Selector.binaryOperator(operator.selectorName);

      // TODO(johnniwinther): Remove these when selectors are only accessed
      // through the send structure.
      registry.setGetterSelectorInComplexSendSet(node, getterSelector);
      registry.setSelector(node, setterSelector);
      registry.setOperatorSelectorInComplexSendSet(node, operatorSelector);

      registry.registerDynamicInvocation(
          new UniverseSelector(getterSelector, null));
      registry.registerDynamicInvocation(
          new UniverseSelector(setterSelector, null));
      registry.registerDynamicInvocation(
          new UniverseSelector(operatorSelector, null));

      SendStructure sendStructure = node.isPrefix
          ? new IndexPrefixStructure(
              semantics, operator, getterSelector, setterSelector)
          : new IndexPostfixStructure(
              semantics, operator, getterSelector, setterSelector);
      registry.registerSendStructure(node, sendStructure);
      return const NoneResult();
    } else {
      Node rhs = node.arguments.tail.head;
      visitExpression(rhs);

      AssignmentOperator operator = AssignmentOperator.parse(operatorText);
      if (operator.kind == AssignmentOperatorKind.ASSIGN) {
        // `a[b] = c`.
        AccessSemantics semantics = new DynamicAccess.dynamicProperty(receiver);
        Selector setterSelector = new Selector.indexSet();

        // TODO(johnniwinther): Remove this when selectors are only accessed
        // through the send structure.
        registry.setSelector(node, setterSelector);
        registry.registerDynamicInvocation(
            new UniverseSelector(setterSelector, null));

        SendStructure sendStructure =
            new IndexSetStructure(semantics, setterSelector);
        registry.registerSendStructure(node, sendStructure);
        return const NoneResult();
      } else {
        // `a[b] += c`.
        AccessSemantics semantics = new DynamicAccess.dynamicProperty(receiver);
        Selector getterSelector = new Selector.index();
        Selector setterSelector = new Selector.indexSet();
        Selector operatorSelector =
            new Selector.binaryOperator(operator.selectorName);

        // TODO(johnniwinther): Remove these when selectors are only accessed
        // through the send structure.
        registry.setGetterSelectorInComplexSendSet(node, getterSelector);
        registry.setSelector(node, setterSelector);
        registry.setOperatorSelectorInComplexSendSet(node, operatorSelector);

        registry.registerDynamicInvocation(
            new UniverseSelector(getterSelector, null));
        registry.registerDynamicInvocation(
            new UniverseSelector(setterSelector, null));
        registry.registerDynamicInvocation(
            new UniverseSelector(operatorSelector, null));

        SendStructure sendStructure = new CompoundIndexSetStructure(
                semantics, operator, getterSelector, setterSelector);
        registry.registerSendStructure(node, sendStructure);
        return const NoneResult();
      }
    }
  }

  ResolutionResult visitSendSet(SendSet node) {
    if (node.isIndex) {
      if (node.isSuperCall) {
        // TODO(johnniwinther): Refactor index operations on super.
      } else {
        return handleIndexSendSet(node);
      }
    }
    return oldVisitSendSet(node);
  }

  ResolutionResult oldVisitSendSet(SendSet node) {
    bool oldSendIsMemberAccess = sendIsMemberAccess;
    sendIsMemberAccess = node.isPropertyAccess || node.isCall;
    ResolutionResult result = resolveSend(node);
    sendIsMemberAccess = oldSendIsMemberAccess;
    Element target = result.element;
    Element setter = target;
    Element getter = target;
    String operatorName = node.assignmentOperator.source;
    String source = operatorName;
    bool isComplex = !identical(source, '=');
    if (!(result is AssertResult || Elements.isUnresolved(target))) {
      if (target.isAbstractField) {
        AbstractFieldElement field = target;
        setter = field.setter;
        getter = field.getter;
        if (setter == null) {
          if (!inInstanceContext || getter.isTopLevel || getter.isStatic) {
            setter = reportAndCreateErroneousElement(node.selector, field.name,
                MessageKind.CANNOT_RESOLVE_SETTER, const {});
            registry.registerThrowNoSuchMethod();
          }
        }
        if (isComplex && getter == null && !inInstanceContext) {
          getter = reportAndCreateErroneousElement(node.selector, field.name,
              MessageKind.CANNOT_RESOLVE_GETTER, const {});
          registry.registerThrowNoSuchMethod();
        }
      } else if (target.impliesType) {
        if (node.isIfNullAssignment) {
          setter = reportAndCreateErroneousElement(node.selector, target.name,
              MessageKind.IF_NULL_ASSIGNING_TYPE, const {});
          // In this case, no assignment happens, the rest of the compiler can
          // treat the expression `C ??= e` as if it's just reading `C`.
        } else {
          setter = reportAndCreateErroneousElement(node.selector, target.name,
              MessageKind.ASSIGNING_TYPE, const {});
          registry.registerThrowNoSuchMethod();
        }
        registerTypeLiteralAccess(node, target);
      } else if (target.isFinal || target.isConst) {
        if (Elements.isStaticOrTopLevelField(target) || target.isLocal) {
          setter = reportAndCreateErroneousElement(
              node.selector, target.name, MessageKind.CANNOT_RESOLVE_SETTER,
              const {});
        } else if (node.isSuperCall) {
          setter = reportAndCreateErroneousElement(
              node.selector, target.name, MessageKind.SETTER_NOT_FOUND_IN_SUPER,
              {'name': target.name, 'className': currentClass.name});
          registry.registerSuperNoSuchMethod();
        } else {
          // For instance fields we don't report a warning here because the type
          // checker will detect this as well and report a better error message
          // with the context of the containing class.
        }
        registry.registerThrowNoSuchMethod();
      } else if (target.isFunction && target.name != '[]=') {
        assert(!target.isSetter);
        if (Elements.isStaticOrTopLevelFunction(target) || target.isLocal) {
          setter = reportAndCreateErroneousElement(
              node.selector, target.name, MessageKind.ASSIGNING_METHOD,
              const {});
        } else if (node.isSuperCall) {
          setter = reportAndCreateErroneousElement(
              node.selector, target.name, MessageKind.ASSIGNING_METHOD_IN_SUPER,
              {'name': target.name,
               'superclassName': target.enclosingElement.name});
          registry.registerSuperNoSuchMethod();
        } else {
          // For instance methods we don't report a warning here because the
          // type checker will detect this as well and report a better error
          // message with the context of the containing class.
        }
        registry.registerThrowNoSuchMethod();
      }
      if (isPotentiallyMutableTarget(target)) {
        registry.registerPotentialMutation(target, node);
        if (enclosingElement != target.enclosingElement) {
          registry.registerPotentialMutationInClosure(target, node);
        }
        for (Node scope in promotionScope) {
          registry.registerPotentialMutationIn(scope, target, node);
        }
      }
    }

    resolveArguments(node.argumentsNode);

    Selector selector = registry.getSelector(node);
    if (isComplex) {
      Selector getterSelector;
      if (selector.isSetter) {
        getterSelector = new Selector.getterFrom(selector);
      } else {
        assert(selector.isIndexSet);
        getterSelector = new Selector.index();
      }
      registerSend(getterSelector, getter);
      registry.setGetterSelectorInComplexSendSet(node, getterSelector);
      if (node.isSuperCall) {
        getter = currentClass.lookupSuperByName(getterSelector.memberName);
        if (getter == null) {
          target = reportAndCreateErroneousElement(
              node, selector.name, MessageKind.NO_SUCH_SUPER_MEMBER,
              {'className': currentClass.name, 'memberName': selector.name});
          registry.registerSuperNoSuchMethod();
        }
      }
      registry.useElement(node.selector, getter);

      // Make sure we include the + and - operators if we are using
      // the ++ and -- ones.  Also, if op= form is used, include op itself.
      void registerBinaryOperator(String name) {
        Selector binop = new Selector.binaryOperator(name);
        registry.registerDynamicInvocation(
            new UniverseSelector(binop, null));
        registry.setOperatorSelectorInComplexSendSet(node, binop);
      }
      if (identical(source, '++')) {
        registerBinaryOperator('+');
        registry.registerInstantiatedClass(compiler.intClass);
      } else if (identical(source, '--')) {
        registerBinaryOperator('-');
        registry.registerInstantiatedClass(compiler.intClass);
      } else if (source.endsWith('=')) {
        registerBinaryOperator(Elements.mapToUserOperator(operatorName));
      }
    }

    registerSend(selector, setter);
    return new ResolutionResult.forElement(registry.useElement(node, setter));
  }

  void registerSend(Selector selector, Element target) {
    if (target == null || target.isInstanceMember) {
      if (selector.isGetter) {
        registry.registerDynamicGetter(
            new UniverseSelector(selector, null));
      } else if (selector.isSetter) {
        registry.registerDynamicSetter(
            new UniverseSelector(selector, null));
      } else {
        registry.registerDynamicInvocation(
            new UniverseSelector(selector, null));
      }
    } else if (Elements.isStaticOrTopLevel(target)) {
      // Avoid registration of type variables since they are not analyzable but
      // instead resolved through their enclosing type declaration.
      if (!target.isTypeVariable) {
        // [target] might be the implementation element and only declaration
        // elements may be registered.
        registry.registerStaticUse(target.declaration);
      }
    }
  }

  ConstantResult visitLiteralInt(LiteralInt node) {
    registry.registerInstantiatedType(coreTypes.intType);
    ConstantExpression constant = new IntConstantExpression(node.value);
    registry.setConstant(node, constant);
    return new ConstantResult(node, constant);
  }

  ConstantResult visitLiteralDouble(LiteralDouble node) {
    registry.registerInstantiatedType(coreTypes.doubleType);
    ConstantExpression constant = new DoubleConstantExpression(node.value);
    registry.setConstant(node, constant);
    return new ConstantResult(node, constant);
  }

  ConstantResult visitLiteralBool(LiteralBool node) {
    registry.registerInstantiatedType(coreTypes.boolType);
    ConstantExpression constant = new BoolConstantExpression(node.value);
    registry.setConstant(node, constant);
    return new ConstantResult(node, constant);
  }

  ResolutionResult visitLiteralString(LiteralString node) {
    registry.registerInstantiatedType(coreTypes.stringType);
    if (node.dartString != null) {
      // [dartString] might be null on parser errors.
      ConstantExpression constant =
          new StringConstantExpression(node.dartString.slowToString());
      registry.setConstant(node, constant);
      return new ConstantResult(node, constant);
    }
    return const NoneResult();
  }

  ConstantResult visitLiteralNull(LiteralNull node) {
    registry.registerInstantiatedType(coreTypes.nullType);
    ConstantExpression constant = new NullConstantExpression();
    registry.setConstant(node, constant);
    return new ConstantResult(node, constant);
  }

  ConstantResult visitLiteralSymbol(LiteralSymbol node) {
    registry.registerInstantiatedClass(compiler.symbolClass);
    registry.registerStaticUse(compiler.symbolConstructor.declaration);
    String name = node.slowNameString;
    registry.registerConstSymbol(name);
    if (!validateSymbol(node, name, reportError: false)) {
      compiler.reportError(node,
          MessageKind.UNSUPPORTED_LITERAL_SYMBOL,
          {'value': name});
    }
    analyzeConstantDeferred(node);
    ConstantExpression constant = new SymbolConstantExpression(name);
    registry.setConstant(node, constant);
    return new ConstantResult(node, constant);
  }

  ResolutionResult visitStringJuxtaposition(StringJuxtaposition node) {
    registry.registerInstantiatedType(coreTypes.stringType);
    ResolutionResult first = visit(node.first);
    ResolutionResult second = visit(node.second);
    if (first.isConstant && second.isConstant) {
      ConstantExpression constant = new ConcatenateConstantExpression(
          <ConstantExpression>[first.constant, second.constant]);
      registry.setConstant(node, constant);
      return new ConstantResult(node, constant);
    }
    return const NoneResult();
  }

  ResolutionResult visitNodeList(NodeList node) {
    for (Link<Node> link = node.nodes; !link.isEmpty; link = link.tail) {
      visit(link.head);
    }
    return const NoneResult();
  }

  ResolutionResult visitRethrow(Rethrow node) {
    if (!inCatchBlock) {
      error(node, MessageKind.THROW_WITHOUT_EXPRESSION);
    }
    return const NoneResult();
  }

  ResolutionResult visitReturn(Return node) {
    Node expression = node.expression;
    if (expression != null) {
      if (enclosingElement.isGenerativeConstructor) {
        // It is a compile-time error if a return statement of the form
        // `return e;` appears in a generative constructor.  (Dart Language
        // Specification 13.12.)
        compiler.reportError(expression,
                             MessageKind.CANNOT_RETURN_FROM_CONSTRUCTOR);
      } else if (!node.isArrowBody && currentAsyncMarker.isYielding) {
        compiler.reportError(
            node,
            MessageKind.RETURN_IN_GENERATOR,
            {'modifier': currentAsyncMarker});
      }
    }
    visit(node.expression);
    return const NoneResult();
  }

  ResolutionResult visitYield(Yield node) {
    compiler.streamClass.ensureResolved(compiler);
    compiler.iterableClass.ensureResolved(compiler);
    visit(node.expression);
    return const NoneResult();
  }

  ResolutionResult visitRedirectingFactoryBody(RedirectingFactoryBody node) {
    final isSymbolConstructor = enclosingElement == compiler.symbolConstructor;
    if (!enclosingElement.isFactoryConstructor) {
      compiler.reportError(
          node, MessageKind.FACTORY_REDIRECTION_IN_NON_FACTORY);
      compiler.reportHint(
          enclosingElement, MessageKind.MISSING_FACTORY_KEYWORD);
    }
    ConstructorElementX constructor = enclosingElement;
    bool isConstConstructor = constructor.isConst;
    bool isValidAsConstant = isConstConstructor;
    ConstructorElement redirectionTarget = resolveRedirectingFactory(
        node, inConstContext: isConstConstructor);
    constructor.immediateRedirectionTarget = redirectionTarget;

    Node constructorReference = node.constructorReference;
    if (constructorReference is Send) {
      constructor.redirectionDeferredPrefix =
          compiler.deferredLoadTask.deferredPrefixElement(constructorReference,
                                                          registry.mapping);
    }

    registry.setRedirectingTargetConstructor(node, redirectionTarget);
    if (Elements.isUnresolved(redirectionTarget)) {
      registry.registerThrowNoSuchMethod();
      return const NoneResult();
    } else {
      if (isConstConstructor &&
          !redirectionTarget.isConst) {
        compiler.reportError(node, MessageKind.CONSTRUCTOR_IS_NOT_CONST);
        isValidAsConstant = false;
      }
      if (redirectionTarget == constructor) {
        compiler.reportError(node, MessageKind.CYCLIC_REDIRECTING_FACTORY);
        // TODO(johnniwinther): Create constant constructor for this case and
        // let evaluation detect the cyclicity.
        isValidAsConstant = false;
      }
    }

    // Check that the target constructor is type compatible with the
    // redirecting constructor.
    ClassElement targetClass = redirectionTarget.enclosingClass;
    InterfaceType type = registry.getType(node);
    FunctionType targetType = redirectionTarget.computeType(compiler)
        .subst(type.typeArguments, targetClass.typeVariables);
    FunctionType constructorType = constructor.computeType(compiler);
    bool isSubtype = compiler.types.isSubtype(targetType, constructorType);
    if (!isSubtype) {
      warning(node, MessageKind.NOT_ASSIGNABLE,
              {'fromType': targetType, 'toType': constructorType});
      // TODO(johnniwinther): Handle this (potentially) erroneous case.
      isValidAsConstant = false;
    }

    redirectionTarget.computeType(compiler);
    FunctionSignature targetSignature = redirectionTarget.functionSignature;
    constructor.computeType(compiler);
    FunctionSignature constructorSignature = constructor.functionSignature;
    if (!targetSignature.isCompatibleWith(constructorSignature)) {
      assert(!isSubtype);
      registry.registerThrowNoSuchMethod();
      isValidAsConstant = false;
    }

    // Register a post process to check for cycles in the redirection chain and
    // set the actual generative constructor at the end of the chain.
    addDeferredAction(constructor, () {
      compiler.resolver.resolveRedirectionChain(constructor, node);
    });

    registry.registerStaticUse(redirectionTarget);
    // TODO(johnniwinther): Register the effective target type instead.
    registry.registerInstantiatedClass(
        redirectionTarget.enclosingClass.declaration);
    if (isSymbolConstructor) {
      registry.registerSymbolConstructor();
    }
    if (isValidAsConstant) {
      List<String> names = <String>[];
      List<ConstantExpression> arguments = <ConstantExpression>[];
      int index = 0;
      constructorSignature.forEachParameter((ParameterElement parameter) {
        if (parameter.isNamed) {
          String name = parameter.name;
          names.add(name);
          arguments.add(new NamedArgumentReference(name));
        } else {
          arguments.add(new PositionalArgumentReference(index));
        }
        index++;
      });
      CallStructure callStructure =
          new CallStructure(constructorSignature.parameterCount, names);
      constructor.constantConstructor =
          new RedirectingFactoryConstantConstructor(
              new ConstructedConstantExpression(
                  type,
                  redirectionTarget,
                  callStructure,
                  arguments));
    }
    return const NoneResult();
  }

  ResolutionResult visitThrow(Throw node) {
    registry.registerThrowExpression();
    visit(node.expression);
    return const NoneResult();
  }

  ResolutionResult visitAwait(Await node) {
    compiler.futureClass.ensureResolved(compiler);
    visit(node.expression);
    return const NoneResult();
  }

  ResolutionResult visitVariableDefinitions(VariableDefinitions node) {
    DartType type;
    if (node.type != null) {
      type = resolveTypeAnnotation(node.type);
    } else {
      type = const DynamicType();
    }
    VariableList variables = new VariableList.node(node, type);
    VariableDefinitionsVisitor visitor =
        new VariableDefinitionsVisitor(compiler, node, this, variables);

    Modifiers modifiers = node.modifiers;
    void reportExtraModifier(String modifier) {
      Node modifierNode;
      for (Link<Node> nodes = modifiers.nodes.nodes;
           !nodes.isEmpty;
           nodes = nodes.tail) {
        if (modifier == nodes.head.asIdentifier().source) {
          modifierNode = nodes.head;
          break;
        }
      }
      assert(modifierNode != null);
      compiler.reportError(modifierNode, MessageKind.EXTRANEOUS_MODIFIER,
          {'modifier': modifier});
    }
    if (modifiers.isFinal && (modifiers.isConst || modifiers.isVar)) {
      reportExtraModifier('final');
    }
    if (modifiers.isVar && (modifiers.isConst || node.type != null)) {
      reportExtraModifier('var');
    }
    if (enclosingElement.isFunction) {
      if (modifiers.isAbstract) {
        reportExtraModifier('abstract');
      }
      if (modifiers.isStatic) {
        reportExtraModifier('static');
      }
    }
    if (node.metadata != null) {
      variables.metadata =
          compiler.resolver.resolveMetadata(enclosingElement, node);
    }
    visitor.visit(node.definitions);
    return const NoneResult();
  }

  ResolutionResult visitWhile(While node) {
    visit(node.condition);
    visitLoopBodyIn(node, node.body, new BlockScope(scope));
    return const NoneResult();
  }

  ResolutionResult visitParenthesizedExpression(ParenthesizedExpression node) {
    bool oldSendIsMemberAccess = sendIsMemberAccess;
    sendIsMemberAccess = false;
    var oldCategory = allowedCategory;
    allowedCategory =
        ElementCategory.VARIABLE |
        ElementCategory.FUNCTION |
        ElementCategory.IMPLIES_TYPE;
    ResolutionResult result = visit(node.expression);
    allowedCategory = oldCategory;
    sendIsMemberAccess = oldSendIsMemberAccess;
    if (result.kind == ResultKind.CONSTANT) {
      return result;
    }
    return const NoneResult();
  }

  ResolutionResult visitNewExpression(NewExpression node) {
    bool isValidAsConstant = true;
    FunctionElement constructor = resolveConstructor(node);
    final bool isSymbolConstructor = constructor == compiler.symbolConstructor;
    final bool isMirrorsUsedConstant =
        node.isConst && (constructor == compiler.mirrorsUsedConstructor);
    Selector callSelector = resolveSelector(node.send, constructor);
    ArgumentsResult argumentsResult;
    if (node.isConst) {
      argumentsResult =
          inConstantContext(() => resolveArguments(node.send.argumentsNode));
    } else {
      argumentsResult = resolveArguments(node.send.argumentsNode);
    }
    registry.useElement(node.send, constructor);
    if (Elements.isUnresolved(constructor)) {
      return new ResolutionResult.forElement(constructor);
    }
    constructor.computeType(compiler);
    if (!callSelector.applies(constructor, compiler.world)) {
      registry.registerThrowNoSuchMethod();
    }

    // [constructor] might be the implementation element
    // and only declaration elements may be registered.
    registry.registerStaticUse(constructor.declaration);
    ClassElement cls = constructor.enclosingClass;
    if (cls.isEnumClass && currentClass != cls) {
      compiler.reportError(node,
                           MessageKind.CANNOT_INSTANTIATE_ENUM,
                           {'enumName': cls.name});
      isValidAsConstant = false;
    }

    InterfaceType type = registry.getType(node);
    if (node.isConst && type.containsTypeVariables) {
      compiler.reportError(node.send.selector,
                           MessageKind.TYPE_VARIABLE_IN_CONSTANT);
      isValidAsConstant = false;
    }
    // TODO(johniwinther): Avoid registration of `type` in face of redirecting
    // factory constructors.
    registry.registerInstantiatedType(type);
    if (constructor.isGenerativeConstructor && cls.isAbstract) {
      warning(node, MessageKind.ABSTRACT_CLASS_INSTANTIATION);
      registry.registerAbstractClassInstantiation();
      isValidAsConstant = false;
    }

    if (isSymbolConstructor) {
      if (node.isConst) {
        Node argumentNode = node.send.arguments.head;
        ConstantExpression constant =
            compiler.resolver.constantCompiler.compileNode(
                argumentNode, registry.mapping);
        ConstantValue name = compiler.constants.getConstantValue(constant);
        if (!name.isString) {
          DartType type = name.getType(coreTypes);
          compiler.reportError(argumentNode, MessageKind.STRING_EXPECTED,
                                   {'type': type});
        } else {
          StringConstantValue stringConstant = name;
          String nameString = stringConstant.toDartString().slowToString();
          if (validateSymbol(argumentNode, nameString)) {
            registry.registerConstSymbol(nameString);
          }
        }
      } else {
        if (!compiler.mirrorUsageAnalyzerTask.hasMirrorUsage(
                enclosingElement)) {
          compiler.reportHint(
              node.newToken, MessageKind.NON_CONST_BLOAT,
              {'name': compiler.symbolClass.name});
        }
        registry.registerNewSymbol();
      }
    } else if (isMirrorsUsedConstant) {
      compiler.mirrorUsageAnalyzerTask.validate(node, registry.mapping);
    }
    if (node.isConst) {
      analyzeConstantDeferred(node);
      if (isValidAsConstant &&
          constructor.isConst &&
          argumentsResult.isValidAsConstant) {
        CallStructure callStructure = argumentsResult.callStructure;
        List<ConstantExpression> arguments = argumentsResult.constantArguments;
        ConstructedConstantExpression constant =
            new ConstructedConstantExpression(
                type,
                constructor,
                callStructure,
                arguments);
        return new ConstantResult(node, constant);
      }
    }

    return const NoneResult();
  }

  void checkConstMapKeysDontOverrideEquals(Spannable spannable,
                                           MapConstantValue map) {
    for (ConstantValue key in map.keys) {
      if (!key.isObject) continue;
      ObjectConstantValue objectConstant = key;
      DartType keyType = objectConstant.type;
      ClassElement cls = keyType.element;
      if (cls == compiler.stringClass) continue;
      Element equals = cls.lookupMember('==');
      if (equals.enclosingClass != compiler.objectClass) {
        compiler.reportError(spannable,
                             MessageKind.CONST_MAP_KEY_OVERRIDES_EQUALS,
                             {'type': keyType});
      }
    }
  }

  void analyzeConstant(Node node, {enforceConst: true}) {
    ConstantExpression constant =
        compiler.resolver.constantCompiler.compileNode(
            node, registry.mapping, enforceConst: enforceConst);

    if (constant == null) {
      assert(invariant(node, compiler.compilationFailed));
      return;
    }

    ConstantValue value = compiler.constants.getConstantValue(constant);
    if (value.isMap) {
      checkConstMapKeysDontOverrideEquals(node, value);
    }

    // The type constant that is an argument to JS_INTERCEPTOR_CONSTANT names
    // a class that will be instantiated outside the program by attaching a
    // native class dispatch record referencing the interceptor.
    if (argumentsToJsInterceptorConstant != null &&
        argumentsToJsInterceptorConstant.contains(node)) {
      if (value.isType) {
        TypeConstantValue typeConstant = value;
        if (typeConstant.representedType is InterfaceType) {
          registry.registerInstantiatedType(typeConstant.representedType);
        } else {
          compiler.reportError(node,
              MessageKind.WRONG_ARGUMENT_FOR_JS_INTERCEPTOR_CONSTANT);
        }
      } else {
        compiler.reportError(node,
            MessageKind.WRONG_ARGUMENT_FOR_JS_INTERCEPTOR_CONSTANT);
      }
    }
  }

  void analyzeConstantDeferred(Node node, {bool enforceConst: true}) {
    addDeferredAction(enclosingElement, () {
      analyzeConstant(node, enforceConst: enforceConst);
    });
  }

  bool validateSymbol(Node node, String name, {bool reportError: true}) {
    if (name.isEmpty) return true;
    if (name.startsWith('_')) {
      if (reportError) {
        compiler.reportError(node, MessageKind.PRIVATE_IDENTIFIER,
                             {'value': name});
      }
      return false;
    }
    if (!symbolValidationPattern.hasMatch(name)) {
      if (reportError) {
        compiler.reportError(node, MessageKind.INVALID_SYMBOL,
                             {'value': name});
      }
      return false;
    }
    return true;
  }

  /**
   * Try to resolve the constructor that is referred to by [node].
   * Note: this function may return an ErroneousFunctionElement instead of
   * [:null:], if there is no corresponding constructor, class or library.
   */
  ConstructorElement resolveConstructor(NewExpression node) {
    return node.accept(new ConstructorResolver(compiler, this));
  }

  ConstructorElement resolveRedirectingFactory(RedirectingFactoryBody node,
                                               {bool inConstContext: false}) {
    return node.accept(new ConstructorResolver(compiler, this,
                                               inConstContext: inConstContext));
  }

  DartType resolveTypeAnnotation(TypeAnnotation node,
                                 {bool malformedIsError: false,
                                  bool deferredIsMalformed: true}) {
    DartType type = typeResolver.resolveTypeAnnotation(
        this, node, malformedIsError: malformedIsError,
        deferredIsMalformed: deferredIsMalformed);
    if (inCheckContext) {
      registry.registerIsCheck(type);
      registry.registerRequiredType(type, enclosingElement);
    }
    return type;
  }

  ResolutionResult visitLiteralList(LiteralList node) {
    bool isValidAsConstant = true;
    sendIsMemberAccess = false;

    NodeList arguments = node.typeArguments;
    DartType typeArgument;
    if (arguments != null) {
      Link<Node> nodes = arguments.nodes;
      if (nodes.isEmpty) {
        // The syntax [: <>[] :] is not allowed.
        error(arguments, MessageKind.MISSING_TYPE_ARGUMENT);
        isValidAsConstant = false;
      } else {
        typeArgument = resolveTypeAnnotation(nodes.head);
        for (nodes = nodes.tail; !nodes.isEmpty; nodes = nodes.tail) {
          warning(nodes.head, MessageKind.ADDITIONAL_TYPE_ARGUMENT);
          resolveTypeAnnotation(nodes.head);
        }
      }
    }
    DartType listType;
    if (typeArgument != null) {
      if (node.isConst && typeArgument.containsTypeVariables) {
        compiler.reportError(arguments.nodes.head,
            MessageKind.TYPE_VARIABLE_IN_CONSTANT);
        isValidAsConstant = false;
      }
      listType = coreTypes.listType(typeArgument);
    } else {
      listType = coreTypes.listType();
    }
    registry.setType(node, listType);
    registry.registerInstantiatedType(listType);
    registry.registerRequiredType(listType, enclosingElement);
    if (node.isConst) {
      List<ConstantExpression> constantExpressions = <ConstantExpression>[];
      inConstantContext(() {
        for (Node element in node.elements) {
          ResolutionResult elementResult = visit(element);
          if (isValidAsConstant && elementResult.isConstant) {
            constantExpressions.add(elementResult.constant);
          } else {
            isValidAsConstant = false;
          }
        }
      });
      analyzeConstantDeferred(node);
      sendIsMemberAccess = false;
      if (isValidAsConstant) {
        ConstantExpression constant =
            new ListConstantExpression(listType, constantExpressions);
        registry.setConstant(node, constant);
        return new ConstantResult(node, constant);
      }
    } else {
      visit(node.elements);
      sendIsMemberAccess = false;
    }
    return const NoneResult();

  }

  ResolutionResult visitConditional(Conditional node) {
    ResolutionResult conditionResult =
        doInPromotionScope(node.condition, () => visit(node.condition));
    ResolutionResult thenResult =
        doInPromotionScope(node.thenExpression, () => visit(node.thenExpression));
    ResolutionResult elseResult = visit(node.elseExpression);
    if (conditionResult.isConstant &&
        thenResult.isConstant &&
        elseResult.isConstant) {
      ConstantExpression constant = new ConditionalConstantExpression(
          conditionResult.constant,
          thenResult.constant,
          elseResult.constant);
      registry.setConstant(node, constant);
      return new ConstantResult(node, constant);
    }
    return const NoneResult();
  }

  ResolutionResult visitStringInterpolation(StringInterpolation node) {
    registry.registerInstantiatedType(coreTypes.stringType);
    registry.registerStringInterpolation();
    registerImplicitInvocation('toString', 0);

    bool isValidAsConstant = true;
    List<ConstantExpression> parts = <ConstantExpression>[];

    void resolvePart(Node subnode) {
      ResolutionResult result = visit(subnode);
      if (isValidAsConstant && result.isConstant) {
        parts.add(result.constant);
      } else {
        isValidAsConstant = false;
      }
    }

    resolvePart(node.string);
    for (StringInterpolationPart part in node.parts) {
      resolvePart(part.expression);
      resolvePart(part.string);
    }

    if (isValidAsConstant) {
      ConstantExpression constant = new ConcatenateConstantExpression(parts);
      registry.setConstant(node, constant);
      return new ConstantResult(node, constant);
    }
    return const NoneResult();
  }

  ResolutionResult visitBreakStatement(BreakStatement node) {
    JumpTarget target;
    if (node.target == null) {
      target = statementScope.currentBreakTarget();
      if (target == null) {
        error(node, MessageKind.NO_BREAK_TARGET);
        return const NoneResult();
      }
      target.isBreakTarget = true;
    } else {
      String labelName = node.target.source;
      LabelDefinition label = statementScope.lookupLabel(labelName);
      if (label == null) {
        error(node.target, MessageKind.UNBOUND_LABEL, {'labelName': labelName});
        return const NoneResult();
      }
      target = label.target;
      if (!target.statement.isValidBreakTarget()) {
        error(node.target, MessageKind.INVALID_BREAK);
        return const NoneResult();
      }
      label.setBreakTarget();
      registry.useLabel(node, label);
    }
    registry.registerTargetOf(node, target);
    return const NoneResult();
  }

  ResolutionResult visitContinueStatement(ContinueStatement node) {
    JumpTarget target;
    if (node.target == null) {
      target = statementScope.currentContinueTarget();
      if (target == null) {
        error(node, MessageKind.NO_CONTINUE_TARGET);
        return const NoneResult();
      }
      target.isContinueTarget = true;
    } else {
      String labelName = node.target.source;
      LabelDefinition label = statementScope.lookupLabel(labelName);
      if (label == null) {
        error(node.target, MessageKind.UNBOUND_LABEL, {'labelName': labelName});
        return const NoneResult();
      }
      target = label.target;
      if (!target.statement.isValidContinueTarget()) {
        error(node.target, MessageKind.INVALID_CONTINUE);
      }
      label.setContinueTarget();
      registry.useLabel(node, label);
    }
    registry.registerTargetOf(node, target);
    return const NoneResult();
  }

  registerImplicitInvocation(String name, int arity) {
    Selector selector = new Selector.call(name, null, arity);
    registry.registerDynamicInvocation(new UniverseSelector(selector, null));
  }

  ResolutionResult visitAsyncForIn(AsyncForIn node) {
    registry.registerAsyncForIn(node);
    registry.setCurrentSelector(node, compiler.currentSelector);
    registry.registerDynamicGetter(
        new UniverseSelector(compiler.currentSelector, null));
    registry.setMoveNextSelector(node, compiler.moveNextSelector);
    registry.registerDynamicInvocation(
        new UniverseSelector(compiler.moveNextSelector, null));

    visit(node.expression);

    Scope blockScope = new BlockScope(scope);
    visitForInDeclaredIdentifierIn(node.declaredIdentifier, node, blockScope);
    visitLoopBodyIn(node, node.body, blockScope);
    return const NoneResult();
  }

  ResolutionResult visitSyncForIn(SyncForIn node) {
    registry.registerSyncForIn(node);
    registry.setIteratorSelector(node, compiler.iteratorSelector);
    registry.registerDynamicGetter(
        new UniverseSelector(compiler.iteratorSelector, null));
    registry.setCurrentSelector(node, compiler.currentSelector);
    registry.registerDynamicGetter(
        new UniverseSelector(compiler.currentSelector, null));
    registry.setMoveNextSelector(node, compiler.moveNextSelector);
    registry.registerDynamicInvocation(
        new UniverseSelector(compiler.moveNextSelector, null));

    visit(node.expression);

    Scope blockScope = new BlockScope(scope);
    visitForInDeclaredIdentifierIn(node.declaredIdentifier, node, blockScope);
    visitLoopBodyIn(node, node.body, blockScope);
    return const NoneResult();
  }

  void visitForInDeclaredIdentifierIn(
      Node declaration,
      ForIn node,
      Scope blockScope) {
    LibraryElement library = enclosingElement.library;

    bool oldAllowFinalWithoutInitializer = allowFinalWithoutInitializer;
    allowFinalWithoutInitializer = true;
    visitIn(declaration, blockScope);
    allowFinalWithoutInitializer = oldAllowFinalWithoutInitializer;

    Send send = declaration.asSend();
    VariableDefinitions variableDefinitions =
        declaration.asVariableDefinitions();
    Element loopVariable;
    Selector loopVariableSelector;
    if (send != null) {
      loopVariable = registry.getDefinition(send);
      Identifier identifier = send.selector.asIdentifier();
      if (identifier == null) {
        compiler.reportError(send.selector, MessageKind.INVALID_FOR_IN);
      } else {
        loopVariableSelector = new Selector.setter(identifier.source, library);
      }
      if (send.receiver != null) {
        compiler.reportError(send.receiver, MessageKind.INVALID_FOR_IN);
      }
    } else if (variableDefinitions != null) {
      Link<Node> nodes = variableDefinitions.definitions.nodes;
      if (!nodes.tail.isEmpty) {
        compiler.reportError(nodes.tail.head, MessageKind.INVALID_FOR_IN);
      }
      Node first = nodes.head;
      Identifier identifier = first.asIdentifier();
      if (identifier == null) {
        compiler.reportError(first, MessageKind.INVALID_FOR_IN);
      } else {
        loopVariableSelector = new Selector.setter(identifier.source, library);
        loopVariable = registry.getDefinition(identifier);
      }
    } else {
      compiler.reportError(declaration, MessageKind.INVALID_FOR_IN);
    }
    if (loopVariableSelector != null) {
      registry.setSelector(declaration, loopVariableSelector);
      registerSend(loopVariableSelector, loopVariable);
    } else {
      // The selector may only be null if we reported an error.
      assert(invariant(declaration, compiler.compilationFailed));
    }
    if (loopVariable != null) {
      // loopVariable may be null if it could not be resolved.
      registry.setForInVariable(node, loopVariable);
    }
  }

  visitLabel(Label node) {
    // Labels are handled by their containing statements/cases.
  }

  ResolutionResult visitLabeledStatement(LabeledStatement node) {
    Statement body = node.statement;
    JumpTarget targetElement = getOrDefineTarget(body);
    Map<String, LabelDefinition> labelElements = <String, LabelDefinition>{};
    for (Label label in node.labels) {
      String labelName = label.labelName;
      if (labelElements.containsKey(labelName)) continue;
      LabelDefinition element = targetElement.addLabel(label, labelName);
      labelElements[labelName] = element;
    }
    statementScope.enterLabelScope(labelElements);
    visit(node.statement);
    statementScope.exitLabelScope();
    labelElements.forEach((String labelName, LabelDefinition element) {
      if (element.isTarget) {
        registry.defineLabel(element.label, element);
      } else {
        warning(element.label, MessageKind.UNUSED_LABEL,
                {'labelName': labelName});
      }
    });
    if (!targetElement.isTarget) {
      registry.undefineTarget(body);
    }
    return const NoneResult();
  }

  ResolutionResult visitLiteralMap(LiteralMap node) {
    bool isValidAsConstant = true;
    sendIsMemberAccess = false;

    NodeList arguments = node.typeArguments;
    DartType keyTypeArgument;
    DartType valueTypeArgument;
    if (arguments != null) {
      Link<Node> nodes = arguments.nodes;
      if (nodes.isEmpty) {
        // The syntax [: <>{} :] is not allowed.
        error(arguments, MessageKind.MISSING_TYPE_ARGUMENT);
        isValidAsConstant = false;
      } else {
        keyTypeArgument = resolveTypeAnnotation(nodes.head);
        nodes = nodes.tail;
        if (nodes.isEmpty) {
          warning(arguments, MessageKind.MISSING_TYPE_ARGUMENT);
        } else {
          valueTypeArgument = resolveTypeAnnotation(nodes.head);
          for (nodes = nodes.tail; !nodes.isEmpty; nodes = nodes.tail) {
            warning(nodes.head, MessageKind.ADDITIONAL_TYPE_ARGUMENT);
            resolveTypeAnnotation(nodes.head);
          }
        }
      }
    }
    DartType mapType;
    if (valueTypeArgument != null) {
      mapType = coreTypes.mapType(keyTypeArgument, valueTypeArgument);
    } else {
      mapType = coreTypes.mapType();
    }
    if (node.isConst && mapType.containsTypeVariables) {
      compiler.reportError(arguments,
          MessageKind.TYPE_VARIABLE_IN_CONSTANT);
      isValidAsConstant = false;
    }
    registry.registerMapLiteral(node, mapType, node.isConst);
    registry.registerRequiredType(mapType, enclosingElement);
    if (node.isConst) {

      List<ConstantExpression> keyExpressions = <ConstantExpression>[];
      List<ConstantExpression> valueExpressions = <ConstantExpression>[];
      inConstantContext(() {
        for (LiteralMapEntry entry in node.entries) {
          ResolutionResult keyResult = visit(entry.key);
          ResolutionResult valueResult = visit(entry.value);
          if (isValidAsConstant &&
              keyResult.isConstant &&
              valueResult.isConstant) {
            keyExpressions.add(keyResult.constant);
            valueExpressions.add(valueResult.constant);
          } else {
            isValidAsConstant = false;
          }
        }
      });
      analyzeConstantDeferred(node);
      sendIsMemberAccess = false;
      if (isValidAsConstant) {
        ConstantExpression constant = new MapConstantExpression(
            mapType, keyExpressions, valueExpressions);
        registry.setConstant(node, constant);
        return new ConstantResult(node, constant);
      }
    } else {
      node.visitChildren(this);
      sendIsMemberAccess = false;
    }
    return const NoneResult();
  }

  ResolutionResult visitLiteralMapEntry(LiteralMapEntry node) {
    node.visitChildren(this);
    return const NoneResult();
  }

  ResolutionResult visitNamedArgument(NamedArgument node) {
    return visit(node.expression);
  }

  DartType typeOfConstant(ConstantValue constant) {
    if (constant.isInt) return compiler.intClass.rawType;
    if (constant.isBool) return compiler.boolClass.rawType;
    if (constant.isDouble) return compiler.doubleClass.rawType;
    if (constant.isString) return compiler.stringClass.rawType;
    if (constant.isNull) return compiler.nullClass.rawType;
    if (constant.isFunction) return compiler.functionClass.rawType;
    assert(constant.isObject);
    ObjectConstantValue objectConstant = constant;
    return objectConstant.type;
  }

  bool overridesEquals(DartType type) {
    ClassElement cls = type.element;
    Element equals = cls.lookupMember('==');
    return equals.enclosingClass != compiler.objectClass;
  }

  void checkCaseExpressions(SwitchStatement node) {
    CaseMatch firstCase = null;
    DartType firstCaseType = null;
    bool hasReportedProblem = false;

    for (Link<Node> cases = node.cases.nodes;
         !cases.isEmpty;
         cases = cases.tail) {
      SwitchCase switchCase = cases.head;

      for (Node labelOrCase in switchCase.labelsAndCases) {
        CaseMatch caseMatch = labelOrCase.asCaseMatch();
        if (caseMatch == null) continue;

        // Analyze the constant.
        ConstantExpression constant =
            registry.getConstant(caseMatch.expression);
        assert(invariant(node, constant != null,
            message: 'No constant computed for $node'));

        ConstantValue value = compiler.constants.getConstantValue(constant);
        DartType caseType = typeOfConstant(value);

        if (firstCaseType == null) {
          firstCase = caseMatch;
          firstCaseType = caseType;

          // We only report the bad type on the first class element. All others
          // get a "type differs" error.
          if (caseType.element == compiler.doubleClass) {
            compiler.reportError(node,
                                 MessageKind.SWITCH_CASE_VALUE_OVERRIDES_EQUALS,
                                 {'type': "double"});
          } else if (caseType.element == compiler.functionClass) {
            compiler.reportError(node, MessageKind.SWITCH_CASE_FORBIDDEN,
                                 {'type': "Function"});
          } else if (value.isObject && overridesEquals(caseType)) {
            compiler.reportError(firstCase.expression,
                MessageKind.SWITCH_CASE_VALUE_OVERRIDES_EQUALS,
                {'type': caseType});
          }
        } else {
          if (caseType != firstCaseType) {
            if (!hasReportedProblem) {
              compiler.reportError(
                  node,
                  MessageKind.SWITCH_CASE_TYPES_NOT_EQUAL,
                  {'type': firstCaseType});
              compiler.reportInfo(
                  firstCase.expression,
                  MessageKind.SWITCH_CASE_TYPES_NOT_EQUAL_CASE,
                  {'type': firstCaseType});
              hasReportedProblem = true;
            }
            compiler.reportInfo(
                caseMatch.expression,
                MessageKind.SWITCH_CASE_TYPES_NOT_EQUAL_CASE,
                {'type': caseType});
          }
        }
      }
    }
  }

  ResolutionResult visitSwitchStatement(SwitchStatement node) {
    node.expression.accept(this);

    JumpTarget breakElement = getOrDefineTarget(node);
    Map<String, LabelDefinition> continueLabels = <String, LabelDefinition>{};
    Link<Node> cases = node.cases.nodes;
    while (!cases.isEmpty) {
      SwitchCase switchCase = cases.head;
      for (Node labelOrCase in switchCase.labelsAndCases) {
        CaseMatch caseMatch = labelOrCase.asCaseMatch();
        if (caseMatch != null) {
          analyzeConstantDeferred(caseMatch.expression);
          continue;
        }
        Label label = labelOrCase;
        String labelName = label.labelName;

        LabelDefinition existingElement = continueLabels[labelName];
        if (existingElement != null) {
          // It's an error if the same label occurs twice in the same switch.
          compiler.reportError(
              label,
              MessageKind.DUPLICATE_LABEL, {'labelName': labelName});
          compiler.reportInfo(
              existingElement.label,
              MessageKind.EXISTING_LABEL, {'labelName': labelName});
        } else {
          // It's only a warning if it shadows another label.
          existingElement = statementScope.lookupLabel(labelName);
          if (existingElement != null) {
            compiler.reportWarning(
                label,
                MessageKind.DUPLICATE_LABEL, {'labelName': labelName});
            compiler.reportInfo(
                existingElement.label,
                MessageKind.EXISTING_LABEL, {'labelName': labelName});
          }
        }

        JumpTarget targetElement = getOrDefineTarget(switchCase);
        LabelDefinition labelElement = targetElement.addLabel(label, labelName);
        registry.defineLabel(label, labelElement);
        continueLabels[labelName] = labelElement;
      }
      cases = cases.tail;
      // Test that only the last case, if any, is a default case.
      if (switchCase.defaultKeyword != null && !cases.isEmpty) {
        error(switchCase, MessageKind.INVALID_CASE_DEFAULT);
      }
    }

    addDeferredAction(enclosingElement, () {
      checkCaseExpressions(node);
    });

    statementScope.enterSwitch(breakElement, continueLabels);
    node.cases.accept(this);
    statementScope.exitSwitch();

    // Clean-up unused labels.
    continueLabels.forEach((String key, LabelDefinition label) {
      if (!label.isContinueTarget) {
        JumpTarget targetElement = label.target;
        SwitchCase switchCase = targetElement.statement;
        registry.undefineTarget(switchCase);
        registry.undefineLabel(label.label);
      }
    });
    // TODO(15575): We should warn if we can detect a fall through
    // error.
    registry.registerFallThroughError();
    return const NoneResult();
  }

  ResolutionResult visitSwitchCase(SwitchCase node) {
    node.labelsAndCases.accept(this);
    visitIn(node.statements, new BlockScope(scope));
    return const NoneResult();
  }

  ResolutionResult visitCaseMatch(CaseMatch node) {
    visit(node.expression);
    return const NoneResult();
  }

  ResolutionResult visitTryStatement(TryStatement node) {
    visit(node.tryBlock);
    if (node.catchBlocks.isEmpty && node.finallyBlock == null) {
      error(node.getEndToken().next, MessageKind.NO_CATCH_NOR_FINALLY);
    }
    visit(node.catchBlocks);
    visit(node.finallyBlock);
    return const NoneResult();
  }

  ResolutionResult visitCatchBlock(CatchBlock node) {
    registry.registerCatchStatement();
    // Check that if catch part is present, then
    // it has one or two formal parameters.
    VariableDefinitions exceptionDefinition;
    VariableDefinitions stackTraceDefinition;
    if (node.formals != null) {
      Link<Node> formalsToProcess = node.formals.nodes;
      if (formalsToProcess.isEmpty) {
        error(node, MessageKind.EMPTY_CATCH_DECLARATION);
      } else {
        exceptionDefinition = formalsToProcess.head.asVariableDefinitions();
        formalsToProcess = formalsToProcess.tail;
        if (!formalsToProcess.isEmpty) {
          stackTraceDefinition = formalsToProcess.head.asVariableDefinitions();
          formalsToProcess = formalsToProcess.tail;
          if (!formalsToProcess.isEmpty) {
            for (Node extra in formalsToProcess) {
              error(extra, MessageKind.EXTRA_CATCH_DECLARATION);
            }
          }
          registry.registerStackTraceInCatch();
        }
      }

      // Check that the formals aren't optional and that they have no
      // modifiers or type.
      for (Link<Node> link = node.formals.nodes;
           !link.isEmpty;
           link = link.tail) {
        // If the formal parameter is a node list, it means that it is a
        // sequence of optional parameters.
        NodeList nodeList = link.head.asNodeList();
        if (nodeList != null) {
          error(nodeList, MessageKind.OPTIONAL_PARAMETER_IN_CATCH);
        } else {
          VariableDefinitions declaration = link.head;
          for (Node modifier in declaration.modifiers.nodes) {
            error(modifier, MessageKind.PARAMETER_WITH_MODIFIER_IN_CATCH);
          }
          TypeAnnotation type = declaration.type;
          if (type != null) {
            error(type, MessageKind.PARAMETER_WITH_TYPE_IN_CATCH);
          }
        }
      }
    }

    Scope blockScope = new BlockScope(scope);
    doInCheckContext(() => visitIn(node.type, blockScope));
    visitIn(node.formals, blockScope);
    var oldInCatchBlock = inCatchBlock;
    inCatchBlock = true;
    visitIn(node.block, blockScope);
    inCatchBlock = oldInCatchBlock;

    if (node.type != null && exceptionDefinition != null) {
      DartType exceptionType = registry.getType(node.type);
      Node exceptionVariable = exceptionDefinition.definitions.nodes.head;
      VariableElementX exceptionElement =
          registry.getDefinition(exceptionVariable);
      exceptionElement.variables.type = exceptionType;
    }
    if (stackTraceDefinition != null) {
      Node stackTraceVariable = stackTraceDefinition.definitions.nodes.head;
      VariableElementX stackTraceElement =
          registry.getDefinition(stackTraceVariable);
      registry.registerInstantiatedClass(compiler.stackTraceClass);
      stackTraceElement.variables.type = compiler.stackTraceClass.rawType;
    }
    return const NoneResult();
  }
}

/// Looks up [name] in [scope] and unwraps the result.
Element lookupInScope(Compiler compiler, Node node,
                      Scope scope, String name) {
  return Elements.unwrap(scope.lookup(name), compiler, node);
}
