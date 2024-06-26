enum Method {
  post,
  get,
  put,
  delete,
  patch,
}

enum NetworkType {
  local,
  wlan,
  defaultIp,
}

enum HttpStatus {
  ok_200,
  created_201,
  accepted_202,
  badRequest_400,
  unauthorized_401,
  forbidden_403,
  notFound_404,
  conflict_409,
  methodNotAllowed_405,
  internalServerError_500,
}
