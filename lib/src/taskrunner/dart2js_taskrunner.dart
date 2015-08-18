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

library code_mobility.taskrunner.dart2js;

import 'dart:async';

import 'taskrunner.dart';

class Dart2JSTaskRunner extends TaskRunner {
  @override
  Future<dynamic> execute(Uri filename, List<String> args) {
    //TODO: Add implementation
    Completer completer = new Completer()
      ..complete(null);
    return completer.future;
  }

  @override
  Future<dynamic> executeFromSourceString(String sourcecode, List<String> args) {
    //TODO: Add implementation
    Completer completer = new Completer()
      ..complete(null);
    return completer.future;
  }
}