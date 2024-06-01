class ServerInfo {
  final String? address;
  final String? addressType;
  final int? port;
  final bool isRunning;

  ServerInfo({
    this.address,
    this.addressType,
    this.port,
    required this.isRunning,
  });
}
