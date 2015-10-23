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

library code_mobility.example.standalone;

import 'package:code_mobility/code_mobility.dart';
import 'package:code_mobility/standalone.dart';

import 'tasks/fibonacci.dart';

main() async {
  List<Task> tasks = [];
  tasks.add(TaskAnnotation.getAnnotation(Fibonacci));
  tasks.add(new Task(
      name: 'Simple Task',
      resource: 'simple_task.dart',
      description: 'A simple task without 3th party imports/dependencies'));

  MobilityServer server = new MobilityServer(new DefaultTaskRunner(), tasks);
  await server.start();
}
