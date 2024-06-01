# Micro Serve

[![pub package](https://img.shields.io/pub/v/micro_serve.svg)](https://pub.dev/packages/micro_serve)

The `micro_serve` package for Flutter is designed to initialize an HTTP server that efficiently manages requests and server-side operations within applications.


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


## Usage

> Import the Package:
```dart
import 'package:micro_serve/micro_serve.dart';
```

> Initialize the Server:

```dart
void main() {
  final MicroServe server = MicroServe();

  server.get("/hello", (ServerContext serverContext) async {
    Response response = Response(
      statusCode: 200,
      data: "Welcome Micro-Serve",
    );
    serverContext.send(response);
  });

  server.listen(ipAddress: "127.0.0.1", port: 2000);
}
```


## Additional information

This `Micro Server` plugin is developed by [Mahadi Hassan](https://www.linkedin.com/in/mithun1st/).
> [LinkedIn](https://www.linkedin.com/in/mithun1st/) | [GitHub](https://www.github.com/mithun1st/) | [Website](https://mithun1st.blogspot.com/)