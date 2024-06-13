import 'package:micro_serve/src/common/dart.dart';

mixin Logger {
  static const String _title = 'MICRO_SERVE';

  void logPrint(String msg) => log(msg, name: _title);

  void logInfo(String msg) => log(msg, name: "$_title-info");

  void logDebug(String msg) => log(msg, name: "$_title-debug");

  void logError(String msg) => log(msg, name: "$_title-error");
}
