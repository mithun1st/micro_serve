import 'package:micro_serve/src/common/constant.dart';
import 'package:micro_serve/src/common/model.dart';
import 'package:micro_serve/src/service/base_service.dart';
import 'package:micro_serve/src/service/interface.dart';

class MicroServe implements Route {
  static final Map<String, Node> _nodeStore = {};
  static late final BaseService _baseService;

  MicroServe({bool showResponseLog = true}) {
    _baseService = BaseService(showResponseLog);
    _nodeStore.clear();
  }

  @override
  void post(String path, Function(ServerContext) handler) {
    final Node node = Node(
      method: Method.post,
      path: path,
      handler: handler,
    );
    _addNode(node);
  }

  @override
  void get(String path, Function(ServerContext) handler) {
    final Node node = Node(
      method: Method.get,
      path: path,
      handler: handler,
    );
    _addNode(node);
  }

  @override
  void put(String path, Function(ServerContext) handler) {
    final Node node = Node(
      method: Method.put,
      path: path,
      handler: handler,
    );
    _addNode(node);
  }

  @override
  void delete(String path, Function(ServerContext) handler) {
    final Node node = Node(
      method: Method.delete,
      path: path,
      handler: handler,
    );
    _addNode(node);
  }

  @override
  void patch(String path, Function(ServerContext) handler) {
    final Node node = Node(
      method: Method.patch,
      path: path,
      handler: handler,
    );
    _addNode(node);
  }

  void _addNode(Node node) {
    if (!_nodeStore.containsKey(node.path)) {
      _nodeStore[node.path] = node;
    }
  }

  void listen({
    required int port,
    String? ipAddress,
    Function(bool)? callBack,
  }) {
    _baseService.serverStart(
      ipAddress: ipAddress ?? Const.defaultIp,
      port: port,
      nodeList: _nodeStore,
      callBack: callBack ?? (_) {},
    );
  }

  Future<bool> close({bool? clearAllRoute}) async {
    if (clearAllRoute ?? false) {
      _nodeStore.clear();
    }

    return await _baseService.serverStop();
  }

  ServerInfo get info => _baseService.serverInfo;
}
