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

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

import 'mobility_api.dart';
import 'dart:async';

class Server {
  final Logger log = new Logger('code_mobility');
  final ApiServer _apiServer = new ApiServer(prettyPrint: true);

  HttpServer _httpServer;
  MobilityAPI _api;

  Server(this._api);

  Future start({int port: 8080, bool discovery: false}) async {
    Logger.root
      ..level = Level.INFO
      ..onRecord.listen(print);

    _apiServer.addApi(_api);
    if (discovery) {
      _apiServer.enableDiscoveryApi();
    }

    _httpServer = await HttpServer.bind(InternetAddress.ANY_IP_V4, port);
    _httpServer.listen(_apiServer.httpRequestHandler);
    print('Server listening on http://${_httpServer.address.host}:${_httpServer.port}');
  }

  stop() {
    _httpServer.close();
    print('Server stopped');
  }
}
