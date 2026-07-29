class DeviceStatus {
  final double? temperature;
  final double? humidity;
  final int brightness;
  final int r;
  final int g;
  final int b;
  final bool sensorOnline;

  DeviceStatus({
    this.temperature,
    this.humidity,
    required this.brightness,
    required this.r,
    required this.g,
    required this.b,
    required this.sensorOnline,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      brightness: (json['brightness'] as num?)?.toInt() ?? 0,
      r: (json['r'] as num?)?.toInt() ?? 0,
      g: (json['g'] as num?)?.toInt() ?? 0,
      b: (json['b'] as num?)?.toInt() ?? 0,
      sensorOnline: json['sensor_online'] == true,
    );
  }
}
