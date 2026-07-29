import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:premio/core/models/discovered_device.dart';

class LocalDeviceDiscoveryService {
  Future<List<DiscoveredDevice>> discover({
    Duration timeout = const Duration(seconds: 2),
    void Function(String)? onLog,
  }) async {
    final devices = <String, DiscoveredDevice>{};
    RawDatagramSocket? socket;
    
    try {
      onLog?.call('Binding socket...');
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      final data = utf8.encode('ECM50_DISCOVER');
      final sentBytes = socket.send(data, InternetAddress('255.255.255.255'), 4210);
      onLog?.call('Sent discovery packet (bytes: $sentBytes)');

      final completer = Completer<List<DiscoveredDevice>>();
      
      final sub = socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket!.receive();
          if (datagram != null) {
            onLog?.call('Received datagram from ${datagram.address.address}');
            try {
              final jsonStr = utf8.decode(datagram.data);
              final json = jsonDecode(jsonStr);
              if (json['type'] == 'ecm50_discovery_response') {
                final device = DiscoveredDevice.fromJson(json);
                devices[device.deviceId] = device;
                onLog?.call('Discovered device: ${device.deviceId} at ${device.ip}');
              }
            } catch (e) {
              onLog?.call('Failed to parse datagram: $e');
            }
          }
        }
      });

      Timer(timeout, () {
        sub.cancel();
        socket?.close();
        if (!completer.isCompleted) {
          completer.complete(devices.values.toList());
        }
      });

      return completer.future;
    } catch (e) {
      onLog?.call('Discovery error: $e');
      socket?.close();
      return [];
    }
  }

  Stream<DiscoveredDevice> discoverStream({
    Duration timeout = const Duration(seconds: 2),
  }) {
    final streamController = StreamController<DiscoveredDevice>();
    final seenIds = <String>{};
    RawDatagramSocket? socket;

    Future<void> start() async {
      try {
        socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        socket!.broadcastEnabled = true;

        final data = utf8.encode('ECM50_DISCOVER');
        socket!.send(data, InternetAddress('255.255.255.255'), 4210);

        final sub = socket!.listen((RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            final datagram = socket!.receive();
            if (datagram != null) {
              try {
                final jsonStr = utf8.decode(datagram.data);
                final json = jsonDecode(jsonStr);
                if (json['type'] == 'ecm50_discovery_response') {
                  final device = DiscoveredDevice.fromJson(json);
                  if (!seenIds.contains(device.deviceId)) {
                    seenIds.add(device.deviceId);
                    streamController.add(device);
                  }
                }
              } catch (_) {}
            }
          }
        });

        Timer(timeout, () {
          sub.cancel();
          socket?.close();
          streamController.close();
        });
      } catch (e) {
        socket?.close();
        streamController.addError(e);
        streamController.close();
      }
    }

    start();
    return streamController.stream;
  }
}
