// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Interact with developer tools such as the debugger and inspector.
///
/// The dart:developer library is _unstable_ and its API might change slightly
/// as a result of developer feedback. This library is platform dependent and
/// therefore it has implementations for both dart2js and the Dart VM. Both are
/// under development and may not support all operations yet.
///
library dart.developer;

import 'dart:async';
import 'dart:convert';

part 'profiler.dart';

/// If [when] is true, stop the program as if a breakpoint were hit at the
/// following statement.
///
/// Returns the value of [when]. Some debuggers may
/// display [msg].
///
/// NOTE: When invoked, the isolate will not return until a debugger
/// continues execution. When running in the Dart VM the behaviour is the same
/// regardless of whether or not a debugger is connected. When compiled to
/// JavaScript, this uses the "debugger" statement, and behaves exactly as
/// that does.
external bool debugger({bool when: true, String msg});

/// Send a reference to [object] to any attached debuggers.
///
/// Debuggers may open an inspector on the object. Returns the argument.
external inspect(object);

/// Emit a log event.
/// [sequenceNumber] is a monotonically increasing sequence number.
/// [millisececondsSinceEpoch] is a timestamp.
/// [level] is the severity level (value between 0 and 2000 inclusive).
/// [name] is the name of the source of the log message.
/// [message] is the log message.
/// [zone] (optional) the zone where the log was emitted
/// [error] (optional) an error object associated with this log event.
/// [stackTrace] (optional) a stack trace associated with this log event.
external log({int sequenceNumber,
              int millisecondsSinceEpoch,
              int level,
              String name,
              String message,
              Zone zone,
              Object error,
              StackTrace stackTrace});
