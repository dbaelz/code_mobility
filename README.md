# Code Mobility
A library for code mobility with Dart. This library was initially created for my master's thesis.
Also, a second library for decision-making, called [Adaptify](https://github.com/dbaelz/adaptify), was developed.
For more information on this topic see the [blog post](https://blog.inovex.de/adaptive-code-execution-with-dart/) on the blog of my employee [inovex GmbH](https://www.inovex.de/).

Concepts
---------
With the Code Mobility library different concepts of code distribution and execution are implemented.
In order to demonstrate the opportunities of the library these concepts are briefly discussed here.
The easiest way of code distribution is the use of locally available code.
In this case, it's assumed that the source code is available on all devices and the code can simply be executed on them.
If the task is executed remotely, it may be necessary to send additional data to the target device.
After the computation the result is returned from the local or remote device and further processed.
These types of executions are referred to as local execution and remote execution.
                                       
Another concept is remote evaluation, which is similar to Remote Procedure Call (RPC).
It enables the remote execution of code on a target device and the receipt of the result. A simple example for the use of remote evaluation is an SQL query, which is sent to the SQL server and executed there. The result of the query is returned to the sender.
                                       
The last supported concept is code on demand.
This concept supports requesting source code from another device.
On the requesting device, the source code is executed and the results are processed.
The best known and widely used example for code on demand is JavaScript in a browser.
Figure above shows the different approaches for code mobility.

![Code Mobility](/code_mobility.png)

Structure
----------
Based on these concepts the library provides its functionality.
The central piece of Code Mobility is the task, whose execution is the reason for all further functionality.
A task consist of the three metadata name, resource identifier and description.
This metadata are used to uniquely identify the task in the code distribution and execution and to provide additional information.
In principle a task consists of a class that manipulates the input data and returns the result or an error.
It's executed by a taskrunner on either a server or client.
This class is responsible for the handover of the input data, the execution of the task and the evaluation of the return values.
In addition to an abstract interface for the taskrunner, the library contributes a concrete implementation for the client and server.

The server is also part of the Code Mobility library and is only available for the Dart VM.
A server is used to deliver the content and to accept requests for the above described concepts.
For communication and data exchange the HTTP protocol and the JSON data format is used. Code Mobility consists of an abstract server class and two concrete implementations: The MobilityServer, which supports all concepts and the limited RepositoryServer that provides only content delivery.

The client controls the local execution of a task, triggers a remote execution/evaluation or queries the source code with code on demand.
In all cases, the client delivers the result to the application for further processing.
The client is defined with an abstract class to provide unified interface.
Furthermore, the library provides clients for the Dart VM and the browser.

Development
-----------
For feedback and bug reports just open an issue. Feel free to fork this project, create pull request and contact me for any questions.

Documentation
-------------
The features are explained in the [dartdoc](https://github.com/dart-lang/dartdoc) documentation and the [example implementations](https://github.com/dbaelz/code_mobility/blob/master/example).

License
-------------
Code Mobility is licensed under the [BSD License](https://github.com/dbaelz/code_mobility/blob/master/LICENSE).