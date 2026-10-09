import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ble_device.dart';
import '../../domain/entities/device_history.dart';
import '../providers/app_providers.dart';

class RadarScreen extends ConsumerStatefulWidget {
  final BleDevice device;

  const RadarScreen({super.key, required this.device});

  @override
  ConsumerState<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends ConsumerState<RadarScreen> with SingleTickerProviderStateMixin {
  late BleDevice currentDevice;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    currentDevice = widget.device;
    
    // Save to history immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyRepositoryProvider).saveDevice(DeviceHistory(
        id: currentDevice.id,
        name: currentDevice.name,
        lastSeen: DateTime.now(),
      ));
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to updates for this specific device
    final devices = ref.watch(scanResultsProvider).value ?? [];
    final updatedDevice = devices.cast<BleDevice?>().firstWhere(
      (d) => d?.id == currentDevice.id,
      orElse: () => null,
    );

    if (updatedDevice != null) {
      currentDevice = updatedDevice;
    }

    final color = _getColor(currentDevice.rssi);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Radar View'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.center,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          
          // Radar pulsing circles
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 100.0 + (index * 80) + (_pulseController.value * 40),
                    height: 100.0 + (index * 80) + (_pulseController.value * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.2 - (index * 0.05)),
                        width: 2,
                      ),
                      color: color.withOpacity(0.05),
                    ),
                  );
                }),
              );
            },
          ),
          
          // Center Device Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                )
              ]
            ),
            child: Icon(Icons.bluetooth_searching, size: 64, color: color),
          ),

          // Detail Information Panel
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentDevice.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentDevice.id,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBlock('Signal Strength', '${currentDevice.rssi} dBm', color),
                      _buildInfoBlock('Est. Distance', currentDevice.distanceCategory, color),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getColor(int rssi) {
    if (rssi >= -30) return Colors.greenAccent;
    if (rssi >= -50) return Colors.lightGreenAccent;
    if (rssi >= -70) return Colors.blueAccent;
    if (rssi >= -80) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
