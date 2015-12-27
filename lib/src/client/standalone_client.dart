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

library code_mobility.client.standalone;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'client.dart';
import '../helper/standalone_helper.dart';
import '../taskrunner/task.dart';
import '../taskrunner/taskrunner.dart';

/// Client implementation for the standalone vm.
class StandaloneClient extends Client {
  StandaloneClient(addressServer, int portServer, String apiName, String apiVersion, TaskRunner runner)
      : super(addressServer, portServer, apiName, apiVersion, runner);

  @override
  String get codResourceUrl => '${baseUrl}${codResource}';

  @override
  Future<List<Task>> retrieveTaskList() async {
    http.Response response = await http.get(taskListUrl);

    List<Task> tasks = [];
    var decoded = JSON.decode(response.body);
    if (decoded.containsKey('codResource')) {
      codResource = decoded['codResource'];
    }
    if (decoded.containsKey('tasks')) {
      List data = decoded['tasks'];
      data.forEach((Map element) {
        tasks.add(new Task(name: element['name'], resource: element['resource'], description: element['description']));
      });
    }
    return tasks;
  }

  @override
  Future<String> executeLocal(String taskDir, String filename, List<String> args) async {
    String resourcePath = StandaloneHelper.getLocalTaskPath(taskDir, filename);
    var result = await runner.execute(Uri.parse(resourcePath), args);
    return _checkRunnerResult(result);
  }

  @override
  Future<String> executeRemote(String filename, List<String> args) async {
    String body = '{"filename":"${filename}","args":${JSON.encode(args)}}';
    http.Response response = await http.post(execUrl, body: body);
    return _checkJSONResult(response.body);
  }

  @override
  Future<String> codeOnDemand(String filename, List<String> args) async {
    String url = '${codResourceUrl}/${filename}';
    var result = await runner.execute(Uri.parse(url), args);
    return _checkRunnerResult(result);
  }

  @override
  Future<String> remoteEvaluationWithFetch(String href, List<String> args) async {
    String body = '{"href":"${href}","args":${JSON.encode(args)}}';
    http.Response response = await http.post(fetchUrl, body: body);
    return _checkJSONResult(response.body);
  }

  @override
  Future<String> remoteEvaluationWithSource(String taskDir, String filename, List<String> args) async {
    String source = await StandaloneHelper.getLocalTaskAsJSON(taskDir, filename);
    String body = '{"source":${source},"args":${JSON.encode(args)}}';
    http.Response response = await http.post(revUrl, body: body);
    return _checkJSONResult(response.body);
  }

  dynamic _checkRunnerResult(dynamic result) {
    if (result is TaskError) {
      return result.message;
    }
    return result.toString();
  }

  String _checkJSONResult(String body) {
    var decoded = JSON.decode(body);
    if (decoded.containsKey('response')) {
      return decoded['response'];
    } else if (decoded.containsKey('error') && decoded['error'].containsKey('message')) {
      var error = decoded['error'];
      return error['message'];
    } else {
      return body;
    }
  }
}
