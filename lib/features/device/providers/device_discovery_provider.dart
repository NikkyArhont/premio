import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premio/core/models/discovered_device.dart';
import 'package:premio/core/services/local_device_discovery_service.dart';

final localDeviceDiscoveryServiceProvider = Provider((ref) => LocalDeviceDiscoveryService());

class DeviceDiscoveryState {
  final bool isDiscovering;
  final List<DiscoveredDevice> devices;
  final String? error;
  final String? debugLog;

  DeviceDiscoveryState({
    this.isDiscovering = false,
    this.devices = const [],
    this.error,
    this.debugLog,
  });

  DeviceDiscoveryState copyWith({
    bool? isDiscovering,
    List<DiscoveredDevice>? devices,
    String? error,
    bool clearError = false,
    String? debugLog,
  }) {
    return DeviceDiscoveryState(
      isDiscovering: isDiscovering ?? this.isDiscovering,
      devices: devices ?? this.devices,
      error: clearError ? null : (error ?? this.error),
      debugLog: debugLog ?? this.debugLog,
    );
  }
}

final deviceDiscoveryProvider = NotifierProvider<DeviceDiscoveryNotifier, DeviceDiscoveryState>(DeviceDiscoveryNotifier.new);

class DeviceDiscoveryNotifier extends Notifier<DeviceDiscoveryState> {
  late LocalDeviceDiscoveryService _service;
  StreamSubscription? _sub;

  @override
  DeviceDiscoveryState build() {
    _service = ref.watch(localDeviceDiscoveryServiceProvider);
    
    ref.onDispose(() {
      _sub?.cancel();
    });
    
    return DeviceDiscoveryState();
  }

  void startDiscovery() {
    _sub?.cancel();
    state = state.copyWith(isDiscovering: true, devices: [], clearError: true, debugLog: 'Starting stream discovery...');
    
    // Wait, stream doesn't have onLog. We can't log inner socket binding here easily, 
    // unless we modify discoverStream to take onLog. 
    // We already modified discover, let's also pass onLog to discoverStream?
    // Let me just log what we get.
    _sub = _service.discoverStream(timeout: const Duration(seconds: 3)).listen(
      (device) {
        state = state.copyWith(debugLog: (state.debugLog ?? '') + '\nFound: ${device.ip}');
        final current = List<DiscoveredDevice>.from(state.devices);
        final idx = current.indexWhere((d) => d.deviceId == device.deviceId);
        if (idx >= 0) {
          current[idx] = device;
        } else {
          current.add(device);
        }
        state = state.copyWith(devices: current);
      },
      onError: (e) {
        state = state.copyWith(isDiscovering: false, error: e.toString(), debugLog: (state.debugLog ?? '') + '\nError: $e');
      },
      onDone: () {
        state = state.copyWith(isDiscovering: false, debugLog: (state.debugLog ?? '') + '\nDone.');
      },
    );
  }
}
