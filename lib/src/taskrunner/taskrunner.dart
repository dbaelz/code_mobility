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

library code_mobility.taskrunner;

import 'dart:async';

const executionError = 'Incorrect or incomplete data';
const notSupportedError = 'This functionality is not supported on this platform';

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