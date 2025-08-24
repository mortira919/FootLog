import 'package:equatable/equatable.dart';
import 'package:footlog/domain/wellbeing/entities/wellbeing_entry.dart';
// Берём Mood и Quality3 из домена, не дублируем!

class WellbeingState extends Equatable {
  final DateTime date;

  final Mood moodBefore;
  final Mood moodAfter;
  final int energy;

  final Duration sleepDuration;
  final Quality3 sleepQuality;

  final Duration mealDelay;
  final Quality3 nutritionQuality;

  final bool discomfort;
  final bool injury;

  final bool saving;
  final String? error;

  const WellbeingState({
    required this.date,
    this.moodBefore = Mood.neutral,
    this.moodAfter  = Mood.neutral,
    this.energy = 5,
    this.sleepDuration = const Duration(hours: 8),
    this.sleepQuality = Quality3.normal,
    this.mealDelay = const Duration(hours: 3),
    this.nutritionQuality = Quality3.normal,
    this.discomfort = false,
    this.injury = false,
    this.saving = false,
    this.error,
  });

  WellbeingState copyWith({
    DateTime? date,
    Mood? moodBefore,
    Mood? moodAfter,
    int? energy,
    Duration? sleepDuration,
    Quality3? sleepQuality,
    Duration? mealDelay,
    Quality3? nutritionQuality,
    bool? discomfort,
    bool? injury,
    bool? saving,
    String? error, // чтобы очистить — передай null явно
  }) {
    return WellbeingState(
      date: date ?? this.date,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter:  moodAfter  ?? this.moodAfter,
      energy: energy ?? this.energy,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      mealDelay: mealDelay ?? this.mealDelay,
      nutritionQuality: nutritionQuality ?? this.nutritionQuality,
      discomfort: discomfort ?? this.discomfort,
      injury: injury ?? this.injury,
      saving: saving ?? this.saving,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    date, moodBefore, moodAfter, energy,
    sleepDuration, sleepQuality,
    mealDelay, nutritionQuality,
    discomfort, injury, saving, error,
  ];
}
