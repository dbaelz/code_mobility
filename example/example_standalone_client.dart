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

library code_mobility.example.client;

import 'package:code_mobility/code_mobility.dart';
import 'package:code_mobility/standalone.dart';

main() async {
  //Initialize standalone client for a server running with default server config on localhost
  StandaloneClient client = new StandaloneClient('localhost', 8080, false, 'mobilityapi', 'v1', new DefaultTaskRunner());

  //Retrieve the available code on demand tasks and the path to the resources cod resources
  //The path is 'cod', so the resource address is http://localhost:8080/cod/{resource})
  List<Task> tasks = await client.retrieveTaskList();
  tasks.forEach((task) => print(task.resource));

  //Filename of the task
  String fibonacciFilename = tasks.where((task) => task.resource == 'fibonacci.dart').first.resource;
  //The arguments (data) for the task
  List<String> args = ['123'];


  //Executes the task on the local (client) device. The source is already on the device.
  print('Local: ${await client.executeLocal('tasks', fibonacciFilename, args)}');

  //Executes the task on the remote (server) device. The source is already on the device.
  print('Remote: ${await client.executeRemote(fibonacciFilename, args)}');

  //Fetch the source from the server and execute the task on the local device.
  print('Code on demand: ${await client.codeOnDemand(fibonacciFilename, args)}');

  //Executes the task on the remote (server) device.
  //The source code is fetched by the server (with cod) from a third (code delivery) server.
  String cdServer = 'http://localhost:4040/repository/';
  print('Remote evaluation with fetch: ${await client.remoteEvaluationWithFetch(cdServer + fibonacciFilename, args)}');

  //Sends the source code as string to the remote device. There it's executed.
  //Currently only the task without the imports/dependencies is sent. Therefore it's only suitable for very simple tasks.
  print('Remote evaluation with source: ${await client.remoteEvaluationWithSource('tasks', fibonacciFilename, args)}');
}


