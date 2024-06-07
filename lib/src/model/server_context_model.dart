import 'package:micro_serve/src/common/common.dart';

class ServerContext {
  final Request request;
  final Function(Response) send;
  final ConnectionInfo connectionInfo;

  ServerContext({
    required this.request,
    required this.send,
    required this.connectionInfo,
  });
}

class Request {
  final Map<String, String> queryParams;
  final Map<String, String> headers;
  final String body;

  Request({
    required this.queryParams,
    required this.headers,
    required this.body,
  });
}

class Response {
  int? statusCode;
  dynamic data;

  Response({
    this.statusCode,
    this.data,
  });

  factory Response.methodNotAllowed() => Response(
        statusCode: HttpStatus.methodNotAllowed_405.code,
        data: Format.responseJsonFormat("Method Not Allowed"),
      );
  factory Response.internalServerError(String error) => Response(
        statusCode: HttpStatus.internalServerError_500.code,
        data: Format.responseJsonFormat(error),
      );
}

class ConnectionInfo {
  final String? address;
  final int? port;
  final String? addressType;

  const ConnectionInfo({
    this.address,
    this.port,
    this.addressType,
  });
}
