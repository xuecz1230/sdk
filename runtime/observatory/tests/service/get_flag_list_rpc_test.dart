// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// VMOptions=--compile_all --error_on_bad_type --error_on_bad_override

import 'package:observatory/service_io.dart';
import 'package:unittest/unittest.dart';

import 'test_helper.dart';

var tests = [
  (VM vm) async {
    var result = await vm.invokeRpcNoUpgrade('getFlagList', {});
    expect(result['type'], equals('FlagList'));
    // TODO(turnidge): Make this test a bit beefier.
  },

  // Modify a flag which does not exist.
  (VM vm) async {
    // Modify a flag.
    var params = {
      'name' : 'does_not_really_exist',
      'value' : 'true',
    };
    var result = await vm.invokeRpcNoUpgrade('_setFlag', params);
    expect(result['type'], equals('Error'));
    expect(result['message'], equals('Cannot set flag: flag not found'));
  },

  // Modify a flag with the wrong value type.
  (VM vm) async {
    // Modify a flag.
    var params = {
      'name' : 'trace_isolates',
      'value' : '123',
    };
    var result = await vm.invokeRpcNoUpgrade('_setFlag', params);
    expect(result['type'], equals('Error'));
    expect(result['message'], equals('Cannot set flag: invalid value'));
  },
];

main(args) async => runVMTests(args, tests);
