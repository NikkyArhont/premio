class DiscoveredDevice {
  final String deviceId;
  final String deviceName;
  final String ip;
  final int httpPort;
  final bool sensorOnline;

  DiscoveredDevice({
    required this.deviceId,
    required this.deviceName,
    required this.ip,
    required this.httpPort,
    required this.sensorOnline,
  });

  factory DiscoveredDevice.fromJson(Map<String, dynamic> json) {
    return DiscoveredDevice(
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      ip: json['ip'] as String,
      httpPort: json['http_port'] as int? ?? 80,
      sensorOnline: json['sensor_online'] as bool? ?? false,
    );
  }
}
