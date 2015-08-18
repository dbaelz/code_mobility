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

import 'dart:async';
import 'dart:io';

import 'package:code_mobility/code_mobility.dart';
import 'package:code_mobility/standalone.dart';

main() async {
  String number = '321';
  TaskRunner runner = new StandaloneTaskRunner();

  String scriptName = Platform.script.toString();
  int lastIndex = scriptName.lastIndexOf('/');
  String filename = '${scriptName.substring(0, lastIndex)}/tasks/fibonacci.dart';
  Uri uri = Uri.parse(filename);

  print('Execute with uri: ${await runner.execute(uri, [number])}');

  String code = await _getFileAsString(uri);
  print('Execute with string and temp file: ${await runner.executeFromSourceString(code, [number])}');
}

Future<String> _getFileAsString(Uri uri) {
  final completer = new Completer();
  new File.fromUri(uri).readAsString().then((content) => completer.complete(content));
  return completer.future;
}
