class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String? lastKnownIp;
  final int httpPort;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    this.lastKnownIp,
    this.httpPort = 80,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      lastKnownIp: json['lastKnownIp'] as String?,
      httpPort: json['httpPort'] as int? ?? 80,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'lastKnownIp': lastKnownIp,
      'httpPort': httpPort,
    };
  }
}
