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

library code_mobility.client.dart2js;

import 'dart:async';
import 'dart:convert';

import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

import 'client.dart';
import '../taskrunner/task.dart';
import '../taskrunner/taskrunner.dart';

/// Client implementation for the browser, compiled to JavaScript with dart2js.
class Dart2JSClient extends Client {
  Dart2JSClient(addressServer, int portServer, String apiName, String apiVersion, TaskRunner runner)
  : super(addressServer, portServer, apiName, apiVersion, runner);

  @override
  String get codResourceUrl => '${baseUrl}${codResource}';

  @override
  Future<List<Task>> retrieveTaskList() async {
    var client = new BrowserClient();
    http.Response response = await client.get(taskListUrl);

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
    var result = await runner.execute(Uri.parse('${taskDir}/${filename}'), args);
    return result;
  }

  @override
  Future<String> executeRemote(String filename, List<String> args) async {
    var client = new BrowserClient();
    String body = '{"filename":"${filename}","args":${JSON.encode(args)}}';
    http.Response response = await client.post(execUrl, body: body);
    return _checkJSONResult(response.body);
  }

  @override
  Future<String> codeOnDemand(String filename, List<String> args) async {
    var client = new BrowserClient();
    String url = '${codResourceUrl}/${filename}.js';
    http.Response response = await client.get(url);
    var result = await runner.executeFromSourceString(response.body, args);
    return _checkRunnerResult(result);
  }

  @override
  Future<String> remoteEvaluationWithFetch(String href, List<String> args) async {
    var client = new BrowserClient();
    String body = '{"href":"${href}","args":${JSON.encode(args)}}';
    http.Response response = await client.post(fetchUrl, body: body);
    return _checkJSONResult(response.body);
  }

  @override
  Future<String> remoteEvaluationWithSource(String taskDir, String filename, List<String> args) async {
    var client = new BrowserClient();
    http.Response file = await client.get('${taskDir}/${filename}');
    String source = JSON.encode(file.body);
    String body = '{"source":${source},"args":${JSON.encode(args)}}';
    http.Response response = await client.post(revUrl, body: body);
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
    } else {
      return body;
    }
  }
}