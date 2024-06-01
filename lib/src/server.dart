import 'dart:io';
import 'dart:convert';
import 'package:micro_serve/src/common/common.dart';

abstract class BaseService {
  static HttpServer? _hServer;

  Future<void> _write(HttpRequest httpRequest, Response response) async {
    httpRequest.response.statusCode = response.statusCode ?? HttpStatus.accepted_202.code;
    httpRequest.response.write(response.data);
    await httpRequest.response.close();
    final DateTime dt = DateTime.now();
    Logger.info("${DTFormat.date(dt)} - ${DTFormat.time(dt)}\t${httpRequest.method}\t${response.statusCode}\t${httpRequest.uri.path}");
  }

  Future<void> _threadOpen(HttpRequest httpRequest, Node node) async {
    if (httpRequest.method != node.method.syntax) {
      final Response response = Response.methodNotAllowed();
      await _write(httpRequest, response);
      return;
    }

    final Map params = httpRequest.uri.queryParameters;
    final String data = await utf8.decoder.bind(httpRequest).join();

    final Request request = Request(queryParams: params, headers: {}, body: data);
    resCallBackFnc(Response response) => _write(httpRequest, response);

    final ServerContext serverContext = ServerContext(request: request, send: resCallBackFnc);

    final Function(ServerContext) handlerFnc = node.handler;

    try {
      await handlerFnc(serverContext);
    } catch (error) {
      final Response response = Response.internalServerError(error.toString());
      await _write(httpRequest, response);
      Logger.error(error.toString());
    }
  }

  Future<void> _start({required String ipAddress, required int port, required Map<String, Node> nodeList}) async {
    _hServer = await HttpServer.bind(ipAddress, port);

    Logger.print("Listening on ${_hServer?.address.address}:${_hServer?.port}", 'debug');

    await for (HttpRequest httpRequest in _hServer ?? ([] as HttpServer)) {
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

    Logger.print("Listening off", 'debug');
  }

  Future<void> _stop() async {
    await _hServer?.close();
  }

  ServerInfo get info {
    try {
      return ServerInfo(
        address: _hServer?.address.address,
        addressType: _hServer?.address.type.name,
        port: _hServer?.port,
        isRunning: true,
      );
    } catch (_) {
      return ServerInfo(isRunning: false);
    }
  }
}

class MicroServe extends BaseService {
  static final Map<String, Node> _nodeList = {};
  MicroServe() {
    _nodeList.clear();
  }

  void _addNode(Node node) {
    if (!_nodeList.containsKey(node.path)) {
      _nodeList[node.path] = node;
    } else {
      Logger.error("'${node.path}' path already exist");
    }
  }

  void post(String path, Function(ServerContext) handler) {
    final Node node = Node(method: Method.post, path: path, handler: handler);
    _addNode(node);
  }

  void get(String path, Function(ServerContext) handler) {
    final Node node = Node(method: Method.get, path: path, handler: handler);
    _addNode(node);
  }

  void put(String path, Function(ServerContext) handler) {
    final Node node = Node(method: Method.put, path: path, handler: handler);
    _addNode(node);
  }

  void delete(String path, Function(ServerContext) handler) {
    final Node node = Node(method: Method.delete, path: path, handler: handler);
    _addNode(node);
  }

  void patch(String path, Function(ServerContext) handler) {
    final Node node = Node(method: Method.patch, path: path, handler: handler);
    _addNode(node);
  }

  void _showAllNode() {
    for (Node node in _nodeList.values.toList()) {
      Logger.print("${node.method.syntax}\t${node.path}", "PATH");
    }
  }

  void listen({required int port, String? ipAddress, NetworkType? setNetworkTypeIfIPUnknown}) async {
    if (ipAddress == null && setNetworkTypeIfIPUnknown != null) {
      ipAddress = await Network.getIp(setNetworkTypeIfIPUnknown);
    }

    _showAllNode();

    _start(ipAddress: ipAddress ?? NetworkType.local.ip, port: port, nodeList: _nodeList);
  }

  Future<void> close({bool? clearNode}) async {
    if (clearNode ?? false) {
      _nodeList.clear();
    }
    await _stop();
  }
}
