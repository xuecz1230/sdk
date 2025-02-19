// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dart2js.ir_tracer;

import 'dart:async' show EventSink;
import 'cps_ir_nodes.dart' as cps_ir hide Function;
import '../tracer.dart';

/**
 * If true, show LetCont expressions in output.
 */
const bool IR_TRACE_LET_CONT = false;

class IRTracer extends TracerUtil implements cps_ir.Visitor {
  EventSink<String> output;

  IRTracer(this.output);

  visit(cps_ir.Node node) => node.accept(this);

  void traceGraph(String name, cps_ir.FunctionDefinition node) {
    tag("cfg", () {
      printProperty("name", name);

      names = new Names();
      BlockCollector builder = new BlockCollector(names);
      builder.visit(node);

      for (Block block in builder.entries) {
        printBlock(block, entryPointParameters: node.parameters);
      }
      for (Block block in builder.cont2block.values) {
        printBlock(block);
      }
      names = null;
    });
  }

  // Temporary field used during tree walk
  Names names;

  visitFunctionDefinition(cps_ir.FunctionDefinition node) {
    unexpectedNode(node);
  }

  // Bodies and initializers are not visited.  They contain continuations which
  // are found by a BlockCollector, then those continuations are processed by
  // this visitor.
  unexpectedNode(cps_ir.Node node) {
    throw 'The IR tracer reached an unexpected IR instruction: $node';
  }


  int countUses(cps_ir.Definition definition) {
    int count = 0;
    cps_ir.Reference ref = definition.firstRef;
    while (ref != null) {
      ++count;
      ref = ref.next;
    }
    return count;
  }

  /// If [entryPointParameters] is given, this block is an entry point
  /// and [entryPointParameters] is the list of function parameters.
  printBlock(Block block, {List<cps_ir.Definition> entryPointParameters}) {
    tag("block", () {
      printProperty("name", block.name);
      printProperty("from_bci", -1);
      printProperty("to_bci", -1);
      printProperty("predecessors", block.pred.map((n) => n.name));
      printProperty("successors", block.succ.map((n) => n.name));
      printEmptyProperty("xhandlers");
      printEmptyProperty("flags");
      tag("states", () {
        tag("locals", () {
          printProperty("size", 0);
          printProperty("method", "None");
        });
      });
      tag("HIR", () {
        if (entryPointParameters != null) {
          String params = entryPointParameters.map(names.name).join(', ');
          printStmt('x0', 'Entry ($params)');
        }
        for (cps_ir.Parameter param in block.parameters) {
          String name = names.name(param);
          printStmt(name, "Parameter $name [useCount=${countUses(param)}]");
        }
        visit(block.body);
      });
    });
  }

  void printStmt(String resultVar, String contents) {
    int bci = 0;
    int uses = 0;
    addIndent();
    add("$bci $uses $resultVar $contents <|@\n");
  }

  visitLetPrim(cps_ir.LetPrim node) {
    String id = names.name(node.primitive);
    printStmt(id, "LetPrim $id = ${formatPrimitive(node.primitive)}");
    visit(node.body);
  }

  visitLetCont(cps_ir.LetCont node) {
    if (IR_TRACE_LET_CONT) {
      String dummy = names.name(node);

      String nameContinuation(cps_ir.Continuation cont) {
        String name = names.name(cont);
        return cont.isRecursive ? '$name*' : name;
      }
      
      String ids = node.continuations.map(nameContinuation).join(', ');
      printStmt(dummy, "LetCont $ids");
    }
    visit(node.body);
  }

  visitLetHandler(cps_ir.LetHandler node) {
    if (IR_TRACE_LET_CONT) {
      String dummy = names.name(node);
      String id = names.name(node.handler);
      printStmt(dummy, "LetHandler $id = <$id>");
    }
    visit(node.body);
  }

  visitLetMutable(cps_ir.LetMutable node) {
    String id = names.name(node.variable);
    printStmt(id, "LetMutable $id = ${formatReference(node.value)}");
    visit(node.body);
  }

  visitInvokeStatic(cps_ir.InvokeStatic node) {
    String dummy = names.name(node);
    String callName = node.selector.name;
    String args = node.arguments.map(formatReference).join(', ');
    String kont = formatReference(node.continuation);
    printStmt(dummy, "InvokeStatic $callName ($args) $kont");
  }

  visitInvokeMethod(cps_ir.InvokeMethod node) {
    String dummy = names.name(node);
    String receiver = formatReference(node.receiver);
    String callName = node.selector.name;
    String args = node.arguments.map(formatReference).join(', ');
    String kont = formatReference(node.continuation);
    printStmt(dummy,
        "InvokeMethod $receiver $callName ($args) $kont");
  }

  visitInvokeMethodDirectly(cps_ir.InvokeMethodDirectly node) {
    String dummy = names.name(node);
    String receiver = formatReference(node.receiver);
    String callName = node.selector.name;
    String args = node.arguments.map(formatReference).join(', ');
    String kont = formatReference(node.continuation);
    printStmt(dummy,
        "InvokeMethodDirectly $receiver $callName ($args) $kont");
  }

  visitInvokeConstructor(cps_ir.InvokeConstructor node) {
    String dummy = names.name(node);
    String className = node.target.enclosingClass.name;
    String callName;
    if (node.target.name.isEmpty) {
      callName = '${className}';
    } else {
      callName = '${className}.${node.target.name}';
    }
    String args = node.arguments.map(formatReference).join(', ');
    String kont = formatReference(node.continuation);
    printStmt(dummy, "InvokeConstructor $callName ($args) $kont");
  }

  visitThrow(cps_ir.Throw node) {
    String dummy = names.name(node);
    String value = formatReference(node.value);
    printStmt(dummy, "Throw $value");
  }

  visitRethrow(cps_ir.Rethrow node) {
    String dummy = names.name(node);
    printStmt(dummy, "Rethrow");
  }

  visitUnreachable(cps_ir.Unreachable node) {
    String dummy = names.name(node);
    printStmt(dummy, 'Unreachable');
  }

  visitLiteralList(cps_ir.LiteralList node) {
    String values = node.values.map(formatReference).join(', ');
    return "LiteralList ($values)";
  }

  visitLiteralMap(cps_ir.LiteralMap node) {
    List<String> entries = new List<String>();
    for (cps_ir.LiteralMapEntry entry in node.entries) {
      String key = formatReference(entry.key);
      String value = formatReference(entry.value);
      entries.add("$key: $value");
    }
    return "LiteralMap (${entries.join(', ')})";
  }

  visitTypeCast(cps_ir.TypeCast node) {
    String dummy = names.name(node);
    String value = formatReference(node.value);
    String args = node.typeArguments.map(formatReference).join(', ');
    String kont = formatReference(node.continuation);
    printStmt(dummy, "TypeCast ($value ${node.type} ($args)) $kont");
  }

  visitInvokeContinuation(cps_ir.InvokeContinuation node) {
    String dummy = names.name(node);
    String kont = formatReference(node.continuation);
    String args = node.arguments.map(formatReference).join(', ');
    printStmt(dummy, "InvokeContinuation $kont ($args)");
  }

  visitBranch(cps_ir.Branch node) {
    String dummy = names.name(node);
    String condition = visit(node.condition);
    String trueCont = formatReference(node.trueContinuation);
    String falseCont = formatReference(node.falseContinuation);
    printStmt(dummy, "Branch $condition ($trueCont, $falseCont)");
  }

  visitSetMutable(cps_ir.SetMutable node) {
    String variable = names.name(node.variable.definition);
    String value = formatReference(node.value);
    return 'SetMutable $variable := $value';
  }

  String formatReference(cps_ir.Reference ref) {
    cps_ir.Definition target = ref.definition;
    if (target is cps_ir.Continuation && target.isReturnContinuation) {
      return "return"; // Do not generate a name for the return continuation
    } else {
      return names.name(ref.definition);
    }
  }

  String formatPrimitive(cps_ir.Primitive p) => visit(p);

  visitConstant(cps_ir.Constant node) {
    return "Constant ${node.value.toStructuredString()}";
  }

  visitParameter(cps_ir.Parameter node) {
    return "Parameter ${names.name(node)}";
  }

  visitMutableVariable(cps_ir.MutableVariable node) {
    return "MutableVariable ${names.name(node)}";
  }

  visitContinuation(cps_ir.Continuation node) {
    return "Continuation ${names.name(node)}";
  }

  visitIsTrue(cps_ir.IsTrue node) {
    return "IsTrue(${names.name(node.value.definition)})";
  }

  visitSetField(cps_ir.SetField node) {
    String object = formatReference(node.object);
    String field = node.field.name;
    String value = formatReference(node.value);
    return 'SetField $object.$field = $value';
  }

  visitGetField(cps_ir.GetField node) {
    String object = formatReference(node.object);
    String field = node.field.name;
    return 'GetField($object.$field)';
  }

  visitGetStatic(cps_ir.GetStatic node) {
    String element = node.element.name;
    return 'GetStatic($element)';
  }

  visitSetStatic(cps_ir.SetStatic node) {
    String element = node.element.name;
    String value = formatReference(node.value);
    return 'SetStatic $element = $value';
  }

  visitGetLazyStatic(cps_ir.GetLazyStatic node) {
    String dummy = names.name(node);
    String kont = formatReference(node.continuation);
    printStmt(dummy, "GetLazyStatic $kont");
  }

  visitCreateBox(cps_ir.CreateBox node) {
    return 'CreateBox';
  }

  visitCreateInstance(cps_ir.CreateInstance node) {
    String className = node.classElement.name;
    String arguments = node.arguments.map(formatReference).join(', ');
    String typeInformation =
        node.typeInformation.map(formatReference).join(', ');
    return 'CreateInstance $className ($arguments) <$typeInformation>';
  }

  visitInterceptor(cps_ir.Interceptor node) {
    return "Interceptor(${formatReference(node.input)})";
  }

  visitCreateFunction(cps_ir.CreateFunction node) {
    return "CreateFunction ${node.definition.element.name}";
  }

  visitGetMutable(cps_ir.GetMutable node) {
    String variable = names.name(node.variable.definition);
    return 'GetMutable $variable';
  }

  visitReadTypeVariable(cps_ir.ReadTypeVariable node) {
    return "ReadTypeVariable ${node.variable.element} "
        "${formatReference(node.target)}";
  }

  visitReifyRuntimeType(cps_ir.ReifyRuntimeType node) {
    return "ReifyRuntimeType ${formatReference(node.value)}";
  }

  visitTypeExpression(cps_ir.TypeExpression node) {
    return "TypeExpression ${node.dartType} "
        "${node.arguments.map(formatReference).join(', ')}";
  }

  visitCreateInvocationMirror(cps_ir.CreateInvocationMirror node) {
    String args = node.arguments.map(formatReference).join(', ');
    return "CreateInvocationMirror(${node.selector.name}, $args)";
  }

  visitTypeTest(cps_ir.TypeTest node) {
    String value = formatReference(node.value);
    String args = node.typeArguments.map(formatReference).join(', ');
    return "TypeTest ($value ${node.type} ($args))";
  }

  visitApplyBuiltinOperator(cps_ir.ApplyBuiltinOperator node) {
    String operator = node.operator.toString();
    String args = node.arguments.map(formatReference).join(', ');
    return 'ApplyBuiltinOperator $operator ($args)';
  }

  @override
  visitForeignCode(cps_ir.ForeignCode node) {
    String id = names.name(node);
    String arguments = node.arguments.map(formatReference).join(', ');
    String continuation = formatReference(node.continuation);
    printStmt(id, "ForeignCode ${node.type} ${node.codeTemplate.source} "
        "$arguments $continuation");
  }

  visitGetLength(cps_ir.GetLength node) {
    String object = formatReference(node.object);
    return 'GetLength $object';
  }

  visitGetIndex(cps_ir.GetIndex node) {
    String object = formatReference(node.object);
    String index = formatReference(node.index);
    return 'GetIndex $object $index';
  }

  visitSetIndex(cps_ir.SetIndex node) {
    String object = formatReference(node.object);
    String index = formatReference(node.index);
    String value = formatReference(node.value);
    return 'SetIndex $object $index $value';
  }
}

/**
 * Invents (and remembers) names for Continuations, Parameters, etc.
 * The names must match the conventions used by IR Hydra, e.g.
 * Continuations and Functions must have names of form B### since they
 * are visualized as basic blocks.
 */
class Names {
  final Map<Object, String> names = {};
  final Map<String, int> counters = {
    'r': 0,
    'B': 0,
    'v': 0,
    'x': 0,
    'c': 0
  };

  String prefix(x) {
    if (x is cps_ir.Parameter) return 'r';
    if (x is cps_ir.Continuation || x is cps_ir.FunctionDefinition) return 'B';
    if (x is cps_ir.Primitive) return 'v';
    if (x is cps_ir.MutableVariable) return 'c';
    return 'x';
  }

  String name(x) {
    String nam = names[x];
    if (nam == null) {
      String pref = prefix(x);
      int id = counters[pref]++;
      nam = names[x] = '${pref}${id}';
    }
    return nam;
  }
}

/**
 * A vertex in the graph visualization, used in place of basic blocks.
 */
class Block {
  String name;
  final List<cps_ir.Parameter> parameters;
  final cps_ir.Expression body;
  final List<Block> succ = <Block>[];
  final List<Block> pred = <Block>[];

  Block(this.name, this.parameters, this.body);

  void addEdgeTo(Block successor) {
    succ.add(successor);
    successor.pred.add(this);
  }
}

class BlockCollector implements cps_ir.Visitor {
  final Map<cps_ir.Continuation, Block> cont2block =
      <cps_ir.Continuation, Block>{};
  final Set<Block> entries = new Set<Block>();
  Block currentBlock;

  Names names;
  BlockCollector(this.names);

  Block getBlock(cps_ir.Continuation c) {
    Block block = cont2block[c];
    if (block == null) {
      block = new Block(names.name(c), c.parameters, c.body);
      cont2block[c] = block;
    }
    return block;
  }

  visit(cps_ir.Node node) => node.accept(this);

  visitFunctionDefinition(cps_ir.FunctionDefinition node) {
    currentBlock = new Block(names.name(node), [], node.body);
    entries.add(currentBlock);
    visit(node.body);
  }

  visitLetPrim(cps_ir.LetPrim exp) {
    visit(exp.body);
  }

  visitLetCont(cps_ir.LetCont exp) {
    exp.continuations.forEach(visit);
    visit(exp.body);
  }

  visitLetHandler(cps_ir.LetHandler exp) {
    visit(exp.handler);
    visit(exp.body);
  }

  visitLetMutable(cps_ir.LetMutable exp) {
    visit(exp.body);
  }

  void addEdgeToContinuation(cps_ir.Reference continuation) {
    cps_ir.Definition target = continuation.definition;
    if (target is cps_ir.Continuation && !target.isReturnContinuation) {
      currentBlock.addEdgeTo(getBlock(target));
    }
  }

  visitInvokeContinuation(cps_ir.InvokeContinuation exp) {
    addEdgeToContinuation(exp.continuation);
  }

  visitInvokeStatic(cps_ir.InvokeStatic exp) {
    addEdgeToContinuation(exp.continuation);
  }

  visitInvokeMethod(cps_ir.InvokeMethod exp) {
    addEdgeToContinuation(exp.continuation);
  }

  visitInvokeMethodDirectly(cps_ir.InvokeMethodDirectly exp) {
    addEdgeToContinuation(exp.continuation);
  }

  visitInvokeConstructor(cps_ir.InvokeConstructor exp) {
    addEdgeToContinuation(exp.continuation);
  }

  visitThrow(cps_ir.Throw exp) {
  }

  visitRethrow(cps_ir.Rethrow exp) {
  }

  visitUnreachable(cps_ir.Unreachable node) {
  }

  visitGetLazyStatic(cps_ir.GetLazyStatic exp) {
    addEdgeToContinuation(exp.continuation);
  }

  visitBranch(cps_ir.Branch exp) {
    cps_ir.Continuation trueTarget = exp.trueContinuation.definition;
    if (!trueTarget.isReturnContinuation) {
      currentBlock.addEdgeTo(getBlock(trueTarget));
    }
    cps_ir.Continuation falseTarget = exp.falseContinuation.definition;
    if (!falseTarget.isReturnContinuation) {
      currentBlock.addEdgeTo(getBlock(falseTarget));
    }
  }

  visitTypeCast(cps_ir.TypeCast exp) {
    addEdgeToContinuation(exp.continuation);
  }

  visitContinuation(cps_ir.Continuation c) {
    var old_node = currentBlock;
    currentBlock = getBlock(c);
    visit(c.body);
    currentBlock = old_node;
  }

  // Primitives and conditions are not visited when searching for blocks.
  unexpectedNode(cps_ir.Node node) {
    throw "The IR tracer's block collector reached an unexpected IR "
        "instruction: $node";
  }

  visitLiteralList(cps_ir.LiteralList node) {
    unexpectedNode(node);
  }

  visitLiteralMap(cps_ir.LiteralMap node) {
    unexpectedNode(node);
  }

  visitConstant(cps_ir.Constant node) {
    unexpectedNode(node);
  }

  visitCreateFunction(cps_ir.CreateFunction node) {
    unexpectedNode(node);
  }

  visitGetMutable(cps_ir.GetMutable node) {
    unexpectedNode(node);
  }

  visitParameter(cps_ir.Parameter node) {
    unexpectedNode(node);
  }

  visitMutableVariable(cps_ir.MutableVariable node) {
    unexpectedNode(node);
  }

  visitGetField(cps_ir.GetField node) {
    unexpectedNode(node);
  }

  visitGetStatic(cps_ir.GetStatic node) {
    unexpectedNode(node);
  }

  visitCreateBox(cps_ir.CreateBox node) {
    unexpectedNode(node);
  }

  visitCreateInstance(cps_ir.CreateInstance node) {
    unexpectedNode(node);
  }

  visitIsTrue(cps_ir.IsTrue node) {
    unexpectedNode(node);
  }

  visitInterceptor(cps_ir.Interceptor node) {
    unexpectedNode(node);
  }

  visitReadTypeVariable(cps_ir.ReadTypeVariable node) {
    unexpectedNode(node);
  }

  visitReifyRuntimeType(cps_ir.ReifyRuntimeType node) {
    unexpectedNode(node);
  }

  visitTypeExpression(cps_ir.TypeExpression node) {
    unexpectedNode(node);
  }

  visitCreateInvocationMirror(cps_ir.CreateInvocationMirror node) {
    unexpectedNode(node);
  }

  visitTypeTest(cps_ir.TypeTest node) {
    unexpectedNode(node);
  }

  visitApplyBuiltinOperator(cps_ir.ApplyBuiltinOperator node) {
    unexpectedNode(node);
  }

  visitGetLength(cps_ir.GetLength node) {
    unexpectedNode(node);
  }

  visitGetIndex(cps_ir.GetIndex node) {
    unexpectedNode(node);
  }

  visitSetIndex(cps_ir.SetIndex node) {
    unexpectedNode(node);
  }

  visitSetMutable(cps_ir.SetMutable node) {
    unexpectedNode(node);
  }

  visitSetField(cps_ir.SetField node) {
    unexpectedNode(node);
  }

  visitSetStatic(cps_ir.SetStatic node) {
    unexpectedNode(node);
  }

  @override
  visitForeignCode(cps_ir.ForeignCode node) {
    addEdgeToContinuation(node.continuation);
  }
}
