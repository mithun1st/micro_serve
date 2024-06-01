class Const {
  static Map responseJsonFormat(String message) => {
        "timestamp": DateTime.now().toIso8601String(),
        "message": message,
      };
}
