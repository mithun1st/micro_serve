import 'package:micro_serve/src/common/model.dart';

abstract class Route {
  void post(String path, Function(ServerContext) handler);
  void get(String path, Function(ServerContext) handler);
  void put(String path, Function(ServerContext) handler);
  void delete(String path, Function(ServerContext) handler);
  void patch(String path, Function(ServerContext) handler);
}

abstract class Server {
  Future<void> serverStart({
    required String ipAddress,
    required int port,
    required Map<String, Node> nodeList,
    required Function(bool) callBack,
  });
  Future<bool> serverStop();
  ServerInfo get serverInfo;
}
