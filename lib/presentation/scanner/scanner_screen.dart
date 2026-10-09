import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scanner_viewmodel.dart';
import '../providers/app_providers.dart';
import '../radar/radar_screen.dart';
import '../history/history_screen.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(filteredScanResultsProvider);
    final isScanning = ref.watch(isScanningProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Slate
      appBar: AppBar(
        title: const Text('BLE Scanner', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3B82F6), // Blue 500
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8B5CF6), // Violet 500
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildControls(context, ref, isScanning),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return _DeviceCard(device: device);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final repo = ref.read(bleRepositoryProvider);
          if (isScanning) {
            await repo.stopScan();
            ref.read(isScanningProvider.notifier).state = false;
          } else {
            await repo.startScan();
            ref.read(isScanningProvider.notifier).state = true;
          }
        },
        backgroundColor: isScanning ? Colors.redAccent : Colors.blueAccent,
        icon: Icon(isScanning ? Icons.stop : Icons.play_arrow, color: Colors.white),
        label: Text(isScanning ? 'Stop' : 'Scan', style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref, bool isScanning) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by Name or MAC...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => ref.read(scannerFilterProvider.notifier).state = value,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Min RSSI: ', style: TextStyle(color: Colors.white70)),
              Expanded(
                child: Slider(
                  value: ref.watch(scannerMinRssiProvider),
                  min: -100,
                  max: 0,
                  divisions: 100,
                  label: '${ref.watch(scannerMinRssiProvider).toInt()} dBm',
                  onChanged: (val) => ref.read(scannerMinRssiProvider.notifier).state = val,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends ConsumerWidget {
  final BleDevice device;

  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RadarScreen(device: device)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getColor(device.rssi).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bluetooth, color: _getColor(device.rssi)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.id,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${device.rssi} dBm',
                  style: TextStyle(
                    color: _getColor(device.rssi),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  device.distanceCategory,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Color _getColor(int rssi) {
    if (rssi >= -50) return Colors.greenAccent;
    if (rssi >= -70) return Colors.blueAccent;
    if (rssi >= -80) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
