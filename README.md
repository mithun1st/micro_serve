# Micro Serve

[![pub package](https://img.shields.io/pub/v/micro_serve.svg)](https://pub.dev/packages/micro_serve)

The `micro_serve` package for Flutter is designed to initialize an HTTP server that efficiently manages requests and server-side operations within applications.

<p align="center">
  <img src="https://raw.githubusercontent.com/mithun1st/micro_serve/master/example/screenshots/animation.gif" width="500" alt="example">
</p>



## Features

- **HTTP Handling:**
*Manage incoming HTTP requests and send responses.*

- **Routing:**
*Define routes (GET, POST, PUT, DELETE, PATCH) and link them to request handlers.*

- **Request Parsing:**
*Read and parse query parameters and body data from requests.*

- **Response Handling:**
*Create and send responses with status codes, headers, and content.*

- **Error Handling:**
*Gracefully manage errors and send appropriate error responses.*


## Getting started

> Add the package to your `pubspec.yaml` file:
```yaml
dependencies:
  micro_serve: <latest version>
```

> Open (android/app/src/main/) `AndroidManifest.xml` and add this line:
```xml
<manifest xmlns:android="...">
  <uses-permission android:name="android.permission.INTERNET"/> <!-- Add this -->
  <application....>
</manifest>
```

> macOS apps must allow network access in the relevant `*.entitlements` files:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

> Import the Package:
```dart
import 'package:micro_serve/micro_serve.dart';
```

> Initialize the Server:
```dart
void main() {
  final MicroServe server = MicroServe();

  server.get("/hello", (ServerContext serverContext) async {
    final Response response = Response(
      statusCode: 200,
      data: "Welcome Micro-Serve",
    );
    serverContext.send(response);
  });

  server.listen(ipAddress: "127.0.0.1", port: 3000);
}
```


## Usage

> Create an Object of MicroServe:
```dart
final MicroServe _server = MicroServe();
```

> Server On Function:
```dart
void _serverOn() async {
  //Define Routes
  _server.put('/update', _updateTask);

  //Get WiFi IP Address
  final String? lanWifiIp = await Network.getIp(NetworkType.wlan);
  const int port = 3000;

  // Server Start
  _server.listen(
    ipAddress: lanWifiIp,
    port: port,
    callBack: () {
      print("Server initiated");
    },
  );
}
```

> Server Off Function:
```dart
void _serverOff() async {
  await _server.close();
}
```

> Handler Function:
```dart
void _updateTask(ServerContext serverContext) {
  //Create an Object of Request() From ServerContext to Get Client Request
  final Request request = serverContext.request;

  final int id = int.parse(request.queryParams["id"]!);
  final String name = jsonDecode(request.body)['name'];
  final bool isDone = jsonDecode(request.body)['isDone'];
  final String? key = request.headers['api-key'];
  // print('ClientIpAddress: ${serverContext.connectionInfo.address}');

  //Create an Object of Response() to Send Client
  final Response response = Response();

  if (key != 'abcd1234') {
    //Edit Response Object as Preference 1
    response.statusCode = HttpStatus.unauthorized_401.code;
    response.data = {"message": "api key error"};
  } else if (!_taskStore.containsKey(id)) {
    //Edit Response Object as Preference 2
    response.statusCode = HttpStatus.notFound_404.code;
    response.data = {"message": "not found"};
  } else {
    _taskStore[id]!.name = name;
    _taskStore[id]!.isDone = isDone;
    //Edit Response Object as Preference 3
    response.statusCode = HttpStatus.accepted_202.code;
    response.data = {"message": "updated successfully"};
  }

  //Send Response to Client
  serverContext.send(response);
}
```

**`API Reference`**

> Method [PUT]:
```url
http://ip:port/update?id=1
```

> Headers:

|  key  |  value |
|:-----:|:------:|
|api-key|abcd1234| 



> Body:
```json
{
  "name" : "mh task",
  "isDone" : true
}
```


## Limitation

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :----: |
|   ✅    | ✅  |  ✅   | ❌  |  ✅   |   ✅   |

The functionality is not supported on Web.


## Additional information

`Micro Serve` plugin is developed by [Mahadi Hassan](https://www.linkedin.com/in/mithun1st/)
> mithun.2121@yahoo.com | [LinkedIn](https://www.linkedin.com/in/mithun1st/) | [GitHub](https://www.github.com/mithun1st/) | [Website](https://mithun1st.blogspot.com/)