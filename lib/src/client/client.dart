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

/// Abstract client that provides an interface for all client implementations.
abstract class Client {
  /// The address of the server. For example an IPv4 address (127.0.0.1) or domain name (dbaelz.de).
  var addressServer;
  /// The port for the connection. For example the port 8080.
  int portServer;
  TaskRunner runner;
  String baseUrl;
  String execUrl;
  String codUrl;
  String revUrl;
  String fetchUrl;
  String codResource = 'cod';

  /// Creates a new client with the given connection information and a [TaskRunner] implementation.
  Client(this.addressServer, int this.portServer, String apiName, String apiVersion, TaskRunner this.runner) {
    baseUrl = 'http://$addressServer:$portServer/';
    execUrl = '$baseUrl/$apiName/$apiVersion/exec';
    codUrl = '$baseUrl/$apiName/$apiVersion/cod';
    revUrl = '$baseUrl/$apiName/$apiVersion/rev';
    fetchUrl = '$baseUrl/$apiName/$apiVersion/fetch';
  }

  /// Returns the url of the code on demand resources on the server (http://server:port/cod).
  String get codResourceUrl;

  /// Returns a [:Future<List<Task>>:] that completes with a list available code on demand tasks fetched from the server.
  Future<List<Task>> retrieveCodTasks();

  /// Returns a [:Future<String>:] that completes with the result of a local task execution.
  Future<String> executeLocal(String taskDir, String filename, List<String> args);

  /// Returns a [:Future<String>:] that completes with the result of a remote task execution.
  Future<String> executeRemote(String filename, List<String> args);

  /// Returns a [:Future<String>:] that completes with the result of code on demand task execution.
  Future<String> codeOnDemand(String filename, List<String> args);

  /// Returns a [:Future<String>:] that completes with the result of a remote evaluation task execution.
  ///
  /// In this method the server fetches the required source code from [href].
  Future<String> remoteEvaluationWithFetch(String href, List<String> args);

  /// Returns a [:Future<String>:] that completes with the result of a remote evaluation task execution.
  ///
  /// In this method the required source code is sent with the data.
  Future<String> remoteEvaluationWithSource(String taskDir, String filename, List<String> args);
}
