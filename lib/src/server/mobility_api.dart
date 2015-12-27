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

library code_mobility.server.api;

import 'dart:async';

import 'package:rpc/rpc.dart';

import '../helper/standalone_helper.dart';
import '../taskrunner/task.dart';
import '../taskrunner/taskrunner.dart';

const pathExec = 'exec';
const pathTaskList = 'tasks';
const pathREV = 'rev';
const pathREVFetch = 'fetch';

@ApiClass(name: 'mobilityapi', version: 'v1')
class MobilityAPI {
  final TaskRunner _runner;
  TaskList _taskList;
  String _taskDir;

  MobilityAPI(TaskRunner this._runner, List<Task> tasks, String codResource, String this._taskDir) {
    tasks = tasks != null ? tasks : [];
    _taskList = new TaskList(tasks, codResource);
  }

  @ApiMethod(method: 'POST', path: pathREV, description: 'Remote evaluation with source string and data')
  Future<StringResponse> remoteEvaluation(REVRequest request) async {
    dynamic result = await _runner.executeFromSourceString(request.source, request.args);
    return _checkForErrors(result);
  }

  @ApiMethod(method: 'POST', path: pathREVFetch, description: 'Remote evaluation with source fetch')
  Future<StringResponse> remoteEvaluationWithFetch(REVFetchRequest request) async {
    Uri uri = Uri.parse(request.href);
    dynamic result = await _runner.execute(uri, request.args);
    return _checkForErrors(result);
  }

  @ApiMethod(method: 'POST', path: pathExec, description: 'Executes local code with the given data')
  Future<StringResponse> executeWitLocalCode(ExecWithLocalRequest request) async {
    String resourcePath = StandaloneHelper.getLocalTaskPath(_taskDir, request.filename);
    dynamic result = await _runner.execute(Uri.parse(resourcePath), request.args);
    return _checkForErrors(result);
  }

  @ApiMethod(path: pathTaskList, description: 'Lists all available tasks with their metadata and the cod resource')
  TaskList listAvailableTasks() {
    return _taskList;
  }

  StringResponse _checkForErrors(dynamic result) {
    if (result is TaskError) {
      throw new BadRequestError('${result.message}');
    }
    return new StringResponse(result.toString());
  }
}

class REVRequest {
  @ApiProperty(required: true)
  String source;

  @ApiProperty()
  List<String> args;
}

class REVFetchRequest {
  @ApiProperty(required: true)
  String href;

  @ApiProperty()
  List<String> args;
}

class ExecWithLocalRequest {
  @ApiProperty(required: true)
  String filename;

  @ApiProperty()
  List<String> args;
}


class StringResponse {
  final String response;

  const StringResponse(this.response);
}

class TaskList {
  final List<Task> tasks;
  final String codResource;

  TaskList(this.tasks, this.codResource);
}
