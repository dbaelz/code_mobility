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

library code_mobility.helper.standalone;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

/// Helper class with frequently used functionality for the standalone vm.
class StandaloneHelper {
  /// Returns the absolute path of the local task directory as a String.
  static String getLocalTaskPath(String taskDir, String filename) {
    final basePath = path.dirname(Platform.script.toString());
    return '${basePath}${path.separator}${taskDir}${path.separator}${filename}';
  }

  /// Returns a [Future<String>] that completes with the content of a Dart file as String.
  static Future<String> getLocalTaskAsJSON(String taskDir, String filename) async {
    Uri localUri = Uri.parse(getLocalTaskPath(taskDir, filename));
    //Open as uri required, cause of an issue with File and file:// protocol
    String content = '{}';
    try {
      content = await new File.fromUri(localUri).readAsString();
    } catch (exeception) {}
    return JSON.encode(content);
  }
}