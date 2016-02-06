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
  String taskListUrl;
  String revUrl;
  String fetchUrl;
  String codResource = 'cod';

  /// Creates a new client with the given connection information and a [TaskRunner] implementation.
  Client(this.addressServer, int this.portServer, bool https, String apiName, String apiVersion, TaskRunner this.runner) {
    String protocol = https ? 'https' : 'http';
    baseUrl = '${protocol}://$addressServer:$portServer/';
    execUrl = '$baseUrl/$apiName/$apiVersion/exec';
    taskListUrl = '$baseUrl/$apiName/$apiVersion/tasks';
    revUrl = '$baseUrl/$apiName/$apiVersion/rev';
    fetchUrl = '$baseUrl/$apiName/$apiVersion/fetch';
  }

  /// Returns the url of the code on demand resources on the server (protocol://server:port/cod).
  String get codResourceUrl;

  /// Returns a [:Future<List<Task>>:] that completes with a list of available tasks fetched from the server.
  Future<List<Task>> retrieveTaskList();

  /// Returns a [:Future<String>:] that completes with the result of a local execution.
  Future<String> executeLocal(String taskDir, String filename, List<String> args);

  /// Returns a [:Future<String>:] that completes with the result of a remote execution.
  Future<String> executeRemote(String filename, List<String> args);

  /// Returns a [:Future<String>:] that completes with the result of code on demand execution.
  Future<String> codeOnDemand(String filename, List<String> args);

  /// Returns a [:Future<String>:] that completes with the result of a remote evaluation execution.
  ///
  /// In this method the server fetches the required source code from [href].
  Future<String> remoteEvaluationWithFetch(String href, List<String> args);

  /// Returns a [:Future<String>:] that completes with the result of a remote evaluation execution.
  ///
  /// In this method the required source code is sent with the data.
  Future<String> remoteEvaluationWithSource(String taskDir, String filename, List<String> args);
}
