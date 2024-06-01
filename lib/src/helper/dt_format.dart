class DTFormat {
  static String date(DateTime dateTime) => "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  static String time(DateTime dateTime) => ("${dateTime.hour}:${dateTime.minute}:${dateTime.second}");
}
