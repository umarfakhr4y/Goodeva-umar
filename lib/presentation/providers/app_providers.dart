import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../data/repositories/ble_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/ble_device.dart';
import '../../domain/entities/device_history.dart';

final bleRepositoryProvider = Provider<BleRepository>((ref) => getIt<BleRepository>());
final historyRepositoryProvider = Provider<HistoryRepository>((ref) => getIt<HistoryRepository>());

final isScanningProvider = StateProvider<bool>((ref) => false);

final scanResultsProvider = StreamProvider<List<BleDevice>>((ref) {
  final repo = ref.watch(bleRepositoryProvider);
  return repo.scanResults;
});

final historyProvider = FutureProvider<List<DeviceHistory>>((ref) async {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.getHistory();
});
