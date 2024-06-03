import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:micro_serve/micro_serve.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Micro Serve',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: false,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<int, Task> _taskStore = {};

  final MicroServe _server = MicroServe();

  ///SERVER ON
  void _serverOn() async {
    //Define Route
    _server.get('/', _welcome);
    _server.post('/create', _createTask);
    _server.get('/read', _readTasks);
    _server.put('/update', _updateTask);
    _server.delete('/delete', _deleteTask);

    //Get WiFi IP Address
    final String? lanWifiIp = await Network.getIp(NetworkType.wlan);
    const int port = 3000;

    //Server Start
    _server.listen(
      ipAddress: lanWifiIp,
      port: port,
      callBack: () {
        setState(() {});
      },
    );
  }

  ///Server Off
  void _serverOff() async {
    await _server.close();
    setState(() {});
  }

  ///HANDLER FUNCTION
  void _welcome(ServerContext serverContext) {
    Response response = Response(
      statusCode: 200,
      data: "Micro-Serve is Running",
    );
    serverContext.send(response);
  }

  void _createTask(ServerContext serverContext) {
    final Request request = serverContext.request;
    final Task newTask = Task.fromJson(jsonDecode(request.body));

    Response response = Response();
    if (_taskStore.containsKey(newTask.id)) {
      response.statusCode = HttpStatus.conflict_409.code;
      response.data = {"message": "already exist"};
    } else {
      _taskStore[newTask.id] = newTask;
      final Map responseBody = {
        "message": "created successfully",
        "total": _taskStore.length,
      };
      response.statusCode = HttpStatus.created_201.code;
      response.data = responseBody;
    }

    serverContext.send(response);
  }

  void _readTasks(ServerContext serverContext) {
    final List<Map> taskList = [];

    for (Task task in _taskStore.values) {
      taskList.add(task.toJson());
    }

    final Map data = {
      "message": "fetched successfully",
      "data": taskList,
    };
    Response response = Response(
      statusCode: HttpStatus.ok_200.code,
      data: data,
    );

    serverContext.send(response);
  }

  void _updateTask(ServerContext serverContext) {
    //Create an Object of Request() From ServerContext to Get Client Request
    final Request request = serverContext.request;

    final int id = int.parse(request.queryParams["id"]);
    final String name = jsonDecode(request.body)['name'];
    final bool isDone = jsonDecode(request.body)['isDone'];

    //Create an Object of Response() to Send Client
    final Response response = Response();

    if (!_taskStore.containsKey(id)) {
      //Edit Response Object as Preference 1
      response.statusCode = HttpStatus.notFound_404.code;
      response.data = {"message": "not found"};
    } else {
      _taskStore[id]!.name = name;
      _taskStore[id]!.isDone = isDone;

      //Edit Response Object as Preference 2
      response.statusCode = HttpStatus.accepted_202.code;
      response.data = {"message": "updated successfully"};
    }

    //Send Response to Client
    serverContext.send(response);
  }

  void _deleteTask(ServerContext serverContext) {
    final Request request = serverContext.request;
    final int taskId = int.parse(request.queryParams["id"]);

    final Response response = Response();
    if (!_taskStore.containsKey(taskId)) {
      response.statusCode = HttpStatus.notFound_404.code;
      response.data = {"message": "not found"};
    } else {
      _taskStore.remove(taskId);

      final Map responseBody = {
        "message": "deleted successfully",
        "total": _taskStore.length,
      };
      response.statusCode = HttpStatus.accepted_202.code;
      response.data = responseBody;
    }

    serverContext.send(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Micro Serve"),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _server.info.isRunning
                    ? Text(
                        "Server running on...\nhttp://${_server.info.address}:${_server.info.port}/",
                        textAlign: TextAlign.center,
                      )
                    : const Text('Server is offline now'),
                ElevatedButton(
                  onPressed: !_server.info.isRunning ? _serverOn : _serverOff,
                  child: Text(!_server.info.isRunning ? "Tap To Start" : "Stop"),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text("API REFERENCE"),
                  _textWidget(welcome),
                  _textWidget(createTask),
                  _textWidget(readTasks),
                  _textWidget(updateTask),
                  _textWidget(deleteTask),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///API REFERENCE
  final String welcome = '''
[GET]\thttp://ip:port/''';

  final String createTask = '''
[POST]\thttp://ip:port/create

body:
{
  "id" : 1,
  "name" : "first task",
  "isDone" : false
}''';
  final String readTasks = '''
[GET]\thttp://ip:port/read''';
  final String updateTask = '''
[PUT]\thttp://ip:port/update?id=1

body:
{
  "name" : "mh task",
  "isDone" : true
}''';
  final String deleteTask = '''
[DELETE]\thttp://ip:port/delete?id=1''';

  Widget _textWidget(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all()),
      child: SelectableText(
        text,
      ),
    );
  }
}

///TASK MODEL
class Task {
  int id;
  String name;
  bool isDone;

  Task({
    required this.id,
    required this.name,
    required this.isDone,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        name: json["name"],
        isDone: json["isDone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "isDone": isDone,
      };
}
