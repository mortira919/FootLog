import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:footlog/domain/wellbeing/entities/wellbeing_entry.dart';
import '../../../domain/wellbeing/repositories/wellbeing_repository.dart';
import 'wellbeing_state.dart';

class WellbeingCubit extends Cubit<WellbeingState> {
  final String uid;
  final WellbeingRepository repo;

  WellbeingCubit({
    required this.uid,
    required this.repo,
  }) : super(WellbeingState(date: DateTime.now()));

  int _clamp(int v, {int min = 0, int max = 10}) =>
      v < min ? min : (v > max ? max : v);

  void prevDay() =>
      emit(state.copyWith(date: state.date.subtract(const Duration(days: 1))));
  void nextDay() =>
      emit(state.copyWith(date: state.date.add(const Duration(days: 1))));

  void setMoodBefore(Mood m) => emit(state.copyWith(moodBefore: m));
  void setMoodAfter(Mood m)  => emit(state.copyWith(moodAfter: m));

  void setEnergy(int v) => emit(state.copyWith(energy: _clamp(v)));

  void setSleepDuration(Duration d) => emit(state.copyWith(sleepDuration: d));
  void setSleepQuality(Quality3 q)   => emit(state.copyWith(sleepQuality: q));

  void setMealDelay(Duration d)        => emit(state.copyWith(mealDelay: d));
  void setNutritionQuality(Quality3 q) => emit(state.copyWith(nutritionQuality: q));

  void toggleDiscomfort([bool? v]) =>
      emit(state.copyWith(discomfort: v ?? !state.discomfort));
  void toggleInjury([bool? v]) =>
      emit(state.copyWith(injury: v ?? !state.injury));

  Future<void> load(DateTime date) async {
    try {
      emit(state.copyWith(date: date, error: null));

      final entry = await repo.loadEntry(uid: uid, date: date);
      if (entry == null) return;

      emit(state.copyWith(
        moodBefore: entry.moodBefore,
        moodAfter: entry.moodAfter,
        energy: entry.energy,
        sleepDuration: Duration(minutes: entry.sleepMinutes),
        sleepQuality: entry.sleepQuality,
        mealDelay: Duration(minutes: entry.mealDelayMinutes),
        nutritionQuality: entry.nutritionQuality,
        discomfort: entry.discomfort,
        injury: entry.injury,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> save() async {
    try {
      emit(state.copyWith(saving: true, error: null));

      final entry = WellbeingEntry(
        date: DateTime(state.date.year, state.date.month, state.date.day),
        moodBefore: state.moodBefore,
        moodAfter: state.moodAfter,
        energy: state.energy,
        sleepMinutes: state.sleepDuration.inMinutes,
        sleepQuality: state.sleepQuality,
        mealDelayMinutes: state.mealDelay.inMinutes,
        nutritionQuality: state.nutritionQuality,
        discomfort: state.discomfort,
        injury: state.injury,
      );

      await repo.saveEntry(uid: uid, entry: entry);
      emit(state.copyWith(saving: false));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }
}
