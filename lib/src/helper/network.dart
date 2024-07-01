import 'package:micro_serve/src/common/dart.dart';
import 'package:micro_serve/src/common/constant.dart';

class Network {
  static Future<String?> _findWlanIp() async {
    for (var v in await NetworkInterface.list()) {
      if (v.name.startsWith('wlan') && v.addresses.isNotEmpty) {
        return v.addresses.first.address;
      }
    }
    return null;
  }

  static Future<String?> getIp(NetworkType networkType) async {
    switch (networkType) {
      case NetworkType.default_:
        return Const.defaultIp;
      case NetworkType.local:
        return Const.localIp;
      case NetworkType.wlan:
        return await _findWlanIp();
    }
  }
}
