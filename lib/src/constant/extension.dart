import 'package:micro_serve/src/constant/enum.dart';

extension MethodSyntax on Method {
  String get syntax {
    switch (this) {
      case Method.post:
        return "POST";
      case Method.get:
        return "GET";
      case Method.put:
        return "PUT";
      case Method.delete:
        return "DELETE";
      case Method.patch:
        return "PATCH";
    }
  }
}

// extension NetworkIp on NetworkType {
//   String get ip {
//     switch (this) {
//       case NetworkType.local:
//         return "127.0.0.1";
//       case NetworkType.wlan:
//         return "";
//     }
//   }
// }

extension HttpStatusCode on HttpStatus {
  int get code {
    switch (this) {
      case HttpStatus.ok_200:
        return 200;
      case HttpStatus.created_201:
        return 201;
      case HttpStatus.accepted_202:
        return 202;
      case HttpStatus.badRequest_400:
        return 400;
      case HttpStatus.unauthorized_401:
        return 401;
      case HttpStatus.forbidden_403:
        return 403;
      case HttpStatus.notFound_404:
        return 404;
      case HttpStatus.conflict_409:
        return 409;
      case HttpStatus.methodNotAllowed_405:
        return 405;
      case HttpStatus.internalServerError_500:
        return 500;
    }
  }
}
