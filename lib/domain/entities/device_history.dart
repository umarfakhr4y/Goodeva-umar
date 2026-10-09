import 'package:equatable/equatable.dart';

class DeviceHistory extends Equatable {
  final String id; // MAC Address
  final String name;
  final DateTime lastSeen;

  const DeviceHistory({
    required this.id,
    required this.name,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  factory DeviceHistory.fromMap(Map<String, dynamic> map) {
    return DeviceHistory(
      id: map['id'],
      name: map['name'],
      lastSeen: DateTime.parse(map['lastSeen']),
    );
  }

  @override
  List<Object?> get props => [id, name, lastSeen];
}
