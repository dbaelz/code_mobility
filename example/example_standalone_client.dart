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

library code_mobility.example.client;

import 'package:code_mobility/code_mobility.dart';
import 'package:code_mobility/standalone.dart';

main() async {
  //Initialize standalone client for a server running with default server config on localhost
  StandaloneClient client = new StandaloneClient('localhost', 8080, 'mobilityapi', 'v1', new StandaloneTaskRunner());

  //Retrieve the available code on demand tasks and the path to the resources cod resources
  //The path is 'cod', so the resource address is http://localhost:8080/cod/{resource})
  List<Task> tasks = await client.retrieveCodTasks();
  tasks.forEach((task) => print(task.resource));

  //Filename of the task
  String fibonacciFilename = tasks.where((task) => task.resource == 'fibonacci.dart').first.resource;
  String simpleFilename = tasks.where((task) => task.resource == 'simple_task.dart').first.resource;
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
  print('Remote evaluation with source: ${await client.remoteEvaluationWithSource('tasks', simpleFilename, args)}');
}


