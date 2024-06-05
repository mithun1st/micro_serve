class Format {
  static String date(DateTime dateTime) =>
      "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  static String time(DateTime dateTime) =>
      ("${dateTime.hour}:${dateTime.minute}:${dateTime.second}");
  static Map responseJsonFormat(String message) => {
        "timestamp": DateTime.now().toIso8601String(),
        "message": message,
      };
}
