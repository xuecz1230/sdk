// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dart2js.semantics_visitor;

import '../constants/expressions.dart';
import '../dart2jslib.dart' show invariant, MessageKind;
import '../dart_types.dart';
import '../elements/elements.dart';
import '../tree/tree.dart';
import '../universe/universe.dart';
import '../util/util.dart' show Spannable, SpannableAssertionFailure;
import 'access_semantics.dart';
import 'operators.dart';
import 'resolution.dart';
import 'send_structure.dart';

part 'semantic_visitor_mixins.dart';
part 'send_resolver.dart';

/// Mixin that couples a [SendResolverMixin] to a [SemanticSendVisitor] in a
/// [Visitor].
abstract class SemanticSendResolvedMixin<R, A>
    implements Visitor<R>, SendResolverMixin {

  SemanticSendVisitor<R, A> get sendVisitor;

  @override
  R visitIdentifier(Identifier node) {
    // TODO(johnniwinther): Support argument.
    A arg = null;
    if (node.isThis()) {
      // TODO(johnniwinther): Parse `this` as a [Send] whose selector is `this`
      // to normalize with `this(...)`.
      return sendVisitor.visitThisGet(node, arg);
    }
    return null;
  }

  @override
  R visitSend(Send node) {
    // TODO(johnniwinther): Support argument.
    A arg = null;

    SendStructure structure = computeSendStructure(node);
    if (structure == null) {
      return internalError(node, 'No structure for $node');
    } else {
      return structure.dispatch(sendVisitor, node, arg);
    }
  }

  @override
  R visitSendSet(SendSet node) {
    return visitSend(node);
  }

  @override
  R visitNewExpression(NewExpression node) {
    // TODO(johnniwinther): Support argument.
    A arg = null;

    NewStructure structure = computeNewStructure(node);
    if (structure == null) {
      return internalError(node, 'No structure for $node');
    } else {
      return structure.dispatch(sendVisitor, node, arg);
    }
  }
}

/// Mixin that couples a [DeclarationResolverMixin] to a
/// [SemanticDeclarationVisitor] in a [Visitor].
abstract class SemanticDeclarationResolvedMixin<R, A>
    implements Visitor<R>, DeclarationResolverMixin {

  SemanticDeclarationVisitor<R, A> get declVisitor;

  @override
  R visitFunctionExpression(FunctionExpression node) {
    // TODO(johnniwinther): Support argument.
    A arg = null;

    DeclStructure structure = computeFunctionStructure(node);
    if (structure == null) {
      return internalError(node, 'No structure for $node');
    } else {
      return structure.dispatch(declVisitor, node, arg);
    }
  }

  visitInitializers(FunctionExpression function, A arg) {
    InitializersStructure initializers = computeInitializersStructure(function);
    for (InitializerStructure structure in initializers.initializers) {
      structure.dispatch(declVisitor, arg);
    }
  }

  visitParameters(NodeList parameters, A arg) {
    List<ParameterStructure> structures =
        computeParameterStructures(parameters);
    for (ParameterStructure structure in structures) {
      structure.dispatch(declVisitor, arg);
    }
  }

  @override
  R visitVariableDefinitions(VariableDefinitions definitions) {
    // TODO(johnniwinther): Support argument.
    A arg = null;

    computeVariableStructures(
        definitions,
        (Node node, VariableStructure structure) {
      if (structure == null) {
        return internalError(node, 'No structure for $node');
      } else {
        return structure.dispatch(declVisitor, node, arg);
      }
    });
    return null;
  }
}

abstract class SemanticVisitor<R, A> extends Visitor<R>
    with SemanticSendResolvedMixin<R, A>,
         SendResolverMixin,
         SemanticDeclarationResolvedMixin<R, A>,
         DeclarationResolverMixin {
  TreeElements elements;

  SemanticVisitor(this.elements);
}

// TODO(johnniwinther): Add visits for [visitLocalConstantGet],
// [visitLocalConstantInvoke], [visitStaticConstantGet], etc.
abstract class SemanticSendVisitor<R, A> {
  R apply(Node node, A arg);

  /// Read of the [parameter].
  ///
  /// For instance:
  ///     m(parameter) => parameter;
  ///
  R visitParameterGet(
      Send node,
      ParameterElement parameter,
      A arg);

  /// Assignment of [rhs] to the [parameter].
  ///
  /// For instance:
  ///     m(parameter) {
  ///       parameter = rhs;
  ///     }
  ///
  R visitParameterSet(
      SendSet node,
      ParameterElement parameter,
      Node rhs,
      A arg);

  /// Assignment of [rhs] to the final [parameter].
  ///
  /// For instance:
  ///     m(final parameter) {
  ///       parameter = rhs;
  ///     }
  ///
  R visitFinalParameterSet(
      SendSet node,
      ParameterElement parameter,
      Node rhs,
      A arg);

  /// Invocation of the [parameter] with [arguments].
  ///
  /// For instance:
  ///     m(parameter) {
  ///       parameter(null, 42);
  ///     }
  ///
  R visitParameterInvoke(
      Send node,
      ParameterElement parameter,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Read of the local [variable].
  ///
  /// For instance:
  ///     m() {
  ///       var variable;
  ///       return variable;
  ///     }
  ///
  R visitLocalVariableGet(
      Send node,
      LocalVariableElement variable,
      A arg);

  /// Assignment of [rhs] to the local [variable].
  ///
  /// For instance:
  ///     m() {
  ///       var variable;
  ///       variable = rhs;
  ///     }
  ///
  R visitLocalVariableSet(
      SendSet node,
      LocalVariableElement variable,
      Node rhs,
      A arg);

  /// Assignment of [rhs] to the final local [variable].
  ///
  /// For instance:
  ///     m() {
  ///       final variable = null;
  ///       variable = rhs;
  ///     }
  ///
  R visitFinalLocalVariableSet(
      SendSet node,
      LocalVariableElement variable,
      Node rhs,
      A arg);

  /// Invocation of the local variable [variable] with [arguments].
  ///
  /// For instance:
  ///     m() {
  ///       var variable;
  ///       variable(null, 42);
  ///     }
  ///
  R visitLocalVariableInvoke(
      Send node,
      LocalVariableElement variable,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Closurization of the local [function].
  ///
  /// For instance:
  ///     m() {
  ///       o(a, b) {}
  ///       return o;
  ///     }
  ///
  R visitLocalFunctionGet(
      Send node,
      LocalFunctionElement function,
      A arg);

  /// Assignment of [rhs] to the local [function].
  ///
  /// For instance:
  ///     m() {
  ///       o(a, b) {}
  ///       o = rhs;
  ///     }
  ///
  R visitLocalFunctionSet(
      SendSet node,
      LocalFunctionElement function,
      Node rhs,
      A arg);

  /// Invocation of the local [function] with [arguments].
  ///
  /// For instance:
  ///     m() {
  ///       o(a, b) {}
  ///       return o(null, 42);
  ///     }
  ///
  R visitLocalFunctionInvoke(
      Send node,
      LocalFunctionElement function,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of the local [function] with incompatible [arguments].
  ///
  /// For instance:
  ///     m() {
  ///       o(a) {}
  ///       return o(null, 42);
  ///     }
  ///
  R visitLocalFunctionIncompatibleInvoke(
      Send node,
      LocalFunctionElement function,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Getter call on [receiver] of the property defined by [selector].
  ///
  /// For instance
  ///     m(receiver) => receiver.foo;
  ///
  R visitDynamicPropertyGet(
      Send node,
      Node receiver,
      Selector selector,
      A arg);

  /// Conditional (if not null) getter call on [receiver] of the property
  /// defined by [selector].
  ///
  /// For instance
  ///     m(receiver) => receiver?.foo;
  ///
  R visitIfNotNullDynamicPropertyGet(
      Send node,
      Node receiver,
      Selector selector,
      A arg);

  /// Setter call on [receiver] with argument [rhs] of the property defined by
  /// [selector].
  ///
  /// For instance
  ///     m(receiver) {
  ///       receiver.foo = rhs;
  ///     }
  ///
  R visitDynamicPropertySet(
      SendSet node,
      Node receiver,
      Selector selector,
      Node rhs,
      A arg);

  /// Conditional (if not null) setter call on [receiver] with argument [rhs] of
  /// the property defined by [selector].
  ///
  /// For instance
  ///     m(receiver) {
  ///       receiver?.foo = rhs;
  ///     }
  ///
  R visitIfNotNullDynamicPropertySet(
      SendSet node,
      Node receiver,
      Selector selector,
      Node rhs,
      A arg);

  /// Invocation of the property defined by [selector] on [receiver] with
  /// [arguments].
  ///
  /// For instance
  ///     m(receiver) {
  ///       receiver.foo(null, 42);
  ///     }
  ///
  R visitDynamicPropertyInvoke(
      Send node,
      Node receiver,
      NodeList arguments,
      Selector selector,
      A arg);

  /// Conditinal invocation of the property defined by [selector] on [receiver]
  /// with [arguments], if [receiver] is not null.
  ///
  /// For instance
  ///     m(receiver) {
  ///       receiver?.foo(null, 42);
  ///     }
  ///
  R visitIfNotNullDynamicPropertyInvoke(
      Send node,
      Node receiver,
      NodeList arguments,
      Selector selector,
      A arg);

  /// Getter call on `this` of the property defined by [selector].
  ///
  /// For instance
  ///     class C {
  ///       m() => this.foo;
  ///     }
  ///
  /// or
  ///
  ///     class C {
  ///       m() => foo;
  ///     }
  ///
  R visitThisPropertyGet(
      Send node,
      Selector selector,
      A arg);

  /// Setter call on `this` with argument [rhs] of the property defined by
  /// [selector].
  ///     class C {
  ///       m() { this.foo = rhs; }
  ///     }
  ///
  /// or
  ///
  ///     class C {
  ///       m() { foo = rhs; }
  ///     }
  ///
  R visitThisPropertySet(
      SendSet node,
      Selector selector,
      Node rhs,
      A arg);

  /// Invocation of the property defined by [selector] on `this` with
  /// [arguments].
  ///
  /// For instance
  ///     class C {
  ///       m() { this.foo(null, 42); }
  ///     }
  ///
  /// or
  ///
  ///     class C {
  ///       m() { foo(null, 42); }
  ///     }
  ///
  ///
  R visitThisPropertyInvoke(
      Send node,
      NodeList arguments,
      Selector selector,
      A arg);

  /// Read of `this`.
  ///
  /// For instance
  ///     class C {
  ///       m() => this;
  ///     }
  ///
  R visitThisGet(
      Identifier node,
      A arg);

  /// Invocation of `this` with [arguments].
  ///
  /// For instance
  ///     class C {
  ///       m() => this(null, 42);
  ///     }
  ///
  R visitThisInvoke(
      Send node,
      NodeList arguments,
      CallStructure callStructure,
      A arg);


  /// Read of the super [field].
  ///
  /// For instance
  ///     class B {
  ///       var foo;
  ///     }
  ///     class C extends B {
  ///        m() => super.foo;
  ///     }
  ///
  R visitSuperFieldGet(
      Send node,
      FieldElement field,
      A arg);

  /// Assignment of [rhs] to the super [field].
  ///
  /// For instance
  ///     class B {
  ///       var foo;
  ///     }
  ///     class C extends B {
  ///        m() { super.foo = rhs; }
  ///     }
  ///
  R visitSuperFieldSet(
      SendSet node,
      FieldElement field,
      Node rhs,
      A arg);

  /// Assignment of [rhs] to the final static [field].
  ///
  /// For instance
  ///     class B {
  ///       final foo = null;
  ///     }
  ///     class C extends B {
  ///        m() { super.foo = rhs; }
  ///     }
  ///
  R visitFinalSuperFieldSet(
      SendSet node,
      FieldElement field,
      Node rhs,
      A arg);

  /// Invocation of the super [field] with [arguments].
  ///
  /// For instance
  ///     class B {
  ///       var foo;
  ///     }
  ///     class C extends B {
  ///        m() { super.foo(null, 42); }
  ///     }
  ///
  R visitSuperFieldInvoke(
      Send node,
      FieldElement field,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Closurization of the super [method].
  ///
  /// For instance
  ///     class B {
  ///       foo(a, b) {}
  ///     }
  ///     class C extends B {
  ///        m() => super.foo;
  ///     }
  ///
  R visitSuperMethodGet(
      Send node,
      MethodElement method,
      A arg);

  /// Invocation of the super [method] with [arguments].
  ///
  /// For instance
  ///     class B {
  ///       foo(a, b) {}
  ///     }
  ///     class C extends B {
  ///        m() { super.foo(null, 42); }
  ///     }
  ///
  R visitSuperMethodInvoke(
      Send node,
      MethodElement method,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of the super [method] with incompatible [arguments].
  ///
  /// For instance
  ///     class B {
  ///       foo(a, b) {}
  ///     }
  ///     class C extends B {
  ///        m() { super.foo(null); } // One argument missing.
  ///     }
  ///
  R visitSuperMethodIncompatibleInvoke(
      Send node,
      MethodElement method,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Assignment of [rhs] to the super [method].
  ///
  /// For instance
  ///     class B {
  ///       foo(a, b) {}
  ///     }
  ///     class C extends B {
  ///        m() { super.foo = rhs; }
  ///     }
  ///
  R visitSuperMethodSet(
      Send node,
      MethodElement method,
      Node rhs,
      A arg);

  /// Getter call to the super [getter].
  ///
  /// For instance
  ///     class B {
  ///       get foo => null;
  ///     }
  ///     class C extends B {
  ///        m() => super.foo;
  ///     }
  ///
  R visitSuperGetterGet(
      Send node,
      FunctionElement getter,
      A arg);

  /// Getter call the super [setter].
  ///
  /// For instance
  ///     class B {
  ///       set foo(_) {}
  ///     }
  ///     class C extends B {
  ///        m() => super.foo;
  ///     }
  ///
  R visitSuperSetterGet(
      Send node,
      FunctionElement setter,
      A arg);

  /// Setter call to the super [setter].
  ///
  /// For instance
  ///     class B {
  ///       set foo(_) {}
  ///     }
  ///     class C extends B {
  ///        m() { super.foo = rhs; }
  ///     }
  ///
  R visitSuperSetterSet(
      SendSet node,
      FunctionElement setter,
      Node rhs,
      A arg);

  /// Assignment of [rhs] to the super [getter].
  ///
  /// For instance
  ///     class B {
  ///       get foo => null;
  ///     }
  ///     class C extends B {
  ///        m() { super.foo = rhs; }
  ///     }
  ///
  R visitSuperGetterSet(
      SendSet node,
      FunctionElement getter,
      Node rhs,
      A arg);

  /// Invocation of the super [getter] with [arguments].
  ///
  /// For instance
  ///     class B {
  ///       get foo => null;
  ///     }
  ///     class C extends B {
  ///        m() { super.foo(null, 42; }
  ///     }
  ///
  R visitSuperGetterInvoke(
      Send node,
      FunctionElement getter,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of the super [setter] with [arguments].
  ///
  /// For instance
  ///     class B {
  ///       set foo(_) {}
  ///     }
  ///     class C extends B {
  ///        m() { super.foo(null, 42; }
  ///     }
  ///
  R visitSuperSetterInvoke(
      Send node,
      FunctionElement setter,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of a [expression] with [arguments].
  ///
  /// For instance
  ///     m() => (a, b){}(null, 42);
  ///
  R visitExpressionInvoke(
      Send node,
      Node expression,
      NodeList arguments,
      Selector selector,
      A arg);

  /// Read of the static [field].
  ///
  /// For instance
  ///     class C {
  ///       static var foo;
  ///     }
  ///     m() => C.foo;
  ///
  R visitStaticFieldGet(
      Send node,
      FieldElement field,
      A arg);

  /// Assignment of [rhs] to the static [field].
  ///
  /// For instance
  ///     class C {
  ///       static var foo;
  ///     }
  ///     m() { C.foo = rhs; }
  ///
  R visitStaticFieldSet(
      SendSet node,
      FieldElement field,
      Node rhs,
      A arg);

  /// Assignment of [rhs] to the final static [field].
  ///
  /// For instance
  ///     class C {
  ///       static final foo;
  ///     }
  ///     m() { C.foo = rhs; }
  ///
  R visitFinalStaticFieldSet(
      SendSet node,
      FieldElement field,
      Node rhs,
      A arg);

  /// Invocation of the static [field] with [arguments].
  ///
  /// For instance
  ///     class C {
  ///       static var foo;
  ///     }
  ///     m() { C.foo(null, 42); }
  ///
  R visitStaticFieldInvoke(
      Send node,
      FieldElement field,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Closurization of the static [function].
  ///
  /// For instance
  ///     class C {
  ///       static foo(a, b) {}
  ///     }
  ///     m() => C.foo;
  ///
  R visitStaticFunctionGet(
      Send node,
      MethodElement function,
      A arg);

  /// Invocation of the static [function] with [arguments].
  ///
  /// For instance
  ///     class C {
  ///       static foo(a, b) {}
  ///     }
  ///     m() { C.foo(null, 42); }
  ///
  R visitStaticFunctionInvoke(
      Send node,
      MethodElement function,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of the static [function] with incompatible [arguments].
  ///
  /// For instance
  ///     class C {
  ///       static foo(a, b) {}
  ///     }
  ///     m() { C.foo(null); }
  ///
  R visitStaticFunctionIncompatibleInvoke(
      Send node,
      MethodElement function,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Assignment of [rhs] to the static [function].
  ///
  /// For instance
  ///     class C {
  ///       static foo(a, b) {}
  ///     }
  ///     m() { C.foo = rhs; }
  ///
  R visitStaticFunctionSet(
      Send node,
      MethodElement function,
      Node rhs,
      A arg);

  /// Getter call to the static [getter].
  ///
  /// For instance
  ///     class C {
  ///       static get foo => null;
  ///     }
  ///     m() => C.foo;
  ///
  R visitStaticGetterGet(
      Send node,
      FunctionElement getter,
      A arg);

  /// Getter call the static [setter].
  ///
  /// For instance
  ///     class C {
  ///       static set foo(_) {}
  ///     }
  ///     m() => C.foo;
  ///
  R visitStaticSetterGet(
      Send node,
      FunctionElement setter,
      A arg);

  /// Setter call to the static [setter].
  ///
  /// For instance
  ///     class C {
  ///       static set foo(_) {}
  ///     }
  ///     m() { C.foo = rhs; }
  ///
  R visitStaticSetterSet(
      SendSet node,
      FunctionElement setter,
      Node rhs,
      A arg);

  /// Assignment of [rhs] to the static [getter].
  ///
  /// For instance
  ///     class C {
  ///       static get foo => null;
  ///     }
  ///     m() { C.foo = rhs; }
  ///
  R visitStaticGetterSet(
      SendSet node,
      FunctionElement getter,
      Node rhs,
      A arg);

  /// Invocation of the static [getter] with [arguments].
  ///
  /// For instance
  ///     class C {
  ///       static get foo => null;
  ///     }
  ///     m() { C.foo(null, 42; }
  ///
  R visitStaticGetterInvoke(
      Send node,
      FunctionElement getter,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of the static [setter] with [arguments].
  ///
  /// For instance
  ///     class C {
  ///       static set foo(_) {}
  ///     }
  ///     m() { C.foo(null, 42; }
  ///
  R visitStaticSetterInvoke(
      Send node,
      FunctionElement setter,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Read of the top level [field].
  ///
  /// For instance
  ///     var foo;
  ///     m() => foo;
  ///
  R visitTopLevelFieldGet(
      Send node,
      FieldElement field,
      A arg);

  /// Assignment of [rhs] to the top level [field].
  ///
  /// For instance
  ///     var foo;
  ///     m() { foo = rhs; }
  ///
  R visitTopLevelFieldSet(
      SendSet node,
      FieldElement field,
      Node rhs,
      A arg);

  /// Assignment of [rhs] to the final top level [field].
  ///
  /// For instance
  ///     final foo = null;
  ///     m() { foo = rhs; }
  ///
  R visitFinalTopLevelFieldSet(
      SendSet node,
      FieldElement field,
      Node rhs,
      A arg);

  /// Invocation of the top level [field] with [arguments].
  ///
  /// For instance
  ///     var foo;
  ///     m() { foo(null, 42); }
  ///
  R visitTopLevelFieldInvoke(
      Send node,
      FieldElement field,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Closurization of the top level [function].
  ///
  /// For instance
  ///     foo(a, b) {};
  ///     m() => foo;
  ///
  R visitTopLevelFunctionGet(
      Send node,
      MethodElement function,
      A arg);

  /// Invocation of the top level [function] with [arguments].
  ///
  /// For instance
  ///     foo(a, b) {};
  ///     m() { foo(null, 42); }
  ///
  R visitTopLevelFunctionInvoke(
      Send node,
      MethodElement function,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of the top level [function] with incompatible [arguments].
  ///
  /// For instance
  ///     class C {
  ///       static foo(a, b) {}
  ///     }
  ///     m() { C.foo(null); }
  ///
  R visitTopLevelFunctionIncompatibleInvoke(
      Send node,
      MethodElement function,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Assignment of [rhs] to the top level [function].
  ///
  /// For instance
  ///     foo(a, b) {};
  ///     m() { foo = rhs; }
  ///
  R visitTopLevelFunctionSet(
      Send node,
      MethodElement function,
      Node rhs,
      A arg);

  /// Getter call to the top level [getter].
  ///
  /// For instance
  ///     get foo => null;
  ///     m() => foo;
  ///
  R visitTopLevelGetterGet(
      Send node,
      FunctionElement getter,
      A arg);

  /// Getter call the top level [setter].
  ///
  /// For instance
  ///     set foo(_) {}
  ///     m() => foo;
  ///
  R visitTopLevelSetterGet(
      Send node,
      FunctionElement setter,
      A arg);

  /// Setter call to the top level [setter].
  ///
  /// For instance
  ///     set foo(_) {}
  ///     m() { foo = rhs; }
  ///
  R visitTopLevelSetterSet(
      SendSet node,
      FunctionElement setter,
      Node rhs,
      A arg);

  /// Assignment of [rhs] to the top level [getter].
  ///
  /// For instance
  ///     get foo => null;
  ///     m() { foo = rhs; }
  ///
  R visitTopLevelGetterSet(
      SendSet node,
      FunctionElement getter,
      Node rhs,
      A arg);

  /// Invocation of the top level [getter] with [arguments].
  ///
  /// For instance
  ///     get foo => null;
  ///     m() { foo(null, 42); }
  ///
  R visitTopLevelGetterInvoke(
      Send node,
      FunctionElement getter,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of the top level [setter] with [arguments].
  ///
  /// For instance
  ///     set foo(_) {};
  ///     m() { foo(null, 42); }
  ///
  R visitTopLevelSetterInvoke(
      Send node,
      FunctionElement setter,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Read of the type literal for class [element].
  ///
  /// For instance
  ///     class C {}
  ///     m() => C;
  ///
  R visitClassTypeLiteralGet(
      Send node,
      ConstantExpression constant,
      A arg);

  /// Invocation of the type literal for class [element] with [arguments].
  ///
  /// For instance
  ///     class C {}
  ///     m() => C(null, 42);
  ///
  R visitClassTypeLiteralInvoke(
      Send node,
      ConstantExpression constant,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Assignment of [rhs] to the type literal for class [element].
  ///
  /// For instance
  ///     class C {}
  ///     m() { C = rhs; }
  ///
  R visitClassTypeLiteralSet(
      SendSet node,
      ConstantExpression constant,
      Node rhs,
      A arg);

  /// Read of the type literal for typedef [element].
  ///
  /// For instance
  ///     typedef F();
  ///     m() => F;
  ///
  R visitTypedefTypeLiteralGet(
      Send node,
      ConstantExpression constant,
      A arg);

  /// Invocation of the type literal for typedef [element] with [arguments].
  ///
  /// For instance
  ///     typedef F();
  ///     m() => F(null, 42);
  ///
  R visitTypedefTypeLiteralInvoke(
      Send node,
      ConstantExpression constant,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Assignment of [rhs] to the type literal for typedef [element].
  ///
  /// For instance
  ///     typedef F();
  ///     m() { F = rhs; }
  ///
  R visitTypedefTypeLiteralSet(
      SendSet node,
      ConstantExpression constant,
      Node rhs,
      A arg);

  /// Read of the type literal for type variable [element].
  ///
  /// For instance
  ///     class C<T> {
  ///       m() => T;
  ///     }
  ///
  R visitTypeVariableTypeLiteralGet(
      Send node,
      TypeVariableElement element,
      A arg);

  /// Invocation of the type literal for type variable [element] with
  /// [arguments].
  ///
  /// For instance
  ///     class C<T> {
  ///       m() { T(null, 42); }
  ///     }
  ///
  R visitTypeVariableTypeLiteralInvoke(
      Send node,
      TypeVariableElement element,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Assignment of [rhs] to the type literal for type variable [element].
  ///
  /// For instance
  ///     class C<T> {
  ///       m() { T = rhs; }
  ///     }
  ///
  R visitTypeVariableTypeLiteralSet(
      SendSet node,
      TypeVariableElement element,
      Node rhs,
      A arg);

  /// Read of the type literal for `dynamic`.
  ///
  /// For instance
  ///     m() => dynamic;
  ///
  R visitDynamicTypeLiteralGet(
      Send node,
      ConstantExpression constant,
      A arg);

  /// Invocation of the type literal for `dynamic` with [arguments].
  ///
  /// For instance
  ///     m() { dynamic(null, 42); }
  ///
  R visitDynamicTypeLiteralInvoke(
      Send node,
      ConstantExpression constant,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Assignment of [rhs] to the type literal for `dynamic`.
  ///
  /// For instance
  ///     m() { dynamic = rhs; }
  ///
  R visitDynamicTypeLiteralSet(
      SendSet node,
      ConstantExpression constant,
      Node rhs,
      A arg);

  /// Call to `assert` with [expression] as the condition.
  ///
  /// For instance:
  ///     m() { assert(expression); }
  ///
  R visitAssert(
      Send node,
      Node expression,
      A arg);

  /// Call to `assert` with the wrong number of [arguments].
  ///
  /// For instance:
  ///     m() { assert(); }
  /// or
  ///     m() { assert(expression1, expression2); }
  ///
  R errorInvalidAssert(
      Send node,
      NodeList arguments,
      A arg);

  /// Binary expression `left operator right` where [operator] is a user
  /// definable operator. Binary expressions using operator `==` are handled
  /// by [visitEquals] and index operations `a[b]` are handled by [visitIndex].
  ///
  /// For instance:
  ///     add(a, b) => a + b;
  ///     sub(a, b) => a - b;
  ///     mul(a, b) => a * b;
  ///
  R visitBinary(
      Send node,
      Node left,
      BinaryOperator operator,
      Node right,
      A arg);

  /// Binary expression `super operator argument` where [operator] is a user
  /// definable operator implemented on a superclass by [function]. Binary
  /// expressions using operator `==` are handled by [visitSuperEquals].
  ///
  /// For instance:
  ///     class B {
  ///       operator +(_) => null;
  ///     }
  ///     class C extends B {
  ///       m(a) => super + a;
  ///     }
  ///
  R visitSuperBinary(
      Send node,
      FunctionElement function,
      BinaryOperator operator,
      Node argument,
      A arg);

  /// Binary operation on the unresolved super [element].
  ///
  /// For instance
  ///     class B {
  ///     }
  ///     class C extends B {
  ///       m() => super + 42;
  ///     }
  ///
  R visitUnresolvedSuperBinary(
      Send node,
      Element element,
      BinaryOperator operator,
      Node argument,
      A arg);

  /// Index expression `receiver[index]`.
  ///
  /// For instance:
  ///     lookup(a, b) => a[b];
  ///
  R visitIndex(
      Send node,
      Node receiver,
      Node index,
      A arg);

  /// Prefix operation on an index expression `operator receiver[index]` where
  /// the operation is defined by [operator].
  ///
  /// For instance:
  ///     lookup(a, b) => --a[b];
  ///
  R visitIndexPrefix(
      Send node,
      Node receiver,
      Node index,
      IncDecOperator operator,
      A arg);

  /// Postfix operation on an index expression `receiver[index] operator` where
  /// the operation is defined by [operator].
  ///
  /// For instance:
  ///     lookup(a, b) => a[b]++;
  ///
  R visitIndexPostfix(
      Send node,
      Node receiver,
      Node index,
      IncDecOperator operator,
      A arg);

  /// Index expression `super[index]` where 'operator []' is implemented on a
  /// superclass by [function].
  ///
  /// For instance:
  ///     class B {
  ///       operator [](_) => null;
  ///     }
  ///     class C extends B {
  ///       m(a) => super[a];
  ///     }
  ///
  R visitSuperIndex(
      Send node,
      FunctionElement function,
      Node index,
      A arg);

  /// Index expression `super[index]` where 'operator []' is unresolved.
  ///
  /// For instance:
  ///     class B {}
  ///     class C extends B {
  ///       m(a) => super[a];
  ///     }
  ///
  R visitUnresolvedSuperIndex(
      Send node,
      Element element,
      Node index,
      A arg);

  /// Prefix operation on an index expression `operator super[index]` where
  /// 'operator []' is implemented on a superclass by [indexFunction] and
  /// 'operator []=' is implemented on by [indexSetFunction] and the operation
  /// is defined by [operator].
  ///
  /// For instance:
  ///     class B {
  ///       operator [](_) => null;
  ///       operator []=(a, b) {}
  ///     }
  ///     class C extends B {
  ///       m(a) => --super[a];
  ///     }
  ///
  R visitSuperIndexPrefix(
      Send node,
      MethodElement indexFunction,
      MethodElement indexSetFunction,
      Node index,
      IncDecOperator operator,
      A arg);

  /// Postfix operation on an index expression `super[index] operator` where
  /// 'operator []' is implemented on a superclass by [indexFunction] and
  /// 'operator []=' is implemented on by [indexSetFunction] and the operation
  /// is defined by [operator].
  ///
  /// For instance:
  ///     class B {
  ///       operator [](_) => null;
  ///       operator []=(a, b) {}
  ///     }
  ///     class C extends B {
  ///       m(a) => super[a]++;
  ///     }
  ///
  R visitSuperIndexPostfix(
      Send node,
      MethodElement indexFunction,
      MethodElement indexSetFunction,
      Node index,
      IncDecOperator operator,
      A arg);

  /// Prefix operation on an index expression `operator super[index]` where
  /// 'operator []' is unresolved, 'operator []=' is defined by [setter], and
  /// the operation is defined by [operator].
  ///
  /// For instance:
  ///     class B {
  ///       operator []=(a, b) {}
  ///     }
  ///     class C extends B {
  ///       m(a) => --super[a];
  ///     }
  ///
  R visitUnresolvedSuperGetterIndexPrefix(
      Send node,
      Element element,
      MethodElement setter,
      Node index,
      IncDecOperator operator,
      A arg);

  /// Postfix operation on an index expression `super[index] operator` where
  /// 'operator []' is unresolved, 'operator []=' is defined by [setter], and
  /// the operation is defined by [operator].
  ///
  /// For instance:
  ///     class B {
  ///       operator []=(a, b) {}
  ///     }
  ///     class C extends B {
  ///       m(a) => super[a]++;
  ///     }
  ///
  R visitUnresolvedSuperGetterIndexPostfix(
      Send node,
      Element element,
      MethodElement setter,
      Node index,
      IncDecOperator operator,
      A arg);

  /// Prefix operation on an index expression `operator super[index]` where
  /// 'operator []' is implemented on a superclass by [indexFunction] and
  /// 'operator []=' is unresolved and the operation is defined by [operator].
  ///
  /// For instance:
  ///     class B {
  ///       operator [](_) => 42;
  ///     }
  ///     class C extends B {
  ///       m(a) => --super[a];
  ///     }
  ///
  R visitUnresolvedSuperSetterIndexPrefix(
      Send node,
      MethodElement indexFunction,
      Element element,
      Node index,
      IncDecOperator operator,
      A arg);

  /// Postfix operation on an index expression `super[index] operator` where
  /// 'operator []' is implemented on a superclass by [indexFunction] and
  /// 'operator []=' is unresolved and the operation is defined by [operator].
  ///
  /// For instance:
  ///     class B {
  ///       operator [](_) => 42;
  ///     }
  ///     class C extends B {
  ///       m(a) => super[a]++;
  ///     }
  ///
  R visitUnresolvedSuperSetterIndexPostfix(
      Send node,
      MethodElement indexFunction,
      Element element,
      Node index,
      IncDecOperator operator,
      A arg);

  /// Prefix operation on an index expression `super[index] operator` where
  /// both 'operator []' and 'operator []=' are unresolved and the operation is
  /// defined by [operator].
  ///
  /// For instance:
  ///     class B {
  ///       operator [](_) => 42;
  ///     }
  ///     class C extends B {
  ///       m(a) => super[a]++;
  ///     }
  ///
  R visitUnresolvedSuperIndexPrefix(
      Send node,
      Element element,
      Node index,
      IncDecOperator operator,
      A arg);

  /// Postfix operation on an index expression `super[index] operator` where
  /// both 'operator []' and 'operator []=' are unresolved and the operation is
  /// defined by [operator].
  ///
  /// For instance:
  ///     class B {
  ///       operator [](_) => 42;
  ///     }
  ///     class C extends B {
  ///       m(a) => super[a]++;
  ///     }
  ///
  R visitUnresolvedSuperIndexPostfix(
      Send node,
      Element element,
      Node index,
      IncDecOperator operator,
      A arg);

  /// Binary expression `left == right`.
  ///
  /// For instance:
  ///     neq(a, b) => a != b;
  ///
  R visitNotEquals(
      Send node,
      Node left,
      Node right,
      A arg);

  /// Binary expression `super != argument` where `==` is implemented on a
  /// superclass by [function].
  ///
  /// For instance:
  ///     class B {
  ///       operator +(_) => null;
  ///     }
  ///     class C extends B {
  ///       m(a) => super + a;
  ///     }
  ///
  R visitSuperNotEquals(
      Send node,
      FunctionElement function,
      Node argument,
      A arg);

  /// Binary expression `left == right`.
  ///
  /// For instance:
  ///     eq(a, b) => a == b;
  ///
  R visitEquals(
      Send node,
      Node left,
      Node right,
      A arg);

  /// Binary expression `super == argument` where `==` is implemented on a
  /// superclass by [function].
  ///
  /// For instance:
  ///     class B {
  ///       operator ==(_) => null;
  ///     }
  ///     class C extends B {
  ///       m(a) => super == a;
  ///     }
  ///
  R visitSuperEquals(
      Send node,
      FunctionElement function,
      Node argument,
      A arg);

  /// Unary expression `operator expression` where [operator] is a user
  /// definable operator.
  ///
  /// For instance:
  ///     neg(a, b) => -a;
  ///     comp(a, b) => ~a;
  ///
  R visitUnary(
      Send node,
      UnaryOperator operator,
      Node expression,
      A arg);

  /// Unary expression `operator super` where [operator] is a user definable
  /// operator implemented on a superclass by [function].
  ///
  /// For instance:
  ///     class B {
  ///       operator -() => null;
  ///     }
  ///     class C extends B {
  ///       m(a) => -super;
  ///     }
  ///
  R visitSuperUnary(
      Send node,
      UnaryOperator operator,
      FunctionElement function,
      A arg);

  /// Unary operation on the unresolved super [element].
  ///
  /// For instance
  ///     class B {
  ///     }
  ///     class C extends B {
  ///       m() => -super;
  ///     }
  ///
  R visitUnresolvedSuperUnary(
      Send node,
      UnaryOperator operator,
      Element element,
      A arg);

  /// Unary expression `!expression`.
  ///
  /// For instance:
  ///     not(a) => !a;
  ///
  R visitNot(
      Send node,
      Node expression,
      A arg);

  /// Index set expression `receiver[index] = rhs`.
  ///
  /// For instance:
  ///     m(receiver, index, rhs) => receiver[index] = rhs;
  ///
  R visitIndexSet(
      SendSet node,
      Node receiver,
      Node index,
      Node rhs,
      A arg);

  /// Index set expression `super[index] = rhs` where `operator []=` is defined
  /// on a superclass by [function].
  ///
  /// For instance:
  ///     class B {
  ///       operator []=(a, b) {}
  ///     }
  ///     class C extends B {
  ///       m(a, b) => super[a] = b;
  ///     }
  ///
  R visitSuperIndexSet(
      SendSet node,
      FunctionElement function,
      Node index,
      Node rhs,
      A arg);

  /// Index set expression `super[index] = rhs` where `operator []=` is
  /// undefined.
  ///
  /// For instance
  ///     class B {
  ///     }
  ///     class C extends B {
  ///       m() => super[1] = 42;
  ///     }
  ///
  R visitUnresolvedSuperIndexSet(
      Send node,
      Element element,
      Node index,
      Node rhs,
      A arg);

  /// If-null, ??, expression with operands [left] and [right].
  ///
  /// For instance
  ///     m() => left ?? right;
  ///
  R visitIfNull(
      Send node,
      Node left,
      Node right,
      A arg);

  /// Logical and, &&, expression with operands [left] and [right].
  ///
  /// For instance
  ///     m() => left && right;
  ///
  R visitLogicalAnd(
      Send node,
      Node left,
      Node right,
      A arg);

  /// Logical or, ||, expression with operands [left] and [right].
  ///
  /// For instance
  ///     m() => left || right;
  ///
  R visitLogicalOr(
      Send node,
      Node left,
      Node right,
      A arg);

  /// Is test of [expression] against [type].
  ///
  /// For instance
  ///     class C {}
  ///     m() => expression is C;
  ///
  R visitIs(
      Send node,
      Node expression,
      DartType type,
      A arg);

  /// Is not test of [expression] against [type].
  ///
  /// For instance
  ///     class C {}
  ///     m() => expression is! C;
  ///
  R visitIsNot(
      Send node,
      Node expression,
      DartType type,
      A arg);

  /// As cast of [expression] to [type].
  ///
  /// For instance
  ///     class C {}
  ///     m() => expression as C;
  ///
  R visitAs(
      Send node,
      Node expression,
      DartType type,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] of the property on
  /// [receiver] whose getter and setter are defined by [getterSelector] and
  /// [setterSelector], respectively.
  ///
  /// For instance:
  ///     m(receiver, rhs) => receiver.foo += rhs;
  ///
  R visitDynamicPropertyCompound(
      Send node,
      Node receiver,
      AssignmentOperator operator,
      Node rhs,
      Selector getterSelector,
      Selector setterSelector,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] of the property on
  /// a possibly null [receiver] whose getter and setter are defined by
  /// [getterSelector] and [setterSelector], respectively.
  ///
  /// For instance:
  ///     m(receiver, rhs) => receiver?.foo += rhs;
  ///
  R visitIfNotNullDynamicPropertyCompound(
      Send node,
      Node receiver,
      AssignmentOperator operator,
      Node rhs,
      Selector getterSelector,
      Selector setterSelector,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] of the property on
  /// `this` whose getter and setter are defined by [getterSelector] and
  /// [setterSelector], respectively.
  ///
  /// For instance:
  ///     class C {
  ///       m(rhs) => this.foo += rhs;
  ///     }
  /// or
  ///     class C {
  ///       m(rhs) => foo += rhs;
  ///     }
  ///
  R visitThisPropertyCompound(
      Send node,
      AssignmentOperator operator,
      Node rhs,
      Selector getterSelector,
      Selector setterSelector,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a [parameter].
  ///
  /// For instance:
  ///     m(parameter, rhs) => parameter += rhs;
  ///
  R visitParameterCompound(
      Send node,
      ParameterElement parameter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a final
  /// [parameter].
  ///
  /// For instance:
  ///     m(final parameter, rhs) => parameter += rhs;
  ///
  R visitFinalParameterCompound(
      Send node,
      ParameterElement parameter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a local
  /// [variable].
  ///
  /// For instance:
  ///     m(rhs) {
  ///       var variable;
  ///       variable += rhs;
  ///     }
  ///
  R visitLocalVariableCompound(
      Send node,
      LocalVariableElement variable,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a final local
  /// [variable].
  ///
  /// For instance:
  ///     m(rhs) {
  ///       final variable = 0;
  ///       variable += rhs;
  ///     }
  ///
  R visitFinalLocalVariableCompound(
      Send node,
      LocalVariableElement variable,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a local
  /// [function].
  ///
  /// For instance:
  ///     m(rhs) {
  ///       function() {}
  ///       function += rhs;
  ///     }
  ///
  R visitLocalFunctionCompound(
      Send node,
      LocalFunctionElement function,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a static
  /// [field].
  ///
  /// For instance:
  ///     class C {
  ///       static var field;
  ///       m(rhs) => field += rhs;
  ///     }
  ///
  R visitStaticFieldCompound(
      Send node,
      FieldElement field,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a final static
  /// [field].
  ///
  /// For instance:
  ///     class C {
  ///       static final field = 0;
  ///       m(rhs) => field += rhs;
  ///     }
  ///
  R visitFinalStaticFieldCompound(
      Send node,
      FieldElement field,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from a
  /// static [getter] and writing to a static [setter].
  ///
  /// For instance:
  ///     class C {
  ///       static get o => 0;
  ///       static set o(_) {}
  ///       m(rhs) => o += rhs;
  ///     }
  ///
  R visitStaticGetterSetterCompound(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from a
  /// static [method], that is, closurizing [method], and writing to a static
  /// [setter].
  ///
  /// For instance:
  ///     class C {
  ///       static o() {}
  ///       static set o(_) {}
  ///       m(rhs) => o += rhs;
  ///     }
  ///
  R visitStaticMethodSetterCompound(
      Send node,
      MethodElement method,
      MethodElement setter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a top level
  /// [field].
  ///
  /// For instance:
  ///     var field;
  ///     m(rhs) => field += rhs;
  ///
  R visitTopLevelFieldCompound(
      Send node,
      FieldElement field,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a final top
  /// level [field].
  ///
  /// For instance:
  ///     final field = 0;
  ///     m(rhs) => field += rhs;
  ///
  R visitFinalTopLevelFieldCompound(
      Send node,
      FieldElement field,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from a
  /// top level [getter] and writing to a top level [setter].
  ///
  /// For instance:
  ///     get o => 0;
  ///     set o(_) {}
  ///     m(rhs) => o += rhs;
  ///
  R visitTopLevelGetterSetterCompound(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from a
  /// top level [method], that is, closurizing [method], and writing to a top
  /// level [setter].
  ///
  /// For instance:
  ///     o() {}
  ///     set o(_) {}
  ///     m(rhs) => o += rhs;
  ///
  R visitTopLevelMethodSetterCompound(
      Send node,
      FunctionElement method,
      FunctionElement setter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from a
  /// top level [method], that is, closurizing [method], and writing to an
  /// unresolved setter.
  ///
  /// For instance:
  ///     o() {}
  ///     m(rhs) => o += rhs;
  ///
  R visitTopLevelMethodCompound(
      Send node,
      FunctionElement method,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a super
  /// [field].
  ///
  /// For instance:
  ///     class B {
  ///       var field;
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.field += rhs;
  ///     }
  ///
  R visitSuperFieldCompound(
      Send node,
      FieldElement field,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a final super
  /// [field].
  ///
  /// For instance:
  ///     class B {
  ///       final field = 42;
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.field += rhs;
  ///     }
  ///
  R visitFinalSuperFieldCompound(
      Send node,
      FieldElement field,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Prefix expression with [operator] on a final super [field].
  ///
  /// For instance:
  ///     class B {
  ///       final field = 42;
  ///     }
  ///     class C extends B {
  ///       m(rhs) => ++super.field;
  ///     }
  ///
  R visitFinalSuperFieldPrefix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on an unresolved super property.
  ///
  /// For instance:
  ///     class B {
  ///     }
  ///     class C extends B {
  ///       m(rhs) => ++super.unresolved;
  ///     }
  ///
  R visitUnresolvedSuperPrefix(
      Send node,
      Element element,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on an unresolved super property.
  ///
  /// For instance:
  ///     class B {
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.unresolved++;
  ///     }
  ///
  R visitUnresolvedSuperPostfix(
      Send node,
      Element element,
      IncDecOperator operator,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on an unresolved
  /// super property.
  ///
  /// For instance:
  ///     class B {
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.unresolved += rhs;
  ///     }
  ///
  R visitUnresolvedSuperCompound(
      Send node,
      Element element,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Postfix expression with [operator] on a final super [field].
  ///
  /// For instance:
  ///     class B {
  ///       final field = 42;
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.field++;
  ///     }
  ///
  R visitFinalSuperFieldPostfix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from the
  /// super field [readField] and writing to the different super field
  /// [writtenField].
  ///
  /// For instance:
  ///     class A {
  ///       var field;
  ///     }
  ///     class B extends A {
  ///       final field;
  ///     }
  ///     class C extends B {
  ///       m() => super.field += rhs;
  ///     }
  ///
  R visitSuperFieldFieldCompound(
      Send node,
      FieldElement readField,
      FieldElement writtenField,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from a
  /// super [getter] and writing to a super [setter].
  ///
  /// For instance:
  ///     class B {
  ///       get o => 0;
  ///       set o(_) {}
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.o += rhs;
  ///     }
  ///
  R visitSuperGetterSetterCompound(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from a
  /// super [method], that is, closurizing [method], and writing to a super
  /// [setter].
  ///
  /// For instance:
  ///     class B {
  ///       o() {}
  ///       set o(_) {}
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.o += rhs;
  ///     }
  ///
  R visitSuperMethodSetterCompound(
      Send node,
      FunctionElement method,
      FunctionElement setter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading the
  /// closurized super [method] and trying to invoke the non-existing setter.
  ///
  /// For instance:
  ///     class B {
  ///       o() {}
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.o += rhs;
  ///     }
  ///
  R visitSuperMethodCompound(
      Send node,
      FunctionElement method,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from the
  /// non-existing super getter and writing to a super [setter].
  ///
  /// For instance
  ///     class B {
  ///       set o(_) {}
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.o += rhs;
  ///     }
  ///
  R visitUnresolvedSuperGetterCompound(
      Send node,
      Element element,
      MethodElement setter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from a
  /// super [getter] and writing to the non-existing super setter.
  ///
  /// For instance
  ///     class B {
  ///       get o => 42;
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.o += rhs;
  ///     }
  ///
  R visitUnresolvedSuperSetterCompound(
      Send node,
      MethodElement getter,
      Element element,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from a
  /// super [field] and writing to a super [setter].
  ///
  /// For instance:
  ///     class A {
  ///       var o;
  ///     }
  ///     class B extends A {
  ///       set o(_) {}
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.o += rhs;
  ///     }
  ///
  R visitSuperFieldSetterCompound(
      Send node,
      FieldElement field,
      FunctionElement setter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] reading from a
  /// super [getter] and writing to a super [field].
  ///
  /// For instance:
  ///     class A {
  ///       var o;
  ///     }
  ///     class B extends A {
  ///       get o => 0;
  ///     }
  ///     class C extends B {
  ///       m(rhs) => super.o += rhs;
  ///     }
  ///
  R visitSuperGetterFieldCompound(
      Send node,
      FunctionElement getter,
      FieldElement field,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a type literal
  /// for class [element].
  ///
  /// For instance:
  ///     class C {}
  ///     m(rhs) => C += rhs;
  ///
  R visitClassTypeLiteralCompound(
      Send node,
      ConstantExpression constant,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a type literal
  /// for typedef [element].
  ///
  /// For instance:
  ///     typedef F();
  ///     m(rhs) => F += rhs;
  ///
  R visitTypedefTypeLiteralCompound(
      Send node,
      ConstantExpression constant,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on a type literal
  /// for type variable [element].
  ///
  /// For instance:
  ///     class C<T> {
  ///       m(rhs) => T += rhs;
  ///     }
  ///
  R visitTypeVariableTypeLiteralCompound(
      Send node,
      TypeVariableElement element,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment expression of [rhs] with [operator] on the type
  /// literal for `dynamic`.
  ///
  /// For instance:
  ///     m(rhs) => dynamic += rhs;
  ///
  R visitDynamicTypeLiteralCompound(
      Send node,
      ConstantExpression constant,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound index assignment of [rhs] with [operator] to [index] on the
  /// index operators of [receiver] whose getter and setter are defined by
  /// [getterSelector] and [setterSelector], respectively.
  ///
  /// For instance:
  ///     m(receiver, index, rhs) => receiver[index] += rhs;
  ///
  R visitCompoundIndexSet(
      SendSet node,
      Node receiver,
      Node index,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound index assignment of [rhs] with [operator] to [index] on the index
  /// operators of a super class defined by [getter] and [setter].
  ///
  /// For instance:
  ///     class B {
  ///       operator [](index) {}
  ///       operator [](index, value) {}
  ///     }
  ///     class C extends B {
  ///       m(index, rhs) => super[index] += rhs;
  ///     }
  ///
  R visitSuperCompoundIndexSet(
      SendSet node,
      MethodElement getter,
      MethodElement setter,
      Node index,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound index assignment of [rhs] with [operator] to [index] on a super
  /// super class where the index getter is undefined and the index setter is
  /// defined by [setter].
  ///
  /// For instance
  ///     class B {
  ///     }
  ///     class C extends B {
  ///       m() => super[1] += 42;
  ///     }
  ///
  R visitUnresolvedSuperGetterCompoundIndexSet(
      Send node,
      Element element,
      MethodElement setter,
      Node index,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound index assignment of [rhs] with [operator] to [index] on a super
  /// super class where the index getter is defined by [getter] but the index
  /// setter is undefined.
  ///
  /// For instance
  ///     class B {
  ///       operator [](index) => 42;
  ///     }
  ///     class C extends B {
  ///       m() => super[1] += 42;
  ///     }
  ///
  R visitUnresolvedSuperSetterCompoundIndexSet(
      Send node,
      MethodElement getter,
      Element element,
      Node index,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound index assignment of [rhs] with [operator] to [index] on a super
  /// super class where the index getter and setter are undefined.
  ///
  /// For instance
  ///     class B {
  ///     }
  ///     class C extends B {
  ///       m() => super[1] += 42;
  ///     }
  ///
  R visitUnresolvedSuperCompoundIndexSet(
      Send node,
      Element element,
      Node index,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Prefix expression with [operator] of the property on [receiver] whose
  /// getter and setter are defined by [getterSelector] and [setterSelector],
  /// respectively.
  ///
  /// For instance:
  ///     m(receiver) => ++receiver.foo;
  ///
  R visitDynamicPropertyPrefix(
      Send node,
      Node receiver,
      IncDecOperator operator,
      Selector getterSelector,
      Selector setterSelector,
      A arg);

  /// Prefix expression with [operator] of the property on a possibly null
  /// [receiver] whose getter and setter are defined by [getterSelector] and
  /// [setterSelector], respectively.
  ///
  /// For instance:
  ///     m(receiver) => ++receiver?.foo;
  ///
  R visitIfNotNullDynamicPropertyPrefix(
      Send node,
      Node receiver,
      IncDecOperator operator,
      Selector getterSelector,
      Selector setterSelector,
      A arg);

  /// Prefix expression with [operator] on a [parameter].
  ///
  /// For instance:
  ///     m(parameter) => ++parameter;
  ///
  R visitParameterPrefix(
      Send node,
      ParameterElement parameter,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a final [parameter].
  ///
  /// For instance:
  ///     m(final parameter) => ++parameter;
  ///
  R visitFinalParameterPrefix(
      Send node,
      ParameterElement parameter,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a local [variable].
  ///
  /// For instance:
  ///     m() {
  ///     var variable;
  ///      ++variable;
  ///     }
  ///
  R visitLocalVariablePrefix(
      Send node,
      LocalVariableElement variable,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a final local [variable].
  ///
  /// For instance:
  ///     m() {
  ///     final variable;
  ///      ++variable;
  ///     }
  ///
  R visitFinalLocalVariablePrefix(
      Send node,
      LocalVariableElement variable,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a local [function].
  ///
  /// For instance:
  ///     m() {
  ///     function() {}
  ///      ++function;
  ///     }
  ///
  R visitLocalFunctionPrefix(
      Send node,
      LocalFunctionElement function,
      IncDecOperator operator,
      A arg);


  /// Prefix expression with [operator] of the property on `this` whose getter
  /// and setter are defined by [getterSelector] and [setterSelector],
  /// respectively.
  ///
  /// For instance:
  ///     class C {
  ///       m() => ++foo;
  ///     }
  /// or
  ///     class C {
  ///       m() => ++this.foo;
  ///     }
  ///
  R visitThisPropertyPrefix(
      Send node,
      IncDecOperator operator,
      Selector getterSelector,
      Selector setterSelector,
      A arg);

  /// Prefix expression with [operator] on a static [field].
  ///
  /// For instance:
  ///     class C {
  ///       static var field;
  ///       m() => ++field;
  ///     }
  ///
  R visitStaticFieldPrefix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a final static [field].
  ///
  /// For instance:
  ///     class C {
  ///       static final field = 42;
  ///       m() => ++field;
  ///     }
  ///
  R visitFinalStaticFieldPrefix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from a static [getter] and
  /// writing to a static [setter].
  ///
  /// For instance:
  ///     class C {
  ///       static get o => 0;
  ///       static set o(_) {}
  ///       m() => ++o;
  ///     }
  ///
  R visitStaticGetterSetterPrefix(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);


  /// Prefix expression with [operator] reading from a static [method], that is,
  /// closurizing [method], and writing to a static [setter].
  ///
  /// For instance:
  ///     class C {
  ///       static o() {}
  ///       static set o(_) {}
  ///       m() => ++o;
  ///     }
  ///
  R visitStaticMethodSetterPrefix(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a top level [field].
  ///
  /// For instance:
  ///     var field;
  ///     m() => ++field;
  ///
  R visitTopLevelFieldPrefix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a final top level [field].
  ///
  /// For instance:
  ///     final field;
  ///     m() => ++field;
  ///
  R visitFinalTopLevelFieldPrefix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from a top level [getter] and
  /// writing to a top level [setter].
  ///
  /// For instance:
  ///     get o => 0;
  ///     set o(_) {}
  ///     m() => ++o;
  ///
  R visitTopLevelGetterSetterPrefix(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from a top level [method], that
  /// is, closurizing [method], and writing to a top level [setter].
  ///
  /// For instance:
  ///     o() {}
  ///     set o(_) {}
  ///     m() => ++o;
  ///
  R visitTopLevelMethodSetterPrefix(
      Send node,
      FunctionElement method,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a super [field].
  ///
  /// For instance:
  ///     class B {
  ///       var field;
  ///     }
  ///     class C extends B {
  ///       m() => ++super.field;
  ///     }
  ///
  R visitSuperFieldPrefix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from the super field [readField]
  /// and writing to the different super field [writtenField].
  ///
  /// For instance:
  ///     class A {
  ///       var field;
  ///     }
  ///     class B extends A {
  ///       final field;
  ///     }
  ///     class C extends B {
  ///       m() => ++super.field;
  ///     }
  ///
  R visitSuperFieldFieldPrefix(
      Send node,
      FieldElement readField,
      FieldElement writtenField,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from a super [field] and writing
  /// to a super [setter].
  ///
  /// For instance:
  ///     class A {
  ///       var field;
  ///     }
  ///     class B extends A {
  ///       set field(_) {}
  ///     }
  ///     class C extends B {
  ///       m() => ++super.field;
  ///     }
  ///
  R visitSuperFieldSetterPrefix(
      Send node,
      FieldElement field,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);


  /// Prefix expression with [operator] reading from a super [getter] and
  /// writing to a super [setter].
  ///
  /// For instance:
  ///     class B {
  ///       get field => 0;
  ///       set field(_) {}
  ///     }
  ///     class C extends B {
  ///       m() => ++super.field;
  ///     }
  ///
  R visitSuperGetterSetterPrefix(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from a super [getter] and
  /// writing to a super [field].
  ///
  /// For instance:
  ///     class A {
  ///       var field;
  ///     }
  ///     class B extends A {
  ///       get field => 0;
  ///     }
  ///     class C extends B {
  ///       m() => ++super.field;
  ///     }
  ///
  R visitSuperGetterFieldPrefix(
      Send node,
      FunctionElement getter,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from a super [method], that is,
  /// closurizing [method], and writing to a super [setter].
  ///
  /// For instance:
  ///     class B {
  ///       o() {}
  ///       set o(_) {}
  ///     }
  ///     class C extends B {
  ///       m() => ++super.o;
  ///     }
  ///
  R visitSuperMethodSetterPrefix(
      Send node,
      FunctionElement method,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from a super [method], that is,
  /// closurizing [method], and writing to an unresolved super setter.
  ///
  /// For instance:
  ///     class B {
  ///       o() {}
  ///       set o(_) {}
  ///     }
  ///     class C extends B {
  ///       m() => ++super.o;
  ///     }
  ///
  R visitSuperMethodPrefix(
      Send node,
      FunctionElement method,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from an unresolved super getter
  /// and writing to a super [setter].
  ///
  /// For instance
  ///     class B {
  ///       set o(_) {}
  ///     }
  ///     class C extends B {
  ///       m() => ++super.o;
  ///     }
  ///
  ///
  R visitUnresolvedSuperGetterPrefix(
      Send node,
      Element element,
      MethodElement setter,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from a super [getter] and
  /// writing to an unresolved super setter.
  ///
  /// For instance
  ///     class B {
  ///       get o => 42
  ///     }
  ///     class C extends B {
  ///       m() => ++super.o;
  ///     }
  ///
  ///
  R visitUnresolvedSuperSetterPrefix(
      Send node,
      MethodElement getter,
      Element element,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a type literal for a class [element].
  ///
  /// For instance:
  ///     class C {}
  ///     m() => ++C;
  ///
  R visitClassTypeLiteralPrefix(
      Send node,
      ConstantExpression constant,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a type literal for a typedef
  /// [element].
  ///
  /// For instance:
  ///     typedef F();
  ///     m() => ++F;
  ///
  R visitTypedefTypeLiteralPrefix(
      Send node,
      ConstantExpression constant,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on a type literal for a type variable
  /// [element].
  ///
  /// For instance:
  ///     class C<T> {
  ///       m() => ++T;
  ///     }
  ///
  R visitTypeVariableTypeLiteralPrefix(
      Send node,
      TypeVariableElement element,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] on the type literal for `dynamic`.
  ///
  /// For instance:
  ///     m() => ++dynamic;
  ///
  R visitDynamicTypeLiteralPrefix(
      Send node,
      ConstantExpression constant,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] of the property on [receiver] whose
  /// getter and setter are defined by [getterSelector] and [setterSelector],
  /// respectively.
  ///
  /// For instance:
  ///     m(receiver) => receiver.foo++;
  ///
  R visitDynamicPropertyPostfix(
      Send node,
      Node receiver,
      IncDecOperator operator,
      Selector getterSelector,
      Selector setterSelector,
      A arg);

  /// Postfix expression with [operator] of the property on a possibly null
  /// [receiver] whose getter and setter are defined by [getterSelector] and
  /// [setterSelector], respectively.
  ///
  /// For instance:
  ///     m(receiver) => receiver?.foo++;
  ///
  R visitIfNotNullDynamicPropertyPostfix(
      Send node,
      Node receiver,
      IncDecOperator operator,
      Selector getterSelector,
      Selector setterSelector,
      A arg);

  /// Postfix expression with [operator] on a [parameter].
  ///
  /// For instance:
  ///     m(parameter) => parameter++;
  ///
  R visitParameterPostfix(
      Send node,
      ParameterElement parameter,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a final [parameter].
  ///
  /// For instance:
  ///     m(final parameter) => parameter++;
  ///
  R visitFinalParameterPostfix(
      Send node,
      ParameterElement parameter,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a local [variable].
  ///
  /// For instance:
  ///     m() {
  ///       var variable;
  ///       variable++;
  ///     }
  ///
  R visitLocalVariablePostfix(
      Send node,
      LocalVariableElement variable,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a final local [variable].
  ///
  /// For instance:
  ///     m() {
  ///       final variable;
  ///       variable++;
  ///     }
  ///
  R visitFinalLocalVariablePostfix(
      Send node,
      LocalVariableElement variable,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a local [function].
  ///
  /// For instance:
  ///     m() {
  ///     function() {}
  ///      function++;
  ///     }
  ///
  R visitLocalFunctionPostfix(
      Send node,
      LocalFunctionElement function,
      IncDecOperator operator,
      A arg);


  /// Postfix expression with [operator] of the property on `this` whose getter
  /// and setter are defined by [getterSelector] and [setterSelector],
  /// respectively.
  ///
  /// For instance:
  ///     class C {
  ///       m() => foo++;
  ///     }
  /// or
  ///     class C {
  ///       m() => this.foo++;
  ///     }
  ///
  R visitThisPropertyPostfix(
      Send node,
      IncDecOperator operator,
      Selector getterSelector,
      Selector setterSelector,
      A arg);

  /// Postfix expression with [operator] on a static [field].
  ///
  /// For instance:
  ///     class C {
  ///       static var field;
  ///       m() => field++;
  ///     }
  ///
  R visitStaticFieldPostfix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a final static [field].
  ///
  /// For instance:
  ///     class C {
  ///       static final field;
  ///       m() => field++;
  ///     }
  ///
  R visitFinalStaticFieldPostfix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] reading from a static [getter] and
  /// writing to a static [setter].
  ///
  /// For instance:
  ///     class C {
  ///       static get o => 0;
  ///       static set o(_) {}
  ///       m() => o++;
  ///     }
  ///
  R visitStaticGetterSetterPostfix(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);


  /// Postfix expression with [operator] reading from a static [method], that
  /// is, closurizing [method], and writing to a static [setter].
  ///
  /// For instance:
  ///     class C {
  ///       static o() {}
  ///       static set o(_) {}
  ///       m() => o++;
  ///     }
  ///
  R visitStaticMethodSetterPostfix(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a top level [field].
  ///
  /// For instance:
  ///     var field;
  ///     m() => field++;
  ///
  R visitTopLevelFieldPostfix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a final top level [field].
  ///
  /// For instance:
  ///     final field = 42;
  ///     m() => field++;
  ///
  R visitFinalTopLevelFieldPostfix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] reading from a top level [getter] and
  /// writing to a top level [setter].
  ///
  /// For instance:
  ///     get o => 0;
  ///     set o(_) {}
  ///     m() => o++;
  ///
  R visitTopLevelGetterSetterPostfix(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] reading from a top level [method], that
  /// is, closurizing [method], and writing to a top level [setter].
  ///
  /// For instance:
  ///     o() {}
  ///     set o(_) {}
  ///     m() => o++;
  ///
  R visitTopLevelMethodSetterPostfix(
      Send node,
      FunctionElement method,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a super [field].
  ///
  /// For instance:
  ///     class B {
  ///       var field;
  ///     }
  ///     class C extends B {
  ///       m() => super.field++;
  ///     }
  ///
  R visitSuperFieldPostfix(
      Send node,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] reading from the super field
  /// [readField] and writing to the different super field [writtenField].
  ///
  /// For instance:
  ///     class A {
  ///       var field;
  ///     }
  ///     class B extends A {
  ///       final field;
  ///     }
  ///     class C extends B {
  ///       m() => super.field++;
  ///     }
  ///
  R visitSuperFieldFieldPostfix(
      Send node,
      FieldElement readField,
      FieldElement writtenField,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] reading from a super [field] and
  /// writing to a super [setter].
  ///
  /// For instance:
  ///     class A {
  ///       var field;
  ///     }
  ///     class B extends A {
  ///       set field(_) {}
  ///     }
  ///     class C extends B {
  ///       m() => super.field++;
  ///     }
  ///
  R visitSuperFieldSetterPostfix(
      Send node,
      FieldElement field,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);


  /// Postfix expression with [operator] reading from a super [getter] and
  /// writing to a super [setter].
  ///
  /// For instance:
  ///     class B {
  ///       get field => 0;
  ///       set field(_) {}
  ///     }
  ///     class C extends B {
  ///       m() => super.field++;
  ///     }
  ///
  R visitSuperGetterSetterPostfix(
      Send node,
      FunctionElement getter,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] reading from a super [getter] and
  /// writing to a super [field].
  ///
  /// For instance:
  ///     class A {
  ///       var field;
  ///     }
  ///     class B extends A {
  ///       get field => 0;
  ///     }
  ///     class C extends B {
  ///       m() => super.field++;
  ///     }
  ///
  R visitSuperGetterFieldPostfix(
      Send node,
      FunctionElement getter,
      FieldElement field,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] reading from a super [method], that is,
  /// closurizing [method], and writing to a super [setter].
  ///
  /// For instance:
  ///     class B {
  ///       o() {}
  ///       set o(_) {}
  ///     }
  ///     class C extends B {
  ///       m() => super.o++;
  ///     }
  ///
  R visitSuperMethodSetterPostfix(
      Send node,
      FunctionElement method,
      FunctionElement setter,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] reading from a super [method], that is,
  /// closurizing [method], and writing to an unresolved super.
  ///
  /// For instance:
  ///     class B {
  ///       o() {}
  ///       set o(_) {}
  ///     }
  ///     class C extends B {
  ///       m() => super.o++;
  ///     }
  ///
  R visitSuperMethodPostfix(
      Send node,
      FunctionElement method,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from an unresolved super getter
  /// and writing to a super [setter].
  ///
  /// For instance
  ///     class B {
  ///       set o(_) {}
  ///     }
  ///     class C extends B {
  ///       m() => super.o++;
  ///     }
  ///
  ///
  R visitUnresolvedSuperGetterPostfix(
      Send node,
      Element element,
      MethodElement setter,
      IncDecOperator operator,
      A arg);

  /// Prefix expression with [operator] reading from a super [getter] and
  /// writing to an unresolved super setter.
  ///
  /// For instance
  ///     class B {
  ///       get o => 42
  ///     }
  ///     class C extends B {
  ///       m() => super.o++;
  ///     }
  ///
  ///
  R visitUnresolvedSuperSetterPostfix(
      Send node,
      MethodElement getter,
      Element element,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a type literal for a class
  /// [element].
  ///
  /// For instance:
  ///     class C {}
  ///     m() => C++;
  ///
  R visitClassTypeLiteralPostfix(
      Send node,
      ConstantExpression constant,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a type literal for a typedef
  /// [element].
  ///
  /// For instance:
  ///     typedef F();
  ///     m() => F++;
  ///
  R visitTypedefTypeLiteralPostfix(
      Send node,
      ConstantExpression constant,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on a type literal for a type variable
  /// [element].
  ///
  /// For instance:
  ///     class C<T> {
  ///       m() => T++;
  ///     }
  ///
  R visitTypeVariableTypeLiteralPostfix(
      Send node,
      TypeVariableElement element,
      IncDecOperator operator,
      A arg);

  /// Postfix expression with [operator] on the type literal for `dynamic`.
  ///
  /// For instance:
  ///     m() => dynamic++;
  ///
  R visitDynamicTypeLiteralPostfix(
      Send node,
      ConstantExpression constant,
      IncDecOperator operator,
      A arg);

  /// Read of the [constant].
  ///
  /// For instance
  ///     const c = c;
  ///     m() => c;
  ///
  R visitConstantGet(
      Send node,
      ConstantExpression constant,
      A arg);

  /// Invocation of the [constant] with [arguments].
  ///
  /// For instance
  ///     const c = null;
  ///     m() => c(null, 42);
  ///
  R visitConstantInvoke(
      Send node,
      ConstantExpression constant,
      NodeList arguments,
      CallStructure callStreucture,
      A arg);

  /// Read of the unresolved [element].
  ///
  /// For instance
  ///     class C {}
  ///     m1() => unresolved;
  ///     m2() => prefix.unresolved;
  ///     m3() => Unresolved.foo;
  ///     m4() => unresolved.foo;
  ///     m5() => unresolved.Foo.bar;
  ///     m6() => C.unresolved;
  ///     m7() => prefix.C.unresolved;
  ///     m8() => prefix?.unresolved;
  ///     m9() => Unresolved?.foo;
  ///     m10() => unresolved?.foo;
  ///     m11() => unresolved?.Foo?.bar;
  ///
  // TODO(johnniwinther): Split the cases in which a prefix is resolved.
  R visitUnresolvedGet(
      Send node,
      Element element,
      A arg);

  /// Read of the unresolved super [element].
  ///
  /// For instance
  ///     class B {}
  ///     class C {
  ///       m() => super.foo;
  ///     }
  ///
  R visitUnresolvedSuperGet(
      Send node,
      Element element,
      A arg);

  /// Assignment of [rhs] to the unresolved [element].
  ///
  /// For instance
  ///     class C {}
  ///     m1() => unresolved = 42;
  ///     m2() => prefix.unresolved = 42;
  ///     m3() => Unresolved.foo = 42;
  ///     m4() => unresolved.foo = 42;
  ///     m5() => unresolved.Foo.bar = 42;
  ///     m6() => C.unresolved = 42;
  ///     m7() => prefix.C.unresolved = 42;
  ///     m8() => prefix?.unresolved = 42;
  ///     m9() => Unresolved?.foo = 42;
  ///     m10() => unresolved?.foo = 42;
  ///     m11() => unresolved?.Foo?.bar = 42;
  ///
  // TODO(johnniwinther): Split the cases in which a prefix is resolved.
  R visitUnresolvedSet(
      Send node,
      Element element,
      Node rhs,
      A arg);

  /// Invocation of the unresolved [element] with [arguments].
  ///
  /// For instance
  ///     class C {}
  ///     m1() => unresolved(null, 42);
  ///     m2() => prefix.unresolved(null, 42);
  ///     m3() => Unresolved.foo(null, 42);
  ///     m4() => unresolved.foo(null, 42);
  ///     m5() => unresolved.Foo.bar(null, 42);
  ///     m6() => C.unresolved(null, 42);
  ///     m7() => prefix.C.unresolved(null, 42);
  ///     m8() => prefix?.unresolved(null, 42);
  ///     m9() => Unresolved?.foo(null, 42);
  ///     m10() => unresolved?.foo(null, 42);
  ///     m11() => unresolved?.Foo?.bar(null, 42);
  ///
  // TODO(johnniwinther): Split the cases in which a prefix is resolved.
  R visitUnresolvedInvoke(
      Send node,
      Element element,
      NodeList arguments,
      Selector selector,
      A arg);

  /// Invocation of the unresolved super [element] with [arguments].
  ///
  /// For instance
  ///     class B {}
  ///     class C extends B {
  ///       m() => super.foo();
  ///     }
  ///
  R visitUnresolvedSuperInvoke(
      Send node,
      Element element,
      NodeList arguments,
      Selector selector,
      A arg);

  /// Compound assignment of [rhs] with [operator] reading from the
  /// non-existing static getter and writing to the static [setter].
  ///
  /// For instance
  ///     class C {
  ///       set foo(_) {}
  ///     }
  ///     m1() => C.foo += 42;
  ///
  R visitUnresolvedStaticGetterCompound(
      Send node,
      Element element,
      MethodElement setter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment of [rhs] with [operator] reading from the
  /// non-existing top level getter and writing to the top level [setter].
  ///
  /// For instance
  ///     set foo(_) {}
  ///     m1() => foo += 42;
  ///
  R visitUnresolvedTopLevelGetterCompound(
      Send node,
      Element element,
      MethodElement setter,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment of [rhs] with [operator] reading from the static
  /// [getter] and writing to the non-existing static setter.
  ///
  /// For instance
  ///     class C {
  ///       get foo => 42;
  ///     }
  ///     m1() => C.foo += 42;
  ///
  R visitUnresolvedStaticSetterCompound(
      Send node,
      MethodElement getter,
      Element element,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment of [rhs] with [operator] reading from the top level
  /// [getter] and writing to the non-existing top level setter.
  ///
  /// For instance
  ///     get foo => 42;
  ///     m1() => foo += 42;
  ///
  R visitUnresolvedTopLevelSetterCompound(
      Send node,
      MethodElement getter,
      Element element,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment of [rhs] with [operator] reading the closurized static
  /// [method] and trying to invoke the non-existing setter.
  ///
  /// For instance
  ///     class C {
  ///       foo() {}
  ///     }
  ///     m1() => C.foo += 42;
  ///
  R visitStaticMethodCompound(
      Send node,
      MethodElement method,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Compound assignment of [rhs] where both getter and setter are unresolved.
  ///
  /// For instance
  ///     class C {}
  ///     m1() => unresolved += 42;
  ///     m2() => prefix.unresolved += 42;
  ///     m3() => Unresolved.foo += 42;
  ///     m4() => unresolved.foo += 42;
  ///     m5() => unresolved.Foo.bar += 42;
  ///     m6() => C.unresolved += 42;
  ///     m7() => prefix.C.unresolved += 42;
  ///     m8() => prefix?.unresolved += 42;
  ///     m9() => Unresolved?.foo += 42;
  ///     m10() => unresolved?.foo += 42;
  ///     m11() => unresolved?.Foo?.bar += 42;
  ///
  // TODO(johnniwinther): Split the cases in which a prefix is resolved.
  R visitUnresolvedCompound(
      Send node,
      Element element,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Prefix operation of [operator] reading from the non-existing static getter
  /// and writing to the static [setter].
  ///
  /// For instance
  ///     class C {
  ///       set foo(_) {}
  ///     }
  ///     m1() => ++C.foo;
  ///
  R visitUnresolvedStaticGetterPrefix(
      Send node,
      Element element,
      MethodElement setter,
      IncDecOperator operator,
      A arg);

  /// Prefix operation of [operator] reading from the non-existing top level
  /// getter and writing to the top level [setter].
  ///
  /// For instance
  ///     set foo(_) {}
  ///     m1() => ++foo;
  ///
  R visitUnresolvedTopLevelGetterPrefix(
      Send node,
      Element element,
      MethodElement setter,
      IncDecOperator operator,
      A arg);

  /// Prefix operation of [operator] reading from the static [getter] and
  /// writing to the non-existing static setter.
  ///
  /// For instance
  ///     class C {
  ///       get foo => 42;
  ///     }
  ///     m1() => ++C.foo;
  ///
  R visitUnresolvedStaticSetterPrefix(
      Send node,
      MethodElement getter,
      Element element,
      IncDecOperator operator,
      A arg);

  /// Postfix operation of [operator] reading from the top level [getter] and
  /// writing to the non-existing top level setter.
  ///
  /// For instance
  ///     get foo => 42;
  ///     m1() => ++foo;
  ///
  R visitUnresolvedTopLevelSetterPrefix(
      Send node,
      MethodElement getter,
      Element element,
      IncDecOperator operator,
      A arg);

  /// Prefix operation of [operator] reading the closurized static [method] and
  /// trying to invoke the non-existing setter.
  ///
  /// For instance
  ///     class C {
  ///       foo() {}
  ///     }
  ///     m1() => ++C.foo;
  ///
  R visitStaticMethodPrefix(
      Send node,
      MethodElement method,
      IncDecOperator operator,
      A arg);

  /// Prefix operation of [operator] reading the closurized top level [method]
  /// and trying to invoke the non-existing setter.
  ///
  /// For instance
  ///     class C {
  ///       foo() {}
  ///     }
  ///     m1() => ++C.foo;
  ///
  R visitTopLevelMethodPrefix(
      Send node,
      MethodElement method,
      IncDecOperator operator,
      A arg);

  /// Prefix operation where both getter and setter are unresolved.
  ///
  /// For instance
  ///     class C {}
  ///     m1() => ++unresolved;
  ///     m2() => ++prefix.unresolved;
  ///     m3() => ++Unresolved.foo;
  ///     m4() => ++unresolved.foo;
  ///     m5() => ++unresolved.Foo.bar;
  ///     m6() => ++C.unresolved;
  ///     m7() => ++prefix.C.unresolved;
  ///     m8() => ++prefix?.unresolved;
  ///     m9() => ++Unresolved?.foo;
  ///     m10() => ++unresolved?.foo;
  ///     m11() => ++unresolved?.Foo?.bar;
  ///
  // TODO(johnniwinther): Split the cases in which a prefix is resolved.
  R visitUnresolvedPrefix(
      Send node,
      Element element,
      IncDecOperator operator,
      A arg);

  /// Postfix operation of [operator] reading from the non-existing static
  /// getter and writing to the static [setter].
  ///
  /// For instance
  ///     class C {
  ///       set foo(_) {}
  ///     }
  ///     m1() => C.foo++;
  ///
  R visitUnresolvedStaticGetterPostfix(
      Send node,
      Element element,
      MethodElement setter,
      IncDecOperator operator,
      A arg);

  /// Postfix operation of [operator] reading from the non-existing top level
  /// getter and writing to the top level [setter].
  ///
  /// For instance
  ///     set foo(_) {}
  ///     m1() => foo++;
  ///
  R visitUnresolvedTopLevelGetterPostfix(
      Send node,
      Element element,
      MethodElement setter,
      IncDecOperator operator,
      A arg);

  /// Postfix operation of [operator] reading from the static [getter] and
  /// writing to the non-existing static setter.
  ///
  /// For instance
  ///     class C {
  ///       get foo => 42;
  ///     }
  ///     m1() => C.foo++;
  ///
  R visitUnresolvedStaticSetterPostfix(
      Send node,
      MethodElement getter,
      Element element,
      IncDecOperator operator,
      A arg);

  /// Postfix operation of [operator] reading from the top level [getter] and
  /// writing to the non-existing top level setter.
  ///
  /// For instance
  ///     get foo => 42;
  ///     m1() => foo++;
  ///
  R visitUnresolvedTopLevelSetterPostfix(
      Send node,
      MethodElement getter,
      Element element,
      IncDecOperator operator,
      A arg);

  /// Postfix operation of [operator] reading the closurized static [method] and
  /// trying to invoke the non-existing setter.
  ///
  /// For instance
  ///     class C {
  ///       foo() {}
  ///     }
  ///     m1() => C.foo++;
  ///
  R visitStaticMethodPostfix(
      Send node,
      MethodElement method,
      IncDecOperator operator,
      A arg);

  /// Postfix operation of [operator] reading the closurized top level [method]
  /// and trying to invoke the non-existing setter.
  ///
  /// For instance
  ///     class C {
  ///       foo() {}
  ///     }
  ///     m1() => C.foo++;
  ///
  R visitTopLevelMethodPostfix(
      Send node,
      MethodElement method,
      IncDecOperator operator,
      A arg);

  /// Postfix operation where both getter and setter are unresolved.
  ///
  /// For instance
  ///     class C {}
  ///     m1() => unresolved++;
  ///     m2() => prefix.unresolved++;
  ///     m3() => Unresolved.foo++;
  ///     m4() => unresolved.foo++;
  ///     m5() => unresolved.Foo.bar++;
  ///     m6() => C.unresolved++;
  ///     m7() => prefix.C.unresolved++;
  ///     m8() => prefix?.unresolved++;
  ///     m9() => Unresolved?.foo++;
  ///     m10() => unresolved?.foo++;
  ///     m11() => unresolved?.Foo?.bar++;
  ///
  // TODO(johnniwinther): Split the cases in which a prefix is resolved.
  R visitUnresolvedPostfix(
      Send node,
      Element element,
      IncDecOperator operator,
      A arg);

  /// Invocation of an undefined unary [operator] on [expression].
  R errorUndefinedUnaryExpression(
      Send node,
      Operator operator,
      Node expression,
      A arg);

  /// Invocation of an undefined unary [operator] with operands
  /// [left] and [right].
  R errorUndefinedBinaryExpression(
      Send node,
      Node left,
      Operator operator,
      Node right,
      A arg);

  /// Const invocation of a [constant] constructor.
  ///
  /// For instance
  ///   class C<T> {
  ///     const C(a, b);
  ///   }
  ///   m() => const C<int>(true, 42);
  ///
  R visitConstConstructorInvoke(
      NewExpression node,
      ConstructedConstantExpression constant,
      A arg);

  /// Const invocation of the `bool.fromEnvironment` constructor.
  ///
  /// For instance
  ///   m() => const bool.fromEnvironment('foo', defaultValue: false);
  ///
  R visitBoolFromEnvironmentConstructorInvoke(
      NewExpression node,
      BoolFromEnvironmentConstantExpression constant,
      A arg);

  /// Const invocation of the `int.fromEnvironment` constructor.
  ///
  /// For instance
  ///   m() => const int.fromEnvironment('foo', defaultValue: 42);
  ///
  R visitIntFromEnvironmentConstructorInvoke(
      NewExpression node,
      IntFromEnvironmentConstantExpression constant,
      A arg);

  /// Const invocation of the `String.fromEnvironment` constructor.
  ///
  /// For instance
  ///   m() => const String.fromEnvironment('foo', defaultValue: 'bar');
  ///
  R visitStringFromEnvironmentConstructorInvoke(
      NewExpression node,
      StringFromEnvironmentConstantExpression constant,
      A arg);

  /// Invocation of a generative [constructor] on [type] with [arguments].
  ///
  /// For instance
  ///   class C<T> {
  ///     C(a, b);
  ///   }
  ///   m() => new C<int>(true, 42);
  ///
  /// where [type] is `C<int>`.
  ///
  R visitGenerativeConstructorInvoke(
      NewExpression node,
      ConstructorElement constructor,
      InterfaceType type,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of a redirecting generative [constructor] on [type] with
  /// [arguments].
  ///
  /// For instance
  ///   class C<T> {
  ///     C(a, b) : this._(b, a);
  ///     C._(b, a);
  ///   }
  ///   m() => new C<int>(true, 42);
  ///
  /// where [type] is `C<int>`.
  ///
  R visitRedirectingGenerativeConstructorInvoke(
      NewExpression node,
      ConstructorElement constructor,
      InterfaceType type,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of a factory [constructor] on [type] with [arguments].
  ///
  /// For instance
  ///   class C<T> {
  ///     factory C(a, b) => new C<T>._(b, a);
  ///     C._(b, a);
  ///   }
  ///   m() => new C<int>(true, 42);
  ///
  /// where [type] is `C<int>`.
  ///
  R visitFactoryConstructorInvoke(
      NewExpression node,
      ConstructorElement constructor,
      InterfaceType type,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of a factory [constructor] on [type] with [arguments] where
  /// [effectiveTarget] and [effectiveTargetType] are the constructor effective
  /// invoked and its type, respectively.
  ///
  /// For instance
  ///   class C<T> {
  ///     factory C(a, b) = C<int>.a;
  ///     factory C.a(a, b) = C<C<T>>.b;
  ///     C.b(a, b);
  ///   }
  ///   m() => new C<double>(true, 42);
  ///
  /// where [type] is `C<double>`, [effectiveTarget] is `C.b` and
  /// [effectiveTargetType] is `C<C<int>>`.
  ///
  R visitRedirectingFactoryConstructorInvoke(
      NewExpression node,
      ConstructorElement constructor,
      InterfaceType type,
      ConstructorElement effectiveTarget,
      InterfaceType effectiveTargetType,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of an unresolved [constructor] on [type] with [arguments].
  ///
  /// For instance
  ///   class C<T> {
  ///     C();
  ///   }
  ///   m() => new C<int>.unresolved(true, 42);
  ///
  /// where [type] is `C<int>`.
  ///
  // TODO(johnniwinther): Change [type] to [InterfaceType] when is it not
  // `dynamic`.
  R visitUnresolvedConstructorInvoke(
      NewExpression node,
      Element constructor,
      DartType type,
      NodeList arguments,
      Selector selector,
      A arg);

  /// Invocation of a constructor on an unresolved [type] with [arguments].
  ///
  /// For instance
  ///   m() => new Unresolved(true, 42);
  ///
  /// where [type] is the malformed type `Unresolved`.
  ///
  // TODO(johnniwinther): Change [type] to [MalformedType] when is it not
  // `dynamic`.
  R visitUnresolvedClassConstructorInvoke(
      NewExpression node,
      Element element,
      DartType type,
      NodeList arguments,
      Selector selector,
      A arg);

  /// Constant invocation of a non-constant constructor.
  ///
  /// For instance
  ///   class C {
  ///     C(a, b);
  ///   }
  ///   m() => const C(true, 42);
  ///
  R errorNonConstantConstructorInvoke(
      NewExpression node,
      Element element,
      DartType type,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of a constructor on an abstract [type] with [arguments].
  ///
  /// For instance
  ///   m() => new Unresolved(true, 42);
  ///
  /// where [type] is the malformed type `Unresolved`.
  ///
  R visitAbstractClassConstructorInvoke(
      NewExpression node,
      ConstructorElement element,
      InterfaceType type,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of a factory [constructor] on [type] with [arguments] where
  /// [effectiveTarget] and [effectiveTargetType] are the constructor effective
  /// invoked and its type, respectively.
  ///
  /// For instance
  ///   class C {
  ///     factory C(a, b) = Unresolved;
  ///     factory C.a(a, b) = C.unresolved;
  ///   }
  ///   m1() => new C(true, 42);
  ///   m2() => new C.a(true, 42);
  ///
  R visitUnresolvedRedirectingFactoryConstructorInvoke(
      NewExpression node,
      ConstructorElement constructor,
      InterfaceType type,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Invocation of [constructor] on [type] with incompatible [arguments].
  ///
  /// For instance
  ///   class C {
  ///     C(a);
  ///   }
  ///   m() => C(true, 42);
  ///
  R visitConstructorIncompatibleInvoke(
      NewExpression node,
      ConstructorElement constructor,
      InterfaceType type,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// Read access of an invalid expression.
  ///
  /// For instance
  ///   import 'foo.dart' as p;
  ///
  ///   m() => p;
  ///
  R errorInvalidGet(
      Send node,
      ErroneousElement error,
      A arg);


  /// Invocation of an invalid expression with [arguments].
  ///
  /// For instance
  ///   import 'foo.dart' as p;
  ///
  ///   m() => p(null, 42);
  ///
  R errorInvalidInvoke(
      Send node,
      ErroneousElement error,
      NodeList arguments,
      Selector selector,
      A arg);

  /// Assignment of [rhs] to an invalid expression.
  ///
  /// For instance
  ///   import 'foo.dart' as p;
  ///
  ///   m() { p = 42; }
  ///
  R errorInvalidSet(
      Send node,
      ErroneousElement error,
      Node rhs,
      A arg);

  /// Prefix operation on an invalid expression.
  ///
  /// For instance
  ///   import 'foo.dart' as p;
  ///
  ///   m() => ++p;
  ///
  R errorInvalidPrefix(
      Send node,
      ErroneousElement error,
      IncDecOperator operator,
      A arg);

  /// Postfix operation on an invalid expression.
  ///
  /// For instance
  ///   import 'foo.dart' as p;
  ///
  ///   m() => p--;
  ///
  R errorInvalidPostfix(
      Send node,
      ErroneousElement error,
      IncDecOperator operator,
      A arg);

  /// Compound assignment of [operator] with [rhs] on an invalid expression.
  ///
  /// For instance
  ///   import 'foo.dart' as p;
  ///
  ///   m() => p += 42;
  ///
  R errorInvalidCompound(
      Send node,
      ErroneousElement error,
      AssignmentOperator operator,
      Node rhs,
      A arg);

  /// Access of library through a deferred [prefix].
  ///
  /// For instance
  ///   import 'lib.dart' deferred as prefix;
  ///
  ///   m() => prefix.foo;
  ///
  /// This visit method is special in that it is called as a pre-step to calling
  /// the visit method for the actual access. Therefore this method cannot
  /// return a result to its caller.
  void previsitDeferredAccess(
      Send node,
      PrefixElement prefix,
      A arg);
}

abstract class SemanticDeclarationVisitor<R, A> {
  R apply(Node node, A arg);

  /// Apply this visitor to the [parameters].
  applyParameters(NodeList parameters, A arg);

  /// Apply this visitor to the initializers of [constructor].
  applyInitializers(FunctionExpression constructor, A arg);

  /// A declaration of a top level [getter].
  ///
  /// For instance
  ///     get m => 42;
  ///
  R visitTopLevelGetterDeclaration(
      FunctionExpression node,
      MethodElement getter,
      Node body,
      A arg);

  /// A declaration of a top level [setter].
  ///
  /// For instance
  ///     set m(a) {}
  ///
  R visitTopLevelSetterDeclaration(
      FunctionExpression node,
      MethodElement setter,
      NodeList parameters,
      Node body,
      A arg);

  /// A declaration of a top level [function].
  ///
  /// For instance
  ///     m(a) {}
  ///
  R visitTopLevelFunctionDeclaration(
      FunctionExpression node,
      MethodElement function,
      NodeList parameters,
      Node body,
      A arg);

  /// A declaration of a static [getter].
  ///
  /// For instance
  ///     class C {
  ///       static get m => 42;
  ///     }
  ///
  R visitStaticGetterDeclaration(
      FunctionExpression node,
      MethodElement getter,
      Node body,
      A arg);

  /// A declaration of a static [setter].
  ///
  /// For instance
  ///     class C {
  ///       static set m(a) {}
  ///     }
  ///
  R visitStaticSetterDeclaration(
      FunctionExpression node,
      MethodElement setter,
      NodeList parameters,
      Node body,
      A arg);

  /// A declaration of a static [function].
  ///
  /// For instance
  ///     class C {
  ///       static m(a) {}
  ///     }
  ///
  R visitStaticFunctionDeclaration(
      FunctionExpression node,
      MethodElement function,
      NodeList parameters,
      Node body,
      A arg);

  /// A declaration of an abstract instance [getter].
  ///
  /// For instance
  ///     abstract class C {
  ///       get m;
  ///     }
  ///
  R visitAbstractGetterDeclaration(
      FunctionExpression node,
      MethodElement getter,
      A arg);

  /// A declaration of an abstract instance [setter].
  ///
  /// For instance
  ///     abstract class C {
  ///       set m(a);
  ///     }
  ///
  R visitAbstractSetterDeclaration(
      FunctionExpression node,
      MethodElement setter,
      NodeList parameters,
      A arg);

  /// A declaration of an abstract instance [method].
  ///
  /// For instance
  ///     abstract class C {
  ///       m(a);
  ///     }
  ///
  R visitAbstractMethodDeclaration(
      FunctionExpression node,
      MethodElement method,
      NodeList parameters,
      A arg);

  /// A declaration of an instance [getter].
  ///
  /// For instance
  ///     class C {
  ///       get m => 42;
  ///     }
  ///
  R visitInstanceGetterDeclaration(
      FunctionExpression node,
      MethodElement getter,
      Node body,
      A arg);

  /// A declaration of an instance [setter].
  ///
  /// For instance
  ///     class C {
  ///       set m(a) {}
  ///     }
  ///
  R visitInstanceSetterDeclaration(
      FunctionExpression node,
      MethodElement setter,
      NodeList parameters,
      Node body,
      A arg);

  /// A declaration of an instance [method].
  ///
  /// For instance
  ///     class C {
  ///       m(a) {}
  ///     }
  ///
  R visitInstanceMethodDeclaration(
      FunctionExpression node,
      MethodElement method,
      NodeList parameters,
      Node body,
      A arg);

  /// A declaration of a local [function].
  ///
  /// For instance `local` in
  ///     m() {
  ///       local(a) {}
  ///     }
  ///
  R visitLocalFunctionDeclaration(
      FunctionExpression node,
      LocalFunctionElement function,
      NodeList parameters,
      Node body,
      A arg);

  /// A declaration of a [closure].
  ///
  /// For instance `(a) {}` in
  ///     m() {
  ///       var closure = (a) {};
  ///     }
  ///
  R visitClosureDeclaration(
      FunctionExpression node,
      LocalFunctionElement closure,
      NodeList parameters,
      Node body,
      A arg);

  /// A declaration of the [index]th [parameter] in a constructor, setter,
  /// method or function.
  ///
  /// For instance `a` in
  ///     m(a) {}
  ///
  R visitParameterDeclaration(
      VariableDefinitions node,
      Node definition,
      ParameterElement parameter,
      int index,
      A arg);

  /// A declaration of the [index]th optional [parameter] in a constructor,
  /// method or function with the explicit [defaultValue]. If no default value
  /// is declared, [defaultValue] is `null`.
  ///
  /// For instance `a` in
  ///     m([a = 42]) {}
  ///
  R visitOptionalParameterDeclaration(
      VariableDefinitions node,
      Node definition,
      ParameterElement parameter,
      ConstantExpression defaultValue,
      int index,
      A arg);

  /// A declaration of a named [parameter] in a constructor, method or function
  /// with the explicit [defaultValue]. If no default value is declared,
  /// [defaultValue] is `null`.
  ///
  /// For instance `a` in
  ///     m({a: 42}) {}
  ///
  R visitNamedParameterDeclaration(
      VariableDefinitions node,
      Node definition,
      ParameterElement parameter,
      ConstantExpression defaultValue,
      A arg);

  /// A declaration of the [index]th [parameter] as an initializing formal in a
  /// constructor.
  ///
  /// For instance `a` in
  ///     class C {
  ///       var a;
  ///       C(this.a);
  ///     }
  ///
  R visitInitializingFormalDeclaration(
      VariableDefinitions node,
      Node definition,
      InitializingFormalElement parameter,
      int index,
      A arg);

  /// A declaration of the [index]th optional [parameter] as an initializing
  /// formal in a constructor with the explicit [defaultValue]. If no default
  /// value is declared, [defaultValue] is `null`.
  ///
  /// For instance `a` in
  ///     class C {
  ///       var a;
  ///       C([this.a = 42]);
  ///     }
  ///
  R visitOptionalInitializingFormalDeclaration(
      VariableDefinitions node,
      Node definition,
      InitializingFormalElement parameter,
      ConstantExpression defaultValue,
      int index,
      A arg);

  /// A declaration of a named [parameter] as an initializing formal in a
  /// constructor with the explicit [defaultValue]. If no default value is
  /// declared, [defaultValue] is `null`.
  ///
  /// For instance `a` in
  ///     class C {
  ///       var a;
  ///       C({this.a: 42});
  ///     }
  ///
  R visitNamedInitializingFormalDeclaration(
      VariableDefinitions node,
      Node definition,
      InitializingFormalElement parameter,
      ConstantExpression defaultValue,
      A arg);

  /// A declaration of a local [variable] with the explicit [initializer]. If
  /// no initializer is declared, [initializer] is `null`.
  ///
  /// For instance `a` in
  ///     m() {
  ///       var a = 42;
  ///     }
  ///
  R visitLocalVariableDeclaration(
      VariableDefinitions node,
      Node definition,
      LocalVariableElement variable,
      Node initializer,
      A arg);

  /// A declaration of a local constant [variable] initialized to [constant].
  ///
  /// For instance `a` in
  ///     m() {
  ///       const a = 42;
  ///     }
  ///
  R visitLocalConstantDeclaration(
      VariableDefinitions node,
      Node definition,
      LocalVariableElement variable,
      ConstantExpression constant,
      A arg);

  /// A declaration of a top level [field] with the explicit [initializer].
  /// If no initializer is declared, [initializer] is `null`.
  ///
  /// For instance `a` in
  ///     var a = 42;
  ///
  R visitTopLevelFieldDeclaration(
      VariableDefinitions node,
      Node definition,
      FieldElement field,
      Node initializer,
      A arg);

  /// A declaration of a top level constant [field] initialized to [constant].
  ///
  /// For instance `a` in
  ///     const a = 42;
  ///
  R visitTopLevelConstantDeclaration(
      VariableDefinitions node,
      Node definition,
      FieldElement field,
      ConstantExpression constant,
      A arg);

  /// A declaration of a static [field] with the explicit [initializer].
  /// If no initializer is declared, [initializer] is `null`.
  ///
  /// For instance `a` in
  ///     class C {
  ///       static var a = 42;
  ///     }
  ///
  R visitStaticFieldDeclaration(
      VariableDefinitions node,
      Node definition,
      FieldElement field,
      Node initializer,
      A arg);

  /// A declaration of a static constant [field] initialized to [constant].
  ///
  /// For instance `a` in
  ///     class C {
  ///       static const a = 42;
  ///     }
  ///
  R visitStaticConstantDeclaration(
      VariableDefinitions node,
      Node definition,
      FieldElement field,
      ConstantExpression constant,
      A arg);

  /// A declaration of an instance [field] with the explicit [initializer].
  /// If no initializer is declared, [initializer] is `null`.
  ///
  /// For instance `a` in
  ///     class C {
  ///       var a = 42;
  ///     }
  ///
  R visitInstanceFieldDeclaration(
      VariableDefinitions node,
      Node definition,
      FieldElement field,
      Node initializer,
      A arg);

  /// A declaration of a generative [constructor] with the explicit constructor
  /// [initializers].
  ///
  /// For instance `C` in
  ///     class C {
  ///       var a;
  ///       C(a) : this.a = a, super();
  ///     }
  ///
  // TODO(johnniwinther): Replace [initializers] with a structure like
  // [InitializersStructure] when computed in resolution.
  R visitGenerativeConstructorDeclaration(
      FunctionExpression node,
      ConstructorElement constructor,
      NodeList parameters,
      NodeList initializers,
      Node body,
      A arg);

  /// A declaration of a redirecting generative [constructor] with
  /// [initializers] containing the redirecting constructor invocation.
  ///
  /// For instance `C` in
  ///     class C {
  ///       C() : this._();
  ///       C._();
  ///     }
  ///
  // TODO(johnniwinther): Replace [initializers] with a single
  // [ThisConstructorInvokeStructure] when computed in resolution.
  R visitRedirectingGenerativeConstructorDeclaration(
      FunctionExpression node,
      ConstructorElement constructor,
      NodeList parameters,
      NodeList initializers,
      A arg);

  /// A declaration of a factory [constructor].
  ///
  /// For instance `C` in
  ///     class C {
  ///       factory C(a) => null;
  ///     }
  ///
  R visitFactoryConstructorDeclaration(
      FunctionExpression node,
      ConstructorElement constructor,
      NodeList parameters,
      Node body,
      A arg);

  /// A declaration of a redirecting factory [constructor]. The immediate
  /// redirection target and its type is provided in [redirectionTarget] and
  /// [redirectionType], respectively.
  ///
  /// For instance
  ///    class C<T> {
  ///      factory C() = C<int>.a;
  ///      factory C.a() = C<C<T>>.b;
  ///      C.b();
  ///    }
  /// where `C` has the redirection target `C.a` of type `C<int>` and `C.a` has
  /// the redirection target `C.b` of type `C<C<T>>`.
  ///
  R visitRedirectingFactoryConstructorDeclaration(
      FunctionExpression node,
      ConstructorElement constructor,
      NodeList parameters,
      InterfaceType redirectionType,
      ConstructorElement redirectionTarget,
      A arg);

  /// An initializer of [field] with [initializer] as found in constructor
  /// initializers.
  ///
  /// For instance `this.a = 42` in
  ///     class C {
  ///       var a;
  ///       C() : this.a = 42;
  ///     }
  ///
  R visitFieldInitializer(
      SendSet node,
      FieldElement field,
      Node initializer,
      A arg);

  /// An initializer of an unresolved field with [initializer] as found in
  /// generative constructor initializers.
  ///
  /// For instance `this.a = 42` in
  ///     class C {
  ///       C() : this.a = 42;
  ///     }
  ///
  R errorUnresolvedFieldInitializer(
      SendSet node,
      Element element,
      Node initializer,
      A arg);

  /// An super constructor invocation of [superConstructor] with [arguments] as
  /// found in generative constructor initializers.
  ///
  /// For instance `super(42)` in
  ///     class B {
  ///       B(a);
  ///     }
  ///     class C extends B {
  ///       C() : super(42);
  ///     }
  ///
  R visitSuperConstructorInvoke(
      Send node,
      ConstructorElement superConstructor,
      InterfaceType type,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// An implicit super constructor invocation of [superConstructor] from
  /// generative constructor initializers.
  ///
  /// For instance `super(42)` in
  ///     class B {
  ///       B();
  ///     }
  ///     class C extends B {
  ///       C(); // Implicit super call of B().
  ///     }
  ///
  R visitImplicitSuperConstructorInvoke(
      FunctionExpression node,
      ConstructorElement superConstructor,
      InterfaceType type,
      A arg);

  /// An super constructor invocation of an unresolved with [arguments] as
  /// found in generative constructor initializers.
  ///
  /// For instance `super(42)` in
  ///     class B {
  ///       B(a);
  ///     }
  ///     class C extends B {
  ///       C() : super.unresolved(42);
  ///     }
  ///
  R errorUnresolvedSuperConstructorInvoke(
      Send node,
      Element element,
      NodeList arguments,
      Selector selector,
      A arg);

  /// An this constructor invocation of [thisConstructor] with [arguments] as
  /// found in a redirecting generative constructors initializer.
  ///
  /// For instance `this._(42)` in
  ///     class C {
  ///       C() : this._(42);
  ///       C._(a);
  ///     }
  ///
  R visitThisConstructorInvoke(
      Send node,
      ConstructorElement thisConstructor,
      NodeList arguments,
      CallStructure callStructure,
      A arg);

  /// An this constructor invocation of an unresolved constructor with
  /// [arguments] as found in a redirecting generative constructors initializer.
  ///
  /// For instance `this._(42)` in
  ///     class C {
  ///       C() : this._(42);
  ///     }
  ///
  R errorUnresolvedThisConstructorInvoke(
      Send node,
      Element element,
      NodeList arguments,
      Selector selector,
      A arg);
}
