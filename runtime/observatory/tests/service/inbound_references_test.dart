// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// VMOptions=--compile_all --error_on_bad_type --error_on_bad_override

library inbound_references_test;

import 'package:observatory/service_io.dart';
import 'package:unittest/unittest.dart';
import 'test_helper.dart';

class Node {
  var edge;
}

class Edge { }

var n, e, array;

void script() {
  n = new Node();
  e = new Edge();
  n.edge = e;
  array = new List(2);
  array[0] = n;
  array[1] = e;
}

var tests = [

  (Isolate isolate) async {
    var lib = await isolate.rootLibrary.load();
    var field = lib.variables.where((v) => v.name == 'e').single;
    await field.load();
    Instance e = field.staticValue;
    ServiceMap response = await isolate.getInboundReferences(e, 100);
    List references = response['references'];
    hasReferenceSuchThat(predicate) {
      expect(references.any(predicate), isTrue);
    }

    // Assert e is referenced by at least n, array, and the top-level
    // field e.
    hasReferenceSuchThat((r) => r['slot'] is Field &&
                         r['slot'].name=='edge' &&
                         r['source'].isInstance &&
                         r['source'].clazz.name=='Node');
    hasReferenceSuchThat((r) => r['slot'] == 1 &&
                         r['source'].isList);
    hasReferenceSuchThat((r) => r['slot']=='<unknown>' &&
                         r['source'] is Field);
  }

];

main(args) => runIsolateTests(args, tests, testeeBefore: script);
