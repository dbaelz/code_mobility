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

library code_mobility.server;

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:rpc/rpc.dart';

import 'mobility_api.dart';
import '../taskrunner/task.dart';
import '../taskrunner/taskrunner.dart';

class Server {
  final Logger log = new Logger('code_mobility');
  final ApiServer _apiServer = new ApiServer(prettyPrint: true);

  HttpServer _httpServer;
  MobilityAPI _api;
  int _port;
  bool _discovery;
  String _codResource;
  String _taskDir;

  Server(TaskRunner taskRunner, List<Task> tasks,
         {int port: 8080, bool discovery: false, String codResource: 'cod', String taskDir: 'tasks'}) {
    _port = port;
    _discovery = discovery;
    _codResource = codResource;
    _taskDir = taskDir;
    _api = new MobilityAPI(taskRunner, tasks, _codResource, _taskDir);
  }

  Future start() async {
    Logger.root
      ..level = Level.INFO
      ..onRecord.listen(print);

    _apiServer.addApi(_api);
    if (_discovery) {
      _apiServer.enableDiscoveryApi();
    }

    _httpServer = await HttpServer.bind(InternetAddress.ANY_IP_V4, _port);
    _httpServer.listen((HttpRequest request) async {
      var requestPath = request.uri.path;
      while (requestPath.contains('//')) requestPath = requestPath.replaceAll('//', '/');

      String codPath = '${path.separator}${_codResource}${path.separator}';
      var apiResponse;
      try {
        if (requestPath.startsWith(codPath) && requestPath.length > codPath.length) {
          if (request.method != 'GET') {
            throw new NotFoundError();
          }

          final basePath = path.dirname(Platform.script.toString());
          String resourcePath = '${basePath}${path.separator}${_taskDir}${path.separator}';

          requestPath = requestPath.substring(codPath.length);
          if (requestPath.startsWith('packages/')) {
            resourcePath += requestPath;
          } else {
            var pathSegments = requestPath.split('/');
            if (pathSegments.length != 1) {
              throw new NotFoundError();
            }
            resourcePath += pathSegments[0];
          }

          Uri uri = Uri.parse(resourcePath);
          final File file = new File.fromUri(uri);
          String content = await file.readAsString();
          request.response
            ..write(content)
            ..close();
          log.info('Send $resourcePath');
        } else {
          var apiRequest = new HttpApiRequest.fromHttpRequest(request);
          apiResponse = await _apiServer.handleHttpApiRequest(apiRequest);
          sendApiResponse(apiResponse, request.response);
        }

      } catch (error, stacktrace) {
        if (error is NotFoundError) {
          apiResponse = new HttpApiResponse.error(HttpStatus.NOT_FOUND, 'No method found matching HTTP method: ${request.method} '
            'and url: ${request.uri.path}.', new Exception(NotFoundError), stacktrace);
        } else {
          apiResponse = new HttpApiResponse.error(HttpStatus.INTERNAL_SERVER_ERROR, 'Internal Server Error.', new Exception(), stacktrace);
        }
        sendApiResponse(apiResponse, request.response);
      }
    });
    log.info('Server listening on http://${_httpServer.address.host}:${_httpServer.port}');
  }

  stop() {
    _httpServer.close();
    log.info('Server stopped');
  }
}
