# Micro Serve

[![pub package](https://img.shields.io/pub/v/micro_serve.svg)](https://pub.dev/packages/micro_serve)

The `Micro_Serve` package for Flutter is designed to initialize an HTTP server that efficiently manages HTTP requests.


## Features

- **HTTP Handling**
Ability to handle incoming HTTP requests and send appropriate responses.

- **Routing**
Support for defining routes (GET, POST, PUT, DELETE, PATCH) and mapping them to specific request handlers.

- **Request Parsing**
Capability to read and parse query parameters and body data from incoming requests.

- **Response Handling**
Ability to construct and send structured responses to clients, including setting status codes, headers, and body content.

- **Error Handling**
Mechanism to handle server-side, method errors gracefully and send appropriate error responses to clients.


## Getting started

> Add the package to your `pubspec.yaml` file:
```yaml
dependencies:
  micro_serve: ^<latest version>
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

This package simplifies server-side operations within a Flutter application, making it ideal for developers looking to integrate server capabilities directly into their apps.

This `Micro Server` plugin is developed by [Mahadi Hassan](https://www.linkedin.com/in/mithun1st/).
> [LinkedIn](https://www.linkedin.com/in/mithun1st/).
> [GitHub](https://www.github.com/mithun1st/)
> [Website](https://mithun1st.blogspot.com/)