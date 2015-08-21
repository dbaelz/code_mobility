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

library code_mobility.client;

import 'dart:async';

import '../taskrunner/task.dart';
import '../taskrunner/taskrunner.dart';

abstract class Client {
  var addressServer;
  int portServer;
  TaskRunner runner;
  String baseUrl;
  String execUrl;
  String codUrl;
  String revUrl;
  String fetchUrl;
  String codResource = 'cod';

  Client(this.addressServer, int this.portServer, String apiName, String apiVersion, TaskRunner this.runner) {
    baseUrl = 'http://$addressServer:$portServer/';
    execUrl = '$baseUrl/$apiName/$apiVersion/exec';
    codUrl = '$baseUrl/$apiName/$apiVersion/cod';
    revUrl = '$baseUrl/$apiName/$apiVersion/rev';
    fetchUrl = '$baseUrl/$apiName/$apiVersion/fetch';
  }

  String get codResourceUrl;

  Future<List<Task>> retrieveCodTasks();

  Future<String> executeLocal(String taskDir, String filename, List<String> args);

  Future<String> executeRemote(String filename, List<String> args);

  Future<String> codeOnDemand(String filename, List<String> args);

  Future<String> remoteEvaluationWithFetch(String href, List<String> args);

  Future<String> remoteEvaluationWithSource(String taskDir, String filename, List<String> args);
}