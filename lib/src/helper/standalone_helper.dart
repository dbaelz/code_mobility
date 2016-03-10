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
    } catch (exception) {}
    return JSON.encode(content);
  }
}