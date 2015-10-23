/*
 * Copyright 2015 Daniel Bälz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
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