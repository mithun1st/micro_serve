import 'package:micro_serve/src/common/constant.dart';
import 'package:micro_serve/src/common/dart.dart';
import 'package:micro_serve/src/common/model.dart';
import 'package:micro_serve/src/helper/logger.dart';
import 'package:micro_serve/src/service/interface.dart';
import 'package:micro_serve/src/service/thread.dart';

class BaseService extends Thread with Logger implements Server {
  BaseService(bool showResponseLog) : super(showResponseLog);

  static HttpServer? _httpServer;

  @override
  Future<void> serverStart({
    required String ipAddress,
    required int port,
    required Map<String, Node> nodeList,
    required Function(bool) callBack,
  }) async {
    for (Node node in nodeList.values.toList()) {
      logInfo("${node.method.syntax}\t${node.path}");
    }

    try {
      _httpServer = await HttpServer.bind(ipAddress, port);

      final String? serverIp = _httpServer?.address.address;
      final int? serverPort = _httpServer?.port;
      logPrint("Server listening on $serverIp:$serverPort");

      callBack(true);
    } catch (error) {
      callBack(false);
      logError(error.toString());
      return;
    }

    await for (HttpRequest httpRequest in _httpServer ?? ([] as HttpServer)) {
      final String path = httpRequest.uri.path;
      if (nodeList.keys.contains(path)) {
        final Node? node = nodeList[path];
        if (node != null) {
          runInThread(httpRequest, node);
        }
      } else {
        await httpRequest.response.close();
      }
    }

    logPrint("Server has been turned off");
  }

  @override
  Future<bool> serverStop() async {
    try {
      await _httpServer?.close();
      _httpServer = null;
      return true;
    } catch (error) {
      logError(error.toString());
      return false;
    }
  }

  @override
  ServerInfo get serverInfo {
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
