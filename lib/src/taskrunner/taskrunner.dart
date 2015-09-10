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

library code_mobility.taskrunner;

import 'dart:async';

const executionError = 'Incorrect or incomplete data';

/// Abstract class of a task runner, which executes a task.
abstract class TaskRunner {
  /// Executes the task with the [filename] and the [args] data.
  Future<dynamic> execute(Uri filename, List<String> args);

  /// Executes the task with the [sourcecode] and the [args] data.
  Future<dynamic> executeFromSourceString(String sourcecode, List<String> args);
}

/// This task runner is inactive and returns only an information about its status.
class InactiveTaskRunner extends TaskRunner {
  @override
  Future execute(Uri filename, List<String> args) {
    return new Future.value("TaskRunner inactive");
  }

  @override
  Future executeFromSourceString(String sourcecode, List<String> args) {
    return new Future.value("TaskRunner inactive");
  }
}

/// Error object for invalid task executions.
class TaskError {
  String message;

  TaskError(this.message);
}