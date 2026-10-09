import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/ble_device.dart';

abstract class BleRepository {
  Stream<List<BleDevice>> get scanResults;
  Future<void> startScan();
  Future<void> stopScan();
  bool get isScanning;
}

@LazySingleton(as: BleRepository)
class BleRepositoryImpl implements BleRepository {
  final _scanResultsController = StreamController<List<BleDevice>>.broadcast();

  BleRepositoryImpl() {
    FlutterBluePlus.scanResults.listen((results) {
      final devices = results.map((r) {
        return BleDevice(
          id: r.device.remoteId.str,
          name: r.device.platformName.isNotEmpty ? r.device.platformName : (r.advertisementData.advName.isNotEmpty ? r.advertisementData.advName : 'Unknown Device'),
          rssi: r.rssi,
        );
      }).toList();
      _scanResultsController.add(devices);
    });
  }

  @override
  Stream<List<BleDevice>> get scanResults => _scanResultsController.stream;

  @override
  Future<void> startScan() async {
    if (FlutterBluePlus.isScanningNow) return;
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15), continuousUpdates: true);
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  @override
  bool get isScanning => FlutterBluePlus.isScanningNow;
}
