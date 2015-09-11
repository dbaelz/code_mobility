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
      throw new BadRequestError('Invalid request: ${result.message}');
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
