import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerProfile {
  final String name;
  final DateTime? birthDate;
  final int? heightCm;
  final int? weightKg;
  final String dominantFoot;
  final String position;
  final String? kitNumber;
  final String? teamName;

  const PlayerProfile({
    this.name = '',
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.dominantFoot = 'right',
    this.position = 'ST',
    this.kitNumber,
    this.teamName,
  });

  PlayerProfile copyWith({
    String? name,
    DateTime? birthDate,
    int? heightCm,
    int? weightKg,
    String? dominantFoot,
    String? position,
    String? kitNumber,
    String? teamName,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      dominantFoot: dominantFoot ?? this.dominantFoot,
      position: position ?? this.position,
      kitNumber: kitNumber ?? this.kitNumber,
      teamName: teamName ?? this.teamName,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'birthDate': birthDate == null ? null : Timestamp.fromDate(birthDate!),
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'dominantFoot': dominantFoot,
    'position': position,
    'kitNumber': kitNumber,
    'teamName': teamName,
  }..removeWhere((k, v) => v == null);

  factory PlayerProfile.fromJson(Map<String, dynamic> j) {

    DateTime? bdate;
    final raw = j['birthDate'];
    if (raw is Timestamp) bdate = raw.toDate();
    if (raw is String) bdate = DateTime.tryParse(raw);


    String pos = (j['position'] ?? '') as String;
    if (pos.isEmpty) {
      pos = (j['primaryPosition'] ?? '') as String;
      if (pos.isEmpty) {
        final arr = j['positions'];
        if (arr is List && arr.isNotEmpty && arr.first is String) {
          pos = arr.first as String;
        }
      }
      if (pos.isEmpty) pos = 'ST';
    }

    return PlayerProfile(
      name: (j['name'] ?? '') as String,
      birthDate: bdate,
      heightCm: (j['height_cm'] as num?)?.toInt(),
      weightKg: (j['weight_kg'] as num?)?.toInt(),
      dominantFoot: (j['dominantFoot'] ?? 'right') as String,
      position: pos,
      kitNumber: j['kitNumber'] as String?,
      teamName: j['teamName'] as String?,
    );
  }
}


const positionLabelsRu = <String, String>{
  'GK': 'Вратарь',
  'CB': 'Центральный защитник',
  'LB': 'Левый защитник',
  'RB': 'Правый защитник',
  'CDM': 'Опорный полузащитник',
  'CM': 'Центральный полузащитник',
  'CAM': 'Атакующий полузащитник',
  'RW': 'Правый вингер',
  'LW': 'Левый вингер',
  'ST': 'Страйкер',
};
