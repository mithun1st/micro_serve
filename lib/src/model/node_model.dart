import 'package:micro_serve/src/common/common.dart';

class Node {
  final Method method;
  final String path;
  final Function(ServerContext) handler;
  final String? token;
  final String? apiKey;
  Node({
    required this.method,
    required this.path,
    required this.handler,
    this.token,
    this.apiKey,
  });
}
