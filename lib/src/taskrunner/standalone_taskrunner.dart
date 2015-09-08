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

library code_mobility.taskrunner.standalone;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:uuid/uuid.dart';

import 'taskrunner.dart';

const executionError = 'Incorrect or incomplete data';

/// Implementation of the [TaskRunner] for the standalone vm.
class StandaloneTaskRunner extends TaskRunner {
  @override
  Future<dynamic> execute(Uri filename, List<String> args) {
    final completer = new Completer();
    ReceivePort receivePort = new ReceivePort();
    receivePort.listen((message) {
      receivePort.close();
      completer.complete(message);
    });

    Isolate.spawnUri(filename, args, receivePort.sendPort).then((isolate){}).catchError((error) {
      completer.complete(new TaskError(executionError));
    });
    return completer.future;
  }

  @override
  Future<dynamic> executeFromSourceString(String sourcecode, List<String> args) {
    final completer = new Completer();
    var filename = new Uuid().v4();
    var systemTempDir = Directory.systemTemp;
    new File('${systemTempDir.path}/code_mobility/${filename}').create(recursive: true).then((file) {
      file.writeAsString(sourcecode).then((file) {
        ReceivePort receivePort = new ReceivePort();
        receivePort.listen((message) {
          receivePort.close();
          file.delete();
          completer.complete(message);
        });

        Isolate.spawnUri(file.uri, args, receivePort.sendPort).then((isolate){}).catchError((error) {
          completer.complete(new TaskError(executionError));
        });
      });
    });
    return completer.future;
  }
}