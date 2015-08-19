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

import '../taskrunner/taskrunner.dart';

const pathREV = 'rev';
const pathCOD = 'cod';

@ApiClass(name: 'baseapi', version: 'v1')
class MobilityAPI {
  TaskRunner _runner;

  MobilityAPI(TaskRunner this._runner);

  @ApiMethod(method: 'POST', path: pathREV, description: 'Resource for remote evaluation')
  Future<StringResponse> remoteEvaluation(REVRequest request) async {
    dynamic result = await _runner.executeFromSourceString(request.source, request.args);
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

class StringResponse {
  final String response;

  const StringResponse(this.response);
}