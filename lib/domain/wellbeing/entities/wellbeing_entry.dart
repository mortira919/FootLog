import 'package:cloud_firestore/cloud_firestore.dart';

enum Mood { bad, neutral, good, veryGood }

enum Quality3 { bad, normal, good }

class WellbeingEntry {
  final DateTime date;
  final Mood moodBefore;
  final Mood moodAfter;
  final int energy;

  final int sleepMinutes;
  final Quality3 sleepQuality;

  final int mealDelayMinutes;
  final Quality3 nutritionQuality;

  final bool discomfort;
  final bool injury;

  WellbeingEntry({
    required this.date,
    required this.moodBefore,
    required this.moodAfter,
    required this.energy,
    required this.sleepMinutes,
    required this.sleepQuality,
    required this.mealDelayMinutes,
    required this.nutritionQuality,
    required this.discomfort,
    required this.injury,
  });


  static DateTime onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);


  static String docId(DateTime d) {
    final dd = onlyDate(d);
    final m = dd.month.toString().padLeft(2, '0');
    final day = dd.day.toString().padLeft(2, '0');
    return '${dd.year}-$m-$day';
  }

  Map<String, dynamic> toJson() => {
    'date': Timestamp.fromDate(onlyDate(date)),
    'moodBefore': moodBefore.name,
    'moodAfter': moodAfter.name,
    'energy': energy,
    'sleepMinutes': sleepMinutes,
    'sleepQuality': sleepQuality.name,
    'mealDelayMinutes': mealDelayMinutes,
    'nutritionQuality': nutritionQuality.name,
    'discomfort': discomfort,
    'injury': injury,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory WellbeingEntry.fromJson(Map<String, dynamic> j) {
    Mood _m(String s) => Mood.values.byName(s);
    Quality3 _q(String s) => Quality3.values.byName(s);

    final ts = j['date'];
    final date = ts is Timestamp
        ? ts.toDate()
        : DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now();

    int _i(dynamic v, [int def = 0]) => v == null ? def : (v as num).toInt();

    return WellbeingEntry(
      date: onlyDate(date),
      moodBefore: _m(j['moodBefore'] as String),
      moodAfter: _m(j['moodAfter'] as String),
      energy: _i(j['energy']),
      sleepMinutes: _i(j['sleepMinutes']),
      sleepQuality: _q(j['sleepQuality'] as String),
      mealDelayMinutes: _i(j['mealDelayMinutes']),
      nutritionQuality: _q(j['nutritionQuality'] as String),
      discomfort: (j['discomfort'] as bool?) ?? false,
      injury: (j['injury'] as bool?) ?? false,
    );
  }
}
