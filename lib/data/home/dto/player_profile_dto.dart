import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerProfileDto {
  final String name;
  final String primaryPosition; // 'ST', 'RW' и т.д.
  final List<String> positions; // ['ST','RW','LW']
  final Timestamp? updatedAt;

  PlayerProfileDto({
    required this.name,
    required this.primaryPosition,
    required this.positions,
    this.updatedAt,
  });

  factory PlayerProfileDto.fromJson(Map<String, dynamic> j) => PlayerProfileDto(
    name: (j['name'] ?? '') as String,
    primaryPosition: (j['primaryPosition'] ?? 'ST') as String,
    positions: (j['positions'] as List<dynamic>? ?? const [])
        .map((e) => e as String)
        .toList(),
    updatedAt: j['updatedAt'] as Timestamp?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'primaryPosition': primaryPosition,
    'positions': positions,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
