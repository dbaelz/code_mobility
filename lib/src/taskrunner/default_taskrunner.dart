/*
 * Copyright (c) 2015, Daniel Bälz
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

library code_mobility.taskrunner.defaultimpl;

import 'dart:async';
import 'dart:isolate';

import 'taskrunner.dart';

/// Implementation of the [TaskRunner] for the standalone vm and the browser.
class DefaultTaskRunner extends TaskRunner {
  @override
  Future<dynamic> execute(Uri filename, List<String> args) {
    final completer = new Completer();
    ReceivePort receivePort = new ReceivePort();
    receivePort.listen((message) {
      receivePort.close();
      completer.complete(_handleMessage(message));
    });

    Isolate.spawnUri(filename, args, receivePort.sendPort).then((isolate){}).catchError((error) {
      completer.complete(new TaskError(executionError));
    });
    return completer.future;
  }

  @override
  Future<dynamic> executeFromSourceString(String sourcecode, List<String> args) {
    final completer = new Completer();
    ReceivePort receivePort = new ReceivePort();
    receivePort.listen((message) {
      receivePort.close();
      completer.complete(_handleMessage(message));
    });

    Uri uri = Uri.parse('data:application/dart;charset=utf-8,${Uri.encodeComponent(sourcecode)}');
    Isolate.spawnUri(uri, args, receivePort.sendPort).then((isolate){}).catchError((error) {
      completer.complete(new TaskError(executionError));
    });
    return completer.future;
  }

  _handleMessage(var message) {
    if (message is Map) {
      Map map = message;
      if (map.containsKey('result')) {
        return map['result'];
      } else if (map.containsKey('error')) {
        return new TaskError(map['error']);
      } else {
        return new TaskError(executionError);
      }
    } else {
      return new TaskError(executionError);
    }
  }
}