import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ble_device.dart';
import '../providers/app_providers.dart';

final scannerFilterProvider = StateProvider<String>((ref) => '');
final scannerMinRssiProvider = StateProvider<double>((ref) => -100);

final filteredScanResultsProvider = Provider<List<BleDevice>>((ref) {
  final results = ref.watch(scanResultsProvider).value ?? [];
  final query = ref.watch(scannerFilterProvider).toLowerCase();
  final minRssi = ref.watch(scannerMinRssiProvider);

  var filtered = results.where((device) {
    if (device.rssi < minRssi) return false;
    if (query.isEmpty) return true;
    return device.name.toLowerCase().contains(query) || 
           device.id.toLowerCase().contains(query);
  }).toList();

  filtered.sort((a, b) => b.rssi.compareTo(a.rssi));
  return filtered;
});
