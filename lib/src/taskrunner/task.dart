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

library code_mobility.taskrepo;

@MirrorsUsed(metaTargets: Task)
import 'dart:mirrors';

/// A parser for class annotations.
class TaskAnnotation {
  /// Parses the given [classType] class for the [Task] annotation.
  ///
  /// Returns null if the annotation does not exist.
  static Task getAnnotation(Type classType) {
    ClassMirror classMirror = reflectClass(classType);
    var annotations = classMirror.metadata.where((element) => element.reflectee.runtimeType == Task).toList();
    if (annotations.length == 1) {
      return annotations.first.reflectee;
    }
    return null;
  }
}

/// Definition of a task.
///
/// Every task consists of a name, resource and description.
class Task {
  final String name;
  final String resource;
  final String description;

  const Task({this.name, this.resource, this.description: ''});
}