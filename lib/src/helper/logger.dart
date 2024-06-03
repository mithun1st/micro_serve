import 'dart:developer';

class Logger {
  static const String _packageName = 'MICRO_SERVE';
  static void info(String msg) => log(msg, name: "$_packageName-INFO");
  static void error(String msg) => log(msg, name: "$_packageName-Error");
  static void print(String msg, String name) => log(msg, name: "$_packageName-$name");
}
