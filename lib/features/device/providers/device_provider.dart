import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:premio/core/providers/shared_prefs_provider.dart';
import 'package:premio/core/services/local_device_api_service.dart';
import 'package:premio/core/models/device_status.dart';
import 'package:premio/core/models/device_info.dart';
import 'package:premio/features/device/providers/device_discovery_provider.dart';

final localDeviceApiServiceProvider = Provider((ref) => LocalDeviceApiService());

final savedDeviceProvider = NotifierProvider<SavedDeviceNotifier, DeviceInfo?>(SavedDeviceNotifier.new);

class SavedDeviceNotifier extends Notifier<DeviceInfo?> {
  late SharedPreferences _prefs;
  
  @override
  DeviceInfo? build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = _prefs.getString('saved_device');
    if (jsonStr != null) {
      try {
        return DeviceInfo.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveDevice(DeviceInfo device) async {
    await _prefs.setString('saved_device', jsonEncode(device.toJson()));
    state = device;
  }

  Future<void> clearDevice() async {
    await _prefs.remove('saved_device');
    state = null;
  }
}

class DeviceState {
  final bool isConnecting;
  final bool isConnected;
  final String? error;
  final DeviceStatus? status;
  final int localBrightness;
  final String? debugLog;

  DeviceState({
    this.isConnecting = false,
    this.isConnected = false,
    this.error,
    this.status,
    this.localBrightness = 0,
    this.debugLog,
  });

  DeviceState copyWith({
    bool? isConnecting,
    bool? isConnected,
    String? error,
    DeviceStatus? status,
    int? localBrightness,
    bool clearError = false,
    String? debugLog,
  }) {
    return DeviceState(
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      error: clearError ? null : (error ?? this.error),
      status: status ?? this.status,
      localBrightness: localBrightness ?? this.localBrightness,
      debugLog: debugLog ?? this.debugLog,
    );
  }
}

final deviceStatusProvider = NotifierProvider<DeviceStatusNotifier, DeviceState>(DeviceStatusNotifier.new);

class DeviceStatusNotifier extends Notifier<DeviceState> {
  late LocalDeviceApiService _api;
  DeviceInfo? _device;
  Timer? _pollingTimer;
  Timer? _debounceTimer;
  bool _isDisposed = false;
  bool _isRequestInProgress = false;

  @override
  DeviceState build() {
    _api = ref.watch(localDeviceApiServiceProvider);
    _device = ref.watch(savedDeviceProvider);
    
    _isDisposed = false; // Убеждаемся, что флаг сброшен при пересоздании провайдера

    ref.onDispose(() {
      _isDisposed = true;
      _pollingTimer?.cancel();
      _debounceTimer?.cancel();
    });
    
    if (_device != null) {
      // Async initialization
      Future.microtask(() => connect());
      return DeviceState(debugLog: 'Инициализация подключения...');
    }
    
    return DeviceState(debugLog: 'Ожидание...');
  }

  void _log(String msg) {
    print('DEBUG_CONN: $msg');
    if (_isDisposed) return;
    state = state.copyWith(debugLog: (state.debugLog ?? '') + '\n- $msg');
  }

  Future<void> connect() async {
    _log('Начало connect()');
    if (_device == null) {
      _log('Ошибка: _device == null');
      state = state.copyWith(error: 'Контроллер не выбран', clearError: false);
      return;
    }

    if (_device!.lastKnownIp == null || _device!.lastKnownIp!.isEmpty) {
      _log('IP пустой, запускаем поиск');
      _tryDiscoveryAndConnect();
      return;
    }

    try {
      _log('Установка IP: ${_device!.lastKnownIp}');
      _api.setDevice(_device!.lastKnownIp!, port: _device!.httpPort, expectedDeviceId: _device!.deviceId);
      state = state.copyWith(isConnecting: true, clearError: true);
      
      _log('Ожидание _api.getStatus()...');
      final status = await _api.getStatus();
      _log('Успешный ответ от getStatus()');
      if (_isDisposed) return;
      
      _handleSuccessfulConnection(status);
    } catch (e) {
      print('DEBUG_CONN: Ошибка getStatus: $e');
      if (!_isDisposed) {
        state = state.copyWith(debugLog: (state.debugLog ?? '') + '\n- Ошибка getStatus: $e');
        _tryDiscoveryAndConnect();
      }
    }
  }

  void _handleSuccessfulConnection(DeviceStatus status) {
    state = state.copyWith(
      isConnecting: false,
      isConnected: true,
      status: status,
      localBrightness: status.brightness,
      clearError: true,
    );
    
    // IP больше не приходит в /status, обновление происходит только при UDP поиске
    _startPolling();
  }

  Future<void> _tryDiscoveryAndConnect() async {
    _log('Начало _tryDiscoveryAndConnect()');
    state = state.copyWith(isConnecting: true, error: 'Поиск устройства в сети...', clearError: false);
    
    final discoveryService = ref.read(localDeviceDiscoveryServiceProvider);
    try {
       _log('Ожидание UDP discover...');
       final devices = await discoveryService.discover(
         timeout: const Duration(seconds: 2),
         onLog: (msg) => _log('UDP: $msg'),
       );
       _log('UDP discover завершен. Найдено: ${devices.length}');
       if (_isDisposed) return;
       
       final match = devices.firstWhere(
         (d) => d.deviceId == _device!.deviceId,
         orElse: () => throw Exception('Не найдено в UDP'),
       );
       
       _log('Устройство найдено в UDP. IP: ${match.ip}');
       // Обновляем IP только если он реально изменился, чтобы избежать бесконечного цикла rebuild-ов
       if (_device!.lastKnownIp != match.ip || _device!.httpPort != match.httpPort) {
         _log('Обновление IP в памяти');
         final updatedDevice = DeviceInfo(
            deviceId: _device!.deviceId,
            deviceName: _device!.deviceName,
            lastKnownIp: match.ip,
            httpPort: match.httpPort,
         );
         ref.read(savedDeviceProvider.notifier).saveDevice(updatedDevice);
       }
       
       _api.setDevice(match.ip, port: match.httpPort, expectedDeviceId: match.deviceId);
       _log('Повторное ожидание getStatus()...');
       final status = await _api.getStatus();
       _log('Повторный getStatus() успешен!');
       if (_isDisposed) return;
       
       _handleSuccessfulConnection(status);
       
    } catch (e) {
       _log('Фатальная ошибка в _tryDiscoveryAndConnect: $e');
       if (_isDisposed) return;
       state = state.copyWith(
         isConnecting: false,
         isConnected: false,
         error: 'Контроллер недоступен. Ошибка: $e',
       );
       _pollingTimer?.cancel();
    }
  }

  void disconnect() {
    _isPollingActive = false;
    _pollingTimer?.cancel();
    state = DeviceState();
  }

  bool _isPollingActive = false;

  void _startPolling() {
    _isPollingActive = true;
    _scheduleNextPoll();
  }

  void _scheduleNextPoll() {
    if (!_isPollingActive || _isDisposed) return;
    _pollingTimer?.cancel();
    _pollingTimer = Timer(const Duration(seconds: 3), () async {
      await _pollStatus();
      if (_isPollingActive && !_isDisposed) {
        _scheduleNextPoll();
      }
    });
  }

  Future<void> _pollStatus() async {
    if (_isRequestInProgress || _isDisposed) return;
    
    _isRequestInProgress = true;
    try {
      final status = await _api.getStatus();
      if (_isDisposed) return;
      
      state = state.copyWith(
        status: status,
        isConnected: true,
        clearError: true,
        localBrightness: _debounceTimer?.isActive == true ? state.localBrightness : status.brightness,
      );
      
      _log('Данные обновлены: Темп ${status.temperature}, Влажн ${status.humidity}');
    } catch (e) {
      if (_isDisposed) return;
      _isPollingActive = false;
      _pollingTimer?.cancel();
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('недоступ') || errorStr.contains('ожидан') || errorStr.contains('тайм-аут') || errorStr.contains('timeout')) {
        // Try to reconnect via discovery
        connect();
      } else {
        state = state.copyWith(
          isConnected: false,
          error: errorStr,
        );
      }
    } finally {
      _isRequestInProgress = false;
    }
  }

  void updateBrightness(int value) {
    if (!state.isConnected) return;
    
    state = state.copyWith(localBrightness: value);
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
      // Ожидаем завершения текущего запроса, чтобы не спамить контроллер
      while (_isRequestInProgress && !_isDisposed) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_isDisposed) return;

      _isRequestInProgress = true;
      try {
        final result = await _api.setBrightness(value);
        if (!_isDisposed) {
           state = state.copyWith(localBrightness: result, clearError: true);
        }
      } catch (e) {
        if (!_isDisposed) {
          state = state.copyWith(error: 'Ошибка изменения яркости: $e');
          if (state.status != null) {
            state = state.copyWith(localBrightness: state.status!.brightness);
          }
        }
      } finally {
        _isRequestInProgress = false;
      }
    });
  }

  Future<void> togglePower(bool turnOn) async {
    if (!state.isConnected) return;
    
    while (_isRequestInProgress && !_isDisposed) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (_isDisposed) return;
    
    _isRequestInProgress = true;
    try {
      if (turnOn) {
        await _api.turnOn();
      } else {
        await _api.turnOff();
      }
      _isRequestInProgress = false; // Освобождаем до вызова _pollStatus, т.к. он тоже ставит лок
      await _pollStatus();
    } catch (e) {
      _isRequestInProgress = false;
      if (!_isDisposed) {
        state = state.copyWith(error: 'Ошибка управления устройства: $e');
      }
    }
  }
}
