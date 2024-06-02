import 'dart:convert';
import 'package:micro_serve/micro_serve.dart';

void main() async {
  final MicroServe server = MicroServe();

  server.post("/test", (ServerContext serverContext) async {
    final String userName = serverContext.request.queryParams["user"];
    final int num1 = jsonDecode(serverContext.request.body)["x"] as int;
    final int num2 = jsonDecode(serverContext.request.body)["y"] as int;

    final Map map = {
      "userName": userName,
      "sum": num1 + num2,
    };
    Response response = Response(statusCode: 202, data: map);
    serverContext.send(response);
  });

  server.get("/", (ServerContext serverContext) async {
    Response response = Response(
      statusCode: HttpStatus.ok_200.code,
      data: "Hello Micro-Serve",
    );
    serverContext.send(response);
  });

  await Network.getIp(NetworkType.local);
  server.listen(ipAddress: "127.0.0.1", port: 2000);
}
