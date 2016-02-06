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

library code_mobility.example.dart2js;

import 'dart:html';

import 'package:code_mobility/code_mobility.dart';
import 'package:code_mobility/dart2js.dart';

//Hostname of the server
const String hostname = 'localhost';

main() async {
  //Initialize dart2js client for a server running with default server config on localhost.
  Dart2JSClient client = new Dart2JSClient(hostname, 8080, false, 'mobilityapi', 'v1', new DefaultTaskRunner());

  //Retrieve the available code on demand tasks and the path to the resources cod resources
  //The path is 'cod', so the resource address is http://localhost:8080/cod/{resource})
  List<Task> tasks = await client.retrieveTaskList();
  tasks.forEach((task) => print(task.resource));

  //Filename of the task
  String fibonacciFilename = tasks.where((task) => task.resource == 'fibonacci.dart').first.resource;
  //The arguments (data) for the task
  List<String> args = ['123'];

  //Executes the task on the local (client) device.
  //The task must be available as filename.dart.js file in the tasks directory.
  String local = 'Local: ${await client.executeLocal('tasks', fibonacciFilename, args)}';
  print(local);
  document.body.append(new Element.div()..setInnerHtml(local));

  //Executes the task on the remote (server) device. The source is already on the device.
  String remote = 'Remote: ${await client.executeRemote(fibonacciFilename, args)}';
  print(remote);
  document.body.append(new Element.div()..setInnerHtml(remote));

  //Fetch the source from the server and execute the task on the local device.
  //The task must be available as filename.dart.js file in the tasks directory of the server.
  String cod = 'Code on demand: ${await client.codeOnDemand(fibonacciFilename, args)}';
  print(cod);
  document.body.append(new Element.div()..setInnerHtml(cod));

  //Executes the task on the remote (server) device.
  //The source code is fetched by the server (with cod) from a third (code delivery) server.
  //It must be available as filename.dart.js in the tasks directory of the code delivery server.
  String cdServer = 'http://$hostname:4040/repository/';
  String revFetch = 'Remote evaluation with fetch: ${await client.remoteEvaluationWithFetch(cdServer + fibonacciFilename, args)}';
  print(revFetch);
  document.body.append(new Element.div()..setInnerHtml(revFetch));

  //Sends the source code as string to the remote device. There it's executed.
  //Currently only the task without the imports/dependencies is sent. Therefore it's only suitable for very simple tasks.
  //The file must be available as *.dart file.
  String rev = 'Remote evaluation with source: ${await client.remoteEvaluationWithSource('tasks', fibonacciFilename, args)}';
  print(rev);
  document.body.append(new Element.div()..setInnerHtml(rev));
}