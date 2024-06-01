import 'dart:io';
import 'package:micro_serve/src/common/common.dart';

class Network {
  static Future<String?> _findWifiIp() async {
    for (var v in await NetworkInterface.list()) {
      if (v.name.startsWith('wlan') && v.addresses.isNotEmpty) {
        return v.addresses.first.address;
      }
    }
    return null;
  }

  static Future<String?> getIp(NetworkType networkType) async {
    switch (networkType) {
      case NetworkType.local:
        return networkType.ip;
      case NetworkType.wlan:
        return await _findWifiIp();
    }
  }
}
