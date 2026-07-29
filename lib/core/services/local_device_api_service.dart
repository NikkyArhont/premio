import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:premio/core/models/device_status.dart';

class LocalDeviceApiException implements Exception {
  final String message;
  LocalDeviceApiException(this.message);
  @override
  String toString() => message;
}

class LocalDeviceApiService {
  final _timeout = const Duration(seconds: 4);

  String? _baseUrl;
  String? _expectedDeviceId;

  void setDevice(String ip, {int port = 80, String? expectedDeviceId}) {
    var cleanIp = ip.trim();
    if (cleanIp.isEmpty) {
      throw LocalDeviceApiException('IP-адрес контроллера не может быть пустым');
    }

    if (cleanIp.startsWith('http://')) cleanIp = cleanIp.substring(7);
    if (cleanIp.startsWith('https://')) cleanIp = cleanIp.substring(8);
    if (cleanIp.endsWith('/')) cleanIp = cleanIp.substring(0, cleanIp.length - 1);
    
    // В случае если был передан IP с портом в строке, очистим его, но лучше верить параметру port
    if (cleanIp.contains(':')) {
      cleanIp = cleanIp.split(':')[0];
    }

    _baseUrl = 'http://$cleanIp:$port';
    _expectedDeviceId = expectedDeviceId;
  }

  String? get currentBaseUrl => _baseUrl;

  Future<T> _safeRequest<T>(Future<http.Response> Function() requestFunc, T Function(Map<String, dynamic>) parser) async {
    if (_baseUrl == null) {
      throw LocalDeviceApiException('Контроллер не установлен');
    }
    try {
      final response = await requestFunc().timeout(_timeout);
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return parser(data);
        } catch (e) {
          // Если устройство обрезало ответ (частая проблема буферов на ESP32),
          // пытаемся достать нужные данные с помощью регулярных выражений.
          print('DEBUG_CONN: Ошибка разбора JSON, пробуем fallback-парсер. Тело: ${response.body}');
          try {
            final fallbackData = <String, dynamic>{};
            
            final tempMatch = RegExp(r'"temperature"\s*:\s*([\d\.]+)').firstMatch(response.body);
            if (tempMatch != null) fallbackData['temperature'] = double.parse(tempMatch.group(1)!);
            
            final humMatch = RegExp(r'"humidity"\s*:\s*([\d\.]+)').firstMatch(response.body);
            if (humMatch != null) fallbackData['humidity'] = double.parse(humMatch.group(1)!);
            
            final brMatch = RegExp(r'"brightness"\s*:\s*(\d+)').firstMatch(response.body);
            if (brMatch != null) fallbackData['brightness'] = int.parse(brMatch.group(1)!);
            
            final rMatch = RegExp(r'"r"\s*:\s*(\d+)').firstMatch(response.body);
            if (rMatch != null) fallbackData['r'] = int.parse(rMatch.group(1)!);
            
            final gMatch = RegExp(r'"g"\s*:\s*(\d+)').firstMatch(response.body);
            if (gMatch != null) fallbackData['g'] = int.parse(gMatch.group(1)!);
            
            final bMatch = RegExp(r'"b"\s*:\s*(\d+)').firstMatch(response.body);
            if (bMatch != null) fallbackData['b'] = int.parse(bMatch.group(1)!);
            
            final sensorMatch = RegExp(r'"sensor_online"\s*:\s*(true|false)').firstMatch(response.body);
            if (sensorMatch != null) fallbackData['sensor_online'] = sensorMatch.group(1) == 'true';
            
            return parser(fallbackData);
          } catch (fallbackError) {
            throw LocalDeviceApiException('Ошибка разбора JSON. Тело: ${response.body}');
          }
        }
      } else {
        throw LocalDeviceApiException('Ошибка устройства: код ${response.statusCode}');
      }
    } on TimeoutException {
      throw LocalDeviceApiException('Превышено время ожидания ответа (устройство выключено или недоступно)');
    } on SocketException {
      throw LocalDeviceApiException('Контроллер недоступен. Проверьте, что телефон и устройство подключены к одной Wi-Fi сети');
    } catch (e) {
      if (e is LocalDeviceApiException) rethrow;
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('xmlhttprequest') || errorStr.contains('clientexception') || errorStr.contains('failed to fetch') || errorStr.contains('failed host lookup')) {
        throw LocalDeviceApiException('Контроллер недоступен. Проверьте, что телефон и устройство подключены к одной Wi-Fi сети');
      }
      
      throw LocalDeviceApiException('Непредвиденная ошибка: $e');
    }
  }

  Future<void> _safeCommand(Future<http.Response> Function() requestFunc) async {
    if (_baseUrl == null) {
      throw LocalDeviceApiException('Контроллер не установлен');
    }
    try {
      final response = await requestFunc().timeout(_timeout);
      if (response.statusCode != 200) {
        throw LocalDeviceApiException('Ошибка устройства: код ${response.statusCode}');
      }
    } on TimeoutException {
      throw LocalDeviceApiException('Превышено время ожидания ответа (устройство выключено или недоступно)');
    } on SocketException {
      throw LocalDeviceApiException('Контроллер недоступен. Проверьте, что телефон и устройство подключены к одной Wi-Fi сети');
    } catch (e) {
      if (e is LocalDeviceApiException) rethrow;
      throw LocalDeviceApiException('Непредвиденная ошибка: $e');
    }
  }

  Future<DeviceStatus> getStatus() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final status = await _safeRequest(
      () => http.get(Uri.parse('$_baseUrl/status?_t=$timestamp'), headers: {'Connection': 'close'}),
      (data) => DeviceStatus.fromJson(data),
    );

    // Устройство больше не возвращает deviceId в статусе, поэтому проверка удалена.
    
    return status;
  }

  Future<int> setBrightness(int value) async {
    if (value < 0) value = 0;
    if (value > 100) value = 100;
    final baseUri = Uri.parse(_baseUrl!);
    final uri = Uri.http(baseUri.authority, '/brightness', {'value': value.toString()});
    
    await _safeCommand(() => http.get(uri, headers: {'Connection': 'close'}));
    return value;
  }

  Future<void> turnOn() {
    return _safeCommand(
      () => http.get(Uri.parse('$_baseUrl/on'), headers: {'Connection': 'close'}),
    );
  }

  Future<void> turnOff() {
    return _safeCommand(
      () => http.get(Uri.parse('$_baseUrl/off'), headers: {'Connection': 'close'}),
    );
  }

  Future<void> setColor(int r, int g, int b) {
    if (r < 0) r = 0; if (r > 255) r = 255;
    if (g < 0) g = 0; if (g > 255) g = 255;
    if (b < 0) b = 0; if (b > 255) b = 255;
    final baseUri = Uri.parse(_baseUrl!);
    final uri = Uri.http(baseUri.authority, '/color', {
      'r': r.toString(),
      'g': g.toString(),
      'b': b.toString(),
    });

    return _safeCommand(
      () => http.get(uri, headers: {'Connection': 'close'}),
    );
  }
}
