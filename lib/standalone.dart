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

/// The standalone library includes all features for the standalone vm.
/// It's imported when the application should be executed on the standalone virtual machine.
library code_mobility.standalone;

export 'src/client/standalone_client.dart';
export 'src/server/server.dart';
export 'src/taskrunner/standalone_taskrunner.dart';
