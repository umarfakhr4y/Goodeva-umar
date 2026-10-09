import 'package:injectable/injectable.dart';
import '../../domain/entities/device_history.dart';
import '../datasources/database_helper.dart';

import 'package:sqflite/sqflite.dart';

abstract class HistoryRepository {
  Future<void> saveDevice(DeviceHistory device);
  Future<List<DeviceHistory>> getHistory();
  Future<void> clearHistory();
}

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  final DatabaseHelper _databaseHelper;

  HistoryRepositoryImpl(this._databaseHelper);

  @override
  Future<void> saveDevice(DeviceHistory device) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'history',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<DeviceHistory>> getHistory() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('history', orderBy: 'lastSeen DESC');
    return List.generate(maps.length, (i) {
      return DeviceHistory.fromMap(maps[i]);
    });
  }

  @override
  Future<void> clearHistory() async {
    final db = await _databaseHelper.database;
    await db.delete('history');
  }
}
