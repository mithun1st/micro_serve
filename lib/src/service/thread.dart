import 'package:micro_serve/src/common/constant.dart';
import 'package:micro_serve/src/common/dart.dart';
import 'package:micro_serve/src/common/model.dart';
import 'package:micro_serve/src/helper/logger.dart';

abstract class Thread with Logger {
  bool _responseLog;
  Thread(this._responseLog);

  void _printResponseLog(
    HttpRequest httpRequest,
    Response response,
  ) {
    final DateTime dateTime = DateTime.now();
    final String date = Format.date(dateTime);
    final String time = Format.time(dateTime);

    final String method = httpRequest.method;
    final int? statusCode = response.statusCode;
    final String path = httpRequest.uri.path;

    final String? ip = httpRequest.connectionInfo?.remoteAddress.address;
    final String clientIp = ip ?? 'x.x.x.x';

    logDebug('|$date - $time|\t|$statusCode|\t|$clientIp|\t|$method|\t$path');
  }

  Future<void> _write(
    HttpRequest httpRequest,
    Response response,
  ) async {
    final int code = response.statusCode ?? HttpStatus.ok_200.code;
    httpRequest.response.statusCode = code;
    if (response.data is Map || response.data is List) {
      response.data = jsonEncode(response.data);
    }
    httpRequest.response.write(response.data);
    await httpRequest.response.close();

    _responseLog ? _printResponseLog(httpRequest, response) : null;
  }

  Map<String, String> _buildHeaders(HttpHeaders headers) {
    final Map<String, String> map = {};
    for (String element in headers.toString().split('\n')) {
      final String key = element.split(":")[0];
      final String? value = headers.value(key);
      if (value != null) {
        map[key] = value;
      }
    }
    return map;
  }

  Future<void> runInThread(HttpRequest httpRequest, Node node) async {
    if (httpRequest.method != node.method.syntax) {
      final Response methodErrorResponse = Response.methodNotAllowed();
      await _write(httpRequest, methodErrorResponse);
      return;
    }

    //build request
    final String data = await utf8.decoder.bind(httpRequest).join();
    final Map<String, String> queryParams = httpRequest.uri.queryParameters;
    final Map<String, String> headers = _buildHeaders(httpRequest.headers);
    final Request request = Request(
      queryParams: queryParams,
      headers: headers,
      body: data,
    );

    //build response-callback
    responseCallBackFnc(Response response) => _write(httpRequest, response);

    //build client-info
    final ConnectionInfo connectionInfo = ConnectionInfo(
      address: httpRequest.connectionInfo?.remoteAddress.address,
      port: httpRequest.connectionInfo?.remotePort,
      addressType: httpRequest.connectionInfo?.remoteAddress.type.name,
    );

    //build server-context (response, response-callback, client-info)
    final ServerContext serverContext = ServerContext(
      request: request,
      send: responseCallBackFnc,
      connectionInfo: connectionInfo,
    );

    final Function(ServerContext) handlerFnc = node.handler;

    try {
      await handlerFnc(serverContext);
    } catch (error) {
      final Response serverErrorResponse = Response.internalServerError(
        error.toString(),
      );
      await _write(httpRequest, serverErrorResponse);
      logError(error.toString());
    }
  }
}
