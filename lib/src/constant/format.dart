class Format {
  static String date(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  static String time(DateTime dateTime) {
    return ("${dateTime.hour}:${dateTime.minute}:${dateTime.second}");
  }

  static Map responseJsonFormat(String message) => {
        "timestamp": DateTime.now().toIso8601String(),
        "message": message,
      };
}
