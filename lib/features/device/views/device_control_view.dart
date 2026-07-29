import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premio/core/models/device_info.dart';
import 'package:premio/features/device/providers/device_provider.dart';
import 'package:premio/features/device/providers/device_discovery_provider.dart';

class DeviceControlView extends ConsumerStatefulWidget {
  const DeviceControlView({super.key});

  @override
  ConsumerState<DeviceControlView> createState() => _DeviceControlViewState();
}

class _DeviceControlViewState extends ConsumerState<DeviceControlView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saved = ref.read(savedDeviceProvider);
      if (saved == null) {
        ref.read(deviceDiscoveryProvider.notifier).startDiscovery();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceStatusProvider);
    final savedDevice = ref.watch(savedDeviceProvider);

    if (savedDevice != null) {
      return _buildConnectedCard(savedDevice, deviceState);
    }

    return _buildDiscoveryCard();
  }

  Widget _buildConnectedCard(DeviceInfo device, DeviceState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.deviceName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    device.lastKnownIp ?? 'Ожидание сети...',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              if (state.isConnecting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (state.isConnected)
                const Icon(Icons.check_circle, color: Colors.green)
              else
                const Icon(Icons.error_outline, color: Colors.red),
            ],
          ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (state.debugLog != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black26),
                  ),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      state.debugLog!,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ref.read(savedDeviceProvider.notifier).clearDevice();
                ref.read(deviceStatusProvider.notifier).disconnect();
                ref.read(deviceDiscoveryProvider.notifier).startDiscovery();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Отключиться'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryCard() {
    final discoveryState = ref.watch(deviceDiscoveryProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Поиск парных',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              if (discoveryState.isDiscovering)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (discoveryState.devices.isEmpty && !discoveryState.isDiscovering)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Контроллеры не найдены. Проверьте, что телефон и контроллер подключены к одной Wi-Fi сети.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            
          if (discoveryState.debugLog != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black26),
                ),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Text(
                    discoveryState.debugLog!,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black87),
                  ),
                ),
              ),
            ),
          
          ...discoveryState.devices.map((d) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.hot_tub, color: Color(0xFFFF5D40)),
            title: Text(d.deviceName),
            subtitle: Text('${d.ip} (${d.sensorOnline ? "Датчик онлайн" : "Датчик оффлайн"})'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final newDevice = DeviceInfo(
                deviceId: d.deviceId,
                deviceName: d.deviceName,
                lastKnownIp: d.ip,
                httpPort: d.httpPort,
              );
              ref.read(savedDeviceProvider.notifier).saveDevice(newDevice);
            },
          )),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: discoveryState.isDiscovering 
                  ? null 
                  : () => ref.read(deviceDiscoveryProvider.notifier).startDiscovery(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Повторить поиск'),
            ),
          ),
        ],
      ),
    );
  }
}
