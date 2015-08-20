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

import '../taskrunner/task.dart';
import '../taskrunner/taskrunner.dart';

const pathREV = 'rev';
const pathREVFetch = 'fetch';
const pathCOD = 'cod';

@ApiClass(name: 'mobilityapi', version: 'v1')
class MobilityAPI {
  final TaskRunner _runner;
  CodInformation _codInformation;

  MobilityAPI(TaskRunner this._runner, List<Task> tasks, String codResource) {
    tasks = tasks != null ? tasks : [];
    _codInformation = new CodInformation(tasks, codResource);
  }

  @ApiMethod(method: 'POST', path: pathREV, description: 'Remote evaluation with source string and data')
  Future<StringResponse> remoteEvaluation(REVRequest request) async {
    dynamic result = await _runner.executeFromSourceString(request.source, request.args);
    if (result is TaskError) {
      throw new BadRequestError('Invalid request: ${result.message}');
    }
    return new StringResponse(result.toString());
  }

  @ApiMethod(method: 'POST', path: pathREVFetch, description: 'Remote evaluation with source fetch')
  Future<StringResponse> remoteEvaluationWithFetch(REVFetchRequest request) async {
    Uri uri = Uri.parse(request.href);
    dynamic result = await _runner.execute(uri, request.args);
    if (result is TaskError) {
      throw new BadRequestError('Invalid request: ${result.message}');
    }
    return new StringResponse(result.toString());
  }

  @ApiMethod(path: pathCOD, description: 'Lists all available tasks for code on demand')
  CodInformation codeOnDemand() {
    return _codInformation;
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

class StringResponse {
  final String response;

  const StringResponse(this.response);
}

class CodInformation {
  final List<Task> tasks;
  final String codResource;

  CodInformation(this.tasks, this.codResource);
}
