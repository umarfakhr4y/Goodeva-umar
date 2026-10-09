import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/entities/ble_device.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scanner_viewmodel.dart';
import '../providers/app_providers.dart';
import '../radar/radar_screen.dart';
import '../history/history_screen.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final repo = ref.read(bleRepositoryProvider);
    if (state == AppLifecycleState.paused) {
      if (ref.read(isScanningProvider)) {
        repo.stopScan();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (ref.read(isScanningProvider)) {
        repo.startScan();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(filteredScanResultsProvider);
    final isScanning = ref.watch(isScanningProvider);
    final bluetoothState = ref.watch(bluetoothStateProvider).value;

    if (bluetoothState != null && bluetoothState != BluetoothAdapterState.on) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bluetooth_disabled, color: Colors.redAccent, size: 80),
              SizedBox(height: 16),
              Text('Bluetooth is Off', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Please turn on Bluetooth to scan for devices.', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, // Pure black
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
      body: SafeArea(
        child: Column(
          children: [
            _buildControls(context, ref, isScanning),
            Expanded(
              child: devices.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bluetooth_searching, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text('Mencari perangkat di sekitarmu...', style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  )
                : ListView.builder(
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
        backgroundColor: isScanning ? Colors.redAccent : Colors.grey[800],
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
