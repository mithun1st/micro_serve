import 'dart:io';
import 'dart:convert';
import 'package:micro_serve/src/common/common.dart';

abstract class _BaseService {
  static HttpServer? _httpServer;

  Future<void> _write(
    HttpRequest httpRequest,
    Response response,
  ) async {
    void printLog() {
      final String date = Format.date(DateTime.now());
      final String time = Format.time(DateTime.now());
      final String method = httpRequest.method;
      final int? statusCode = response.statusCode;
      final String path = httpRequest.uri.path;

      Logger.info("$date - $time\t$method\t$statusCode\t$path");
    }

    final int code = response.statusCode ?? HttpStatus.ok_200.code;
    httpRequest.response.statusCode = code;
    if (response.data is Map || response.data is List) {
      response.data = jsonEncode(response.data);
    }
    httpRequest.response.write(response.data);
    await httpRequest.response.close();

    printLog();
  }

  Map<String, String> _buildHeaders(HttpHeaders headers) {
    final Map<String, String> map = {};
    for (String e in headers.toString().split('\n')) {
      final String key = e.split(":")[0];
      final String? value = headers.value(key);
      if (value != null) {
        map[key] = value;
      }
    }
    return map;
  }

  Future<void> _threadOpen(HttpRequest httpRequest, Node node) async {
    if (httpRequest.method != node.method.syntax) {
      final Response response = Response.methodNotAllowed();
      await _write(httpRequest, response);
      return;
    }

    //request
    final String data = await utf8.decoder.bind(httpRequest).join();

    final Request request = Request(
      queryParams: httpRequest.uri.queryParameters,
      headers: _buildHeaders(httpRequest.headers),
      body: data,
    );

    //response
    resCallBackFnc(Response response) => _write(httpRequest, response);

    //client
    final ConnectionInfo connectionInfo = ConnectionInfo(
      address: httpRequest.connectionInfo?.remoteAddress.address,
      port: httpRequest.connectionInfo?.remotePort,
      addressType: httpRequest.connectionInfo?.remoteAddress.type.name,
    );

    //server context
    final ServerContext serverContext = ServerContext(
      request: request,
      send: resCallBackFnc,
      connectionInfo: connectionInfo,
    );

    final Function(ServerContext) handlerFnc = node.handler;

    try {
      await handlerFnc(serverContext);
    } catch (error) {
      final Response response = Response.internalServerError(
        error.toString(),
      );
      await _write(httpRequest, response);
      Logger.error(error.toString());
    }
  }

  Future<void> _start({
    required String ipAddress,
    required int port,
    required Map<String, Node> nodeList,
    required Function callBack,
  }) async {
    _httpServer = await HttpServer.bind(ipAddress, port);

    final String? serverIp = _httpServer?.address.address;
    final int? serverPort = _httpServer?.port;
    Logger.print("Server listening on $serverIp:$serverPort", 'debug');

    callBack();

    await for (HttpRequest httpRequest in _httpServer ?? ([] as HttpServer)) {
      final String path = httpRequest.uri.path;
      if (nodeList.keys.contains(path)) {
        final Node? node = nodeList[path];
        if (node != null) {
          _threadOpen(httpRequest, node);
        }
      } else {
        await httpRequest.response.close();
      }
    }

    Logger.print("Server has been turned off", 'debug');
  }

  Future<void> _stop() async {
    await _httpServer?.close();
    _httpServer = null;
  }

  ServerInfo get info {
    if (_httpServer == null) {
      return ServerInfo(isRunning: false);
    }
    try {
      return ServerInfo(
        address: _httpServer?.address.address,
        addressType: _httpServer?.address.type.name,
        port: _httpServer?.port,
        isRunning: true,
      );
    } catch (_) {
      return ServerInfo(isRunning: false);
    }
  }
}

class MicroServe extends _BaseService {
  static final Map<String, Node> _nodeList = {};
  MicroServe() {
    _nodeList.clear();
  }

  void _addNode(Node node) {
    if (!_nodeList.containsKey(node.path)) {
      _nodeList[node.path] = node;
    }
    // else {
    //   Logger.error("'${node.path}' path already exist");
    // }
  }

  void post(String path, Function(ServerContext) handler) {
    final Node node = Node(method: Method.post, path: path, handler: handler);
    _addNode(node);
  }

  void get(String path, Function(ServerContext) handler) {
    final Node node = Node(
      method: Method.get,
      path: path,
      handler: handler,
    );
    _addNode(node);
  }

  void put(String path, Function(ServerContext) handler) {
    final Node node = Node(
      method: Method.put,
      path: path,
      handler: handler,
    );
    _addNode(node);
  }

  void delete(String path, Function(ServerContext) handler) {
    final Node node = Node(
      method: Method.delete,
      path: path,
      handler: handler,
    );
    _addNode(node);
  }

  void patch(String path, Function(ServerContext) handler) {
    final Node node = Node(
      method: Method.patch,
      path: path,
      handler: handler,
    );
    _addNode(node);
  }

  void _showAllNode() {
    for (Node node in _nodeList.values.toList()) {
      Logger.print("${node.method.syntax}\t${node.path}", "PATH");
    }
  }

  void listen({
    required int port,
    String? ipAddress,
    Function? callBack,
  }) {
    _showAllNode();

    _start(
      ipAddress: ipAddress ?? Const.localIp,
      port: port,
      nodeList: _nodeList,
      callBack: callBack ?? () {},
    );
  }

  Future<void> close({bool? clearNode}) async {
    if (clearNode ?? false) {
      _nodeList.clear();
    }
    await _stop();
  }
}
