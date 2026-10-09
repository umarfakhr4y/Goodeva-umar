import 'package:equatable/equatable.dart';

class BleDevice extends Equatable {
  final String id;
  final String name;
  final int rssi;

  const BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });

  BleDevice copyWith({
    String? id,
    String? name,
    int? rssi,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
    );
  }

  String get distanceCategory {
    if (rssi >= -30) return 'Sangat Kuat (< 1m)';
    if (rssi >= -50) return 'Kuat (1-3m)';
    if (rssi >= -70) return 'Cukup (3-10m)';
    if (rssi >= -80) return 'Lemah (10-20m)';
    if (rssi >= -90) return 'Sangat Lemah (> 20m)';
    return 'Sinyal Hilang';
  }

  @override
  List<Object?> get props => [id, name, rssi];
}
