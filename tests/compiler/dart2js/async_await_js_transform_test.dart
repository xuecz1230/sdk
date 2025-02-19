// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import "package:compiler/src/js/js.dart";
import "package:compiler/src/js/rewrite_async.dart";
import "package:compiler/src/js_backend/js_backend.dart" show StringBackedName;

import "backend_dart/dart_printer_test.dart" show PrintDiagnosticListener;

void testTransform(String source, String expected, AsyncRewriterBase rewriter) {
  Fun fun = js(source);
  Fun rewritten = rewriter.rewrite(fun);

  JavaScriptPrintingOptions options = new JavaScriptPrintingOptions();
  SimpleJavaScriptPrintingContext context =
      new SimpleJavaScriptPrintingContext();
  Printer printer = new Printer(options, context);
  printer.visit(rewritten);
  Expect.stringEquals(expected, context.getText());
}

void testAsyncTransform(String source, String expected) {
  testTransform(source, expected, new AsyncRewriter(
      null, // The diagnostic helper should not be used in these tests.
      null,
      asyncHelper: new VariableUse("thenHelper"),
      newCompleter: new VariableUse("Completer"),
      safeVariableName: (String name) => "__$name",
      bodyName: new StringBackedName("body")));
}

void testSyncStarTransform(String source, String expected) {
  testTransform(source, expected, new SyncStarRewriter(
      null,
      null,
      endOfIteration: new VariableUse("endOfIteration"),
      newIterable: new VariableUse("newIterable"),
      yieldStarExpression: new VariableUse("yieldStar"),
      uncaughtErrorExpression: new VariableUse("uncaughtError"),
      safeVariableName: (String name) => "__$name",
      bodyName: new StringBackedName("body")));
}

main() {
  testAsyncTransform("""
function(a) async {
  print(this.x); // Ensure `this` is translated in the helper function.
  await foo();
}""", """
function(a) {
  var __goto = 0, __completer = new Completer(), __handler = 1, __currentError, __self = this;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
          print(__self.x);
          __goto = 2;
          return thenHelper(foo(), body, __completer);
        case 2:
          // returning from await.
          // implicit return
          return thenHelper(null, 0, __completer, null);
        case 1:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
  function(b) async {
    try {
      __outer: while (true) { // Overlapping label name.
        try {
          inner: while (true) {
            break __outer; // Break from untranslated loop to translated target.
            break; // break to untranslated target.
          }
          while (true) {
            return; // Return via finallies.
          }
          var __helper = await foo(); // Overlapping variable name.
        } finally {
          foo();
          continue; // Continue from finally with pending finally.
          return 2; // Return from finally with pending finally.
        }
      }
    } finally {
      return 3; // Return from finally with no pending finally.
    }
    return 4;
  }""", """
function(b) {
  var __goto = 0, __completer = new Completer(), __returnValue, __handler = 2, __currentError, __next = [], __helper;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      __outer1:
        switch (__goto) {
          case 0:
            // Function start
            __handler = 3;
          case 7:
            // while condition
            __handler = 9;
            inner:
              while (true) {
                __next = [6];
                // goto finally
                __goto = 10;
                break __outer1;
                break;
              }
            while (true) {
              __next = [1, 4];
              // goto finally
              __goto = 10;
              break __outer1;
            }
            __goto = 12;
            return thenHelper(foo(), body, __completer);
          case 12:
            // returning from await.
            __helper = __result;
            __next.push(11);
            // goto finally
            __goto = 10;
            break;
          case 9:
            // uncaught
            __next = [3];
          case 10:
            // finally
            __handler = 3;
            foo();
            // goto while condition
            __goto = 7;
            break;
            __returnValue = 2;
            __next = [1];
            // goto finally
            __goto = 4;
            break;
            // goto the next finally handler
            __goto = __next.pop();
            break;
          case 11:
            // after finally
            // goto while condition
            __goto = 7;
            break;
          case 8:
            // after while
          case 6:
            // break __outer
            __next.push(5);
            // goto finally
            __goto = 4;
            break;
          case 3:
            // uncaught
            __next = [2];
          case 4:
            // finally
            __handler = 2;
            __returnValue = 3;
            // goto return
            __goto = 1;
            break;
            // goto the next finally handler
            __goto = __next.pop();
            break;
          case 5:
            // after finally
            __returnValue = 4;
            // goto return
            __goto = 1;
            break;
          case 1:
            // return
            return thenHelper(__returnValue, 0, __completer, null);
          case 2:
            // rethrow
            return thenHelper(__currentError, 1, __completer);
        }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
function(c) async {
  var a, b, c, d, e, f;
  a = b++; // post- and preincrements.
  b = --b;
  c = (await foo()).a++;
  d = ++(await foo()).a;
  e = foo1()[await foo2()]--;
  f = --foo1()[await foo2()];
}""", """
function(c) {
  var __goto = 0, __completer = new Completer(), __handler = 1, __currentError, a, b, c, d, e, f, __temp1;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
          a = b++;
          b = --b;
          __goto = 2;
          return thenHelper(foo(), body, __completer);
        case 2:
          // returning from await.
          c = __result.a++;
          __goto = 3;
          return thenHelper(foo(), body, __completer);
        case 3:
          // returning from await.
          d = ++__result.a;
          __temp1 = foo1();
          __goto = 4;
          return thenHelper(foo2(), body, __completer);
        case 4:
          // returning from await.
          e = __temp1[__result]--;
          __temp1 = foo1();
          __goto = 5;
          return thenHelper(foo2(), body, __completer);
        case 5:
          // returning from await.
          f = --__temp1[__result];
          // implicit return
          return thenHelper(null, 0, __completer, null);
        case 1:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
  function(d2) async {
    var a, b, c, d, e, f, g, h; // empty initializer
    a = foo1() || await foo2(); // short circuiting operators
    b = await foo1() || foo2();
    c = await foo1() || foo3(await foo2());
    d = foo1() || foo2();
    e = foo1() && await foo2();
    f = await foo1() && foo2();
    g = await foo1() && await foo2();
    h = foo1() && foo2();
  }""", """
function(d2) {
  var __goto = 0, __completer = new Completer(), __handler = 1, __currentError, a, b, c, d, e, f, g, h, __temp1;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
          __temp1 = foo1();
          if (__temp1)
            __result = __temp1;
          else {
            // goto then
            __goto = 2;
            break;
          }
          // goto join
          __goto = 3;
          break;
        case 2:
          // then
          __goto = 4;
          return thenHelper(foo2(), body, __completer);
        case 4:
          // returning from await.
        case 3:
          // join
          a = __result;
          __goto = 5;
          return thenHelper(foo1(), body, __completer);
        case 5:
          // returning from await.
          b = __result || foo2();
          __goto = 8;
          return thenHelper(foo1(), body, __completer);
        case 8:
          // returning from await.
          __temp1 = __result;
          if (__temp1)
            __result = __temp1;
          else {
            // goto then
            __goto = 6;
            break;
          }
          // goto join
          __goto = 7;
          break;
        case 6:
          // then
          __temp1 = foo3;
          __goto = 9;
          return thenHelper(foo2(), body, __completer);
        case 9:
          // returning from await.
          __result = __temp1(__result);
        case 7:
          // join
          c = __result;
          d = foo1() || foo2();
          __temp1 = foo1();
          if (__temp1) {
            // goto then
            __goto = 10;
            break;
          } else
            __result = __temp1;
          // goto join
          __goto = 11;
          break;
        case 10:
          // then
          __goto = 12;
          return thenHelper(foo2(), body, __completer);
        case 12:
          // returning from await.
        case 11:
          // join
          e = __result;
          __goto = 13;
          return thenHelper(foo1(), body, __completer);
        case 13:
          // returning from await.
          f = __result && foo2();
          __goto = 16;
          return thenHelper(foo1(), body, __completer);
        case 16:
          // returning from await.
          __temp1 = __result;
          if (__temp1) {
            // goto then
            __goto = 14;
            break;
          } else
            __result = __temp1;
          // goto join
          __goto = 15;
          break;
        case 14:
          // then
          __goto = 17;
          return thenHelper(foo2(), body, __completer);
        case 17:
          // returning from await.
        case 15:
          // join
          g = __result;
          h = foo1() && foo2();
          // implicit return
          return thenHelper(null, 0, __completer, null);
        case 1:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
function(x, y) async {
  while (true) {
    switch(y) { // Switch with no awaits in case key expressions
      case 0:
      case 1: 
        await foo();
        continue; // Continue the loop, not the switch
      case 1: // Duplicate case
        await foo();
        break; // Break the switch
      case 2:
        foo(); // No default
    }
  }
}""", """
function(x, y) {
  var __goto = 0, __completer = new Completer(), __handler = 1, __currentError;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
        case 2:
          // while condition
        case 4:
          // switch
          switch (y) {
            case 0:
              // goto case
              __goto = 6;
              break;
            case 1:
              // goto case
              __goto = 7;
              break;
            case 1:
              // goto case
              __goto = 8;
              break;
            case 2:
              // goto case
              __goto = 9;
              break;
            default:
              // goto after switch
              __goto = 5;
              break;
          }
          break;
        case 6:
          // case
        case 7:
          // case
          __goto = 10;
          return thenHelper(foo(), body, __completer);
        case 10:
          // returning from await.
          // goto while condition
          __goto = 2;
          break;
        case 8:
          // case
          __goto = 11;
          return thenHelper(foo(), body, __completer);
        case 11:
          // returning from await.
          // goto after switch
          __goto = 5;
          break;
        case 9:
          // case
          foo();
        case 5:
          // after switch
          // goto while condition
          __goto = 2;
          break;
        case 3:
          // after while
          // implicit return
          return thenHelper(null, 0, __completer, null);
        case 1:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
  function(f) async {
    do {
      var a = await foo();
      if (a) // If with no awaits in body
        break;
      else
        continue;
    } while (await foo());
  }
  """, """
function(f) {
  var __goto = 0, __completer = new Completer(), __handler = 1, __currentError, a;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
        case 2:
          // do body
          __goto = 5;
          return thenHelper(foo(), body, __completer);
        case 5:
          // returning from await.
          a = __result;
          if (a) {
            // goto after do
            __goto = 4;
            break;
          } else {
            // goto do condition
            __goto = 3;
            break;
          }
        case 3:
          // do condition
          __goto = 6;
          return thenHelper(foo(), body, __completer);
        case 6:
          // returning from await.
          if (__result) {
            // goto do body
            __goto = 2;
            break;
          }
        case 4:
          // after do
          // implicit return
          return thenHelper(null, 0, __completer, null);
        case 1:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
function(g) async {
  for (var i = 0; i < await foo1(); i += await foo2()) {
    if (foo(i))
      continue;
    else
      break;
    if (!foo(i)) { // If with no else and await in body.
      await foo();
      return;
    }
    print(await(foo(i)));
  } 
}
""", """
function(g) {
  var __goto = 0, __completer = new Completer(), __returnValue, __handler = 2, __currentError, i, __temp1;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
          i = 0;
        case 3:
          // for condition
          __temp1 = i;
          __goto = 6;
          return thenHelper(foo1(), body, __completer);
        case 6:
          // returning from await.
          if (!(__temp1 < __result)) {
            // goto after for
            __goto = 5;
            break;
          }
          if (foo(i)) {
            // goto for update
            __goto = 4;
            break;
          } else {
            // goto after for
            __goto = 5;
            break;
          }
          __goto = !foo(i) ? 7 : 8;
          break;
        case 7:
          // then
          __goto = 9;
          return thenHelper(foo(), body, __completer);
        case 9:
          // returning from await.
          // goto return
          __goto = 1;
          break;
        case 8:
          // join
          __temp1 = print;
          __goto = 10;
          return thenHelper(foo(i), body, __completer);
        case 10:
          // returning from await.
          __temp1(__result);
        case 4:
          // for update
          __goto = 11;
          return thenHelper(foo2(), body, __completer);
        case 11:
          // returning from await.
          i += __result;
          // goto for condition
          __goto = 3;
          break;
        case 5:
          // after for
        case 1:
          // return
          return thenHelper(__returnValue, 0, __completer, null);
        case 2:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
  function(a, h) async {
    var x = {"a": foo1(), "b": await foo2(), "c": foo3()};
    x["a"] = 2; // Different assignments
    (await foo()).a = 3;
    x[await foo()] = 4;
    x[(await foo1()).a = await foo2()] = 5;
    (await foo1())[await foo2()] = await foo3(6);
  }
  """, """
function(a, h) {
  var __goto = 0, __completer = new Completer(), __handler = 1, __currentError, x, __temp1, __temp2;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
          __temp1 = foo1();
          __goto = 2;
          return thenHelper(foo2(), body, __completer);
        case 2:
          // returning from await.
          x = {a: __temp1, b: __result, c: foo3()};
          x.a = 2;
          __goto = 3;
          return thenHelper(foo(), body, __completer);
        case 3:
          // returning from await.
          __result.a = 3;
          __temp1 = x;
          __goto = 4;
          return thenHelper(foo(), body, __completer);
        case 4:
          // returning from await.
          __temp1[__result] = 4;
          __temp1 = x;
          __goto = 5;
          return thenHelper(foo1(), body, __completer);
        case 5:
          // returning from await.
          __temp2 = __result;
          __goto = 6;
          return thenHelper(foo2(), body, __completer);
        case 6:
          // returning from await.
          __temp1[__temp2.a = __result] = 5;
          __goto = 7;
          return thenHelper(foo1(), body, __completer);
        case 7:
          // returning from await.
          __temp1 = __result;
          __goto = 8;
          return thenHelper(foo2(), body, __completer);
        case 8:
          // returning from await.
          __temp2 = __result;
          __goto = 9;
          return thenHelper(foo3(6), body, __completer);
        case 9:
          // returning from await.
          __temp1[__temp2] = __result;
          // implicit return
          return thenHelper(null, 0, __completer, null);
        case 1:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
function(c, i) async {
  try {
    var x = c ? await foo() : foo(); // conditional
    var y = {};
  } catch (error) {
    try {
      x = c ? await fooError(error) : fooError(error);
    } catch (error) { // nested error handler with overlapping name
      y.x = foo(error);
    } finally {
      foo(x);
    }
  }
}
""", """
function(c, i) {
  var __goto = 0, __completer = new Completer(), __handler = 1, __currentError, __next = [], x, y, __error, __error1;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
          __handler = 3;
          __goto = c ? 6 : 8;
          break;
        case 6:
          // then
          __goto = 9;
          return thenHelper(foo(), body, __completer);
        case 9:
          // returning from await.
          // goto join
          __goto = 7;
          break;
        case 8:
          // else
          __result = foo();
        case 7:
          // join
          x = __result;
          y = {};
          __handler = 1;
          // goto after finally
          __goto = 5;
          break;
        case 3:
          // catch
          __handler = 2;
          __error = __currentError;
          __handler = 11;
          __goto = c ? 14 : 16;
          break;
        case 14:
          // then
          __goto = 17;
          return thenHelper(fooError(__error), body, __completer);
        case 17:
          // returning from await.
          // goto join
          __goto = 15;
          break;
        case 16:
          // else
          __result = fooError(__error);
        case 15:
          // join
          x = __result;
          __next.push(13);
          // goto finally
          __goto = 12;
          break;
        case 11:
          // catch
          __handler = 10;
          __error1 = __currentError;
          y.x = foo(__error1);
          __next.push(13);
          // goto finally
          __goto = 12;
          break;
        case 10:
          // uncaught
          __next = [2];
        case 12:
          // finally
          __handler = 2;
          foo(x);
          // goto the next finally handler
          __goto = __next.pop();
          break;
        case 13:
          // after finally
          // goto after finally
          __goto = 5;
          break;
        case 2:
          // uncaught
          // goto rethrow
          __goto = 1;
          break;
        case 5:
          // after finally
          // implicit return
          return thenHelper(null, 0, __completer, null);
        case 1:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
  function(x, y, j) async {
    print(await(foo(x))); // calls
    (await print)(foo(x));
    print(foo(await x));
    await (print(foo(await x)));
    print(foo(x, await y, z));
  }
  """, """
function(x, y, j) {
  var __goto = 0, __completer = new Completer(), __handler = 1, __currentError, __temp1, __temp2, __temp3;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
          __temp1 = print;
          __goto = 2;
          return thenHelper(foo(x), body, __completer);
        case 2:
          // returning from await.
          __temp1(__result);
          __goto = 3;
          return thenHelper(print, body, __completer);
        case 3:
          // returning from await.
          __result(foo(x));
          __temp1 = print;
          __temp2 = foo;
          __goto = 4;
          return thenHelper(x, body, __completer);
        case 4:
          // returning from await.
          __temp1(__temp2(__result));
          __temp1 = print;
          __temp2 = foo;
          __goto = 6;
          return thenHelper(x, body, __completer);
        case 6:
          // returning from await.
          __goto = 5;
          return thenHelper(__temp1(__temp2(__result)), body, __completer);
        case 5:
          // returning from await.
          __temp1 = print;
          __temp2 = foo;
          __temp3 = x;
          __goto = 7;
          return thenHelper(y, body, __completer);
        case 7:
          // returning from await.
          __temp1(__temp2(__temp3, __result, z));
          // implicit return
          return thenHelper(null, 0, __completer, null);
        case 1:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
function(x, y, k) async {
  while (await(foo())) {
    lab: { // labelled statement
      switch(y) {
      case 0:
        foo();
      case 0: // Duplicate case
        print(await foo1(x));
        return y;
      case await bar(): // await in case
        print(await foobar(x));
        return y;
      case x:
        if (a) {
          throw new Error();
        } else {
          continue;
        }
      default: // defaul case
        break lab; // break to label
      }
      foo();
    }
  }
}""", """
function(x, y, k) {
  var __goto = 0, __completer = new Completer(), __returnValue, __handler = 2, __currentError, __temp1;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
        case 3:
          // while condition
          __goto = 5;
          return thenHelper(foo(), body, __completer);
        case 5:
          // returning from await.
          if (!__result) {
            // goto after while
            __goto = 4;
            break;
          }
        case 7:
          // switch
          __temp1 = y;
          if (__temp1 === 0) {
            // goto case
            __goto = 9;
            break;
          }
          if (__temp1 === 0) {
            // goto case
            __goto = 10;
            break;
          }
          __goto = 12;
          return thenHelper(bar(), body, __completer);
        case 12:
          // returning from await.
          if (__temp1 === __result) {
            // goto case
            __goto = 11;
            break;
          }
          if (__temp1 === x) {
            // goto case
            __goto = 13;
            break;
          }
          // goto default
          __goto = 14;
          break;
        case 9:
          // case
          foo();
        case 10:
          // case
          __temp1 = print;
          __goto = 15;
          return thenHelper(foo1(x), body, __completer);
        case 15:
          // returning from await.
          __temp1(__result);
          __returnValue = y;
          // goto return
          __goto = 1;
          break;
        case 11:
          // case
          __temp1 = print;
          __goto = 16;
          return thenHelper(foobar(x), body, __completer);
        case 16:
          // returning from await.
          __temp1(__result);
          __returnValue = y;
          // goto return
          __goto = 1;
          break;
        case 13:
          // case
          if (a)
            throw new Error();
          else {
            // goto while condition
            __goto = 3;
            break;
          }
        case 14:
          // default
          // goto break lab
          __goto = 6;
          break;
        case 8:
          // after switch
          foo();
        case 6:
          // break lab
          // goto while condition
          __goto = 3;
          break;
        case 4:
          // after while
        case 1:
          // return
          return thenHelper(__returnValue, 0, __completer, null);
        case 2:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
  function(l) async {
    switch(await l) {
      case 1:
        print(1);
        break;
      case 2:
        print(1);
        // Fallthrough
      default:
        print(2);
        break;
    }
  }""", """
function(l) {
  var __goto = 0, __completer = new Completer(), __handler = 1, __currentError;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
          __goto = 2;
          return thenHelper(l, body, __completer);
        case 2:
          // returning from await.
          switch (__result) {
            case 1:
              print(1);
              break;
            case 2:
              print(1);
            default:
              print(2);
              break;
          }
          // implicit return
          return thenHelper(null, 0, __completer, null);
        case 1:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testAsyncTransform("""
  function(m) async {
    var exception = 1;
    try {
      await 42;
      throw 42;
    } catch (exception) {
      exception = await 10;
      exception += await 10;
      exception++;
      exception--;
      ++exception;
      --exception;
      exception += 10;
    }
    print(exception);
  }""", """
function(m) {
  var __goto = 0, __completer = new Completer(), __handler = 1, __currentError, __next = [], exception, __exception;
  function body(__errorCode, __result) {
    if (__errorCode === 1) {
      __currentError = __result;
      __goto = __handler;
    }
    while (true)
      switch (__goto) {
        case 0:
          // Function start
          exception = 1;
          __handler = 3;
          __goto = 6;
          return thenHelper(42, body, __completer);
        case 6:
          // returning from await.
          throw 42;
          __handler = 1;
          // goto after finally
          __goto = 5;
          break;
        case 3:
          // catch
          __handler = 2;
          __exception = __currentError;
          __goto = 7;
          return thenHelper(10, body, __completer);
        case 7:
          // returning from await.
          __exception = __result;
          __goto = 8;
          return thenHelper(10, body, __completer);
        case 8:
          // returning from await.
          __exception += __result;
          __exception++;
          __exception--;
          ++__exception;
          --__exception;
          __exception += 10;
          // goto after finally
          __goto = 5;
          break;
        case 2:
          // uncaught
          // goto rethrow
          __goto = 1;
          break;
        case 5:
          // after finally
          print(exception);
          // implicit return
          return thenHelper(null, 0, __completer, null);
        case 1:
          // rethrow
          return thenHelper(__currentError, 1, __completer);
      }
  }
  return thenHelper(null, body, __completer, null);
}""");

  testSyncStarTransform("""
function(a) sync* {
  // Ensure that return of a value is treated as first evaluating the value, and
  // then returning.
  return foo();
}""", """
function(__a) {
  return new newIterable(function() {
    var a = __a;
    var __goto = 0, __handler = 2, __currentError;
    return function body(__errorCode, __result) {
      if (__errorCode === 1) {
        __currentError = __result;
        __goto = __handler;
      }
      while (true)
        switch (__goto) {
          case 0:
            // Function start
            foo();
            // goto return
            __goto = 1;
            break;
          case 1:
            // return
            return endOfIteration();
          case 2:
            // rethrow
            return uncaughtError(__currentError);
        }
    };
  });
}""");
}
