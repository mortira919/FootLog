import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:footlog/core/my_result.dart';

import 'package:footlog/domain/home/entities/player_profile.dart';
import 'package:footlog/domain/home/enums/period.dart';
import 'package:footlog/domain/home/usecases/get_player_profile_usecase.dart';
import 'package:footlog/domain/home/usecases/save_player_profile_usecase.dart';
import 'package:footlog/domain/home/usecases/get_quick_stats_usecase.dart';
import 'package:footlog/domain/home/usecases/get_recent_matches_usecase.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final String uid;
  final GetPlayerProfileUseCase _getProfile;
  final SavePlayerProfileUseCase _saveProfile;
  final GetQuickStatsUseCase _getStats;
  final GetRecentMatchesUseCase _getRecent;

  HomeCubit({
    required this.uid,
    required GetPlayerProfileUseCase getProfile,
    required SavePlayerProfileUseCase saveProfile,
    required GetQuickStatsUseCase getStats,
    required GetRecentMatchesUseCase getRecent,
  })  : _getProfile = getProfile,
        _saveProfile = saveProfile,
        _getStats = getStats,
        _getRecent = getRecent,
        super(const HomeState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));

    final p = await _getProfile(uid);
    if (p is Error) {
      emit(state.copyWith(loading: false, error: (p as Error).message));
      return;
    }

    final s = await _getStats(uid: uid, period: state.period);
    if (s is Error) {
      emit(state.copyWith(loading: false, error: (s as Error).message));
      return;
    }

    final r = await _getRecent(uid: uid, limit: 5);
    if (r is Error) {
      emit(state.copyWith(loading: false, error: (r as Error).message));
      return;
    }

    emit(state.copyWith(
      loading: false,
      profile: (p as Success).data,
      stats:   (s as Success).data,
      recent:  (r as Success).data,
    ));
  }

  Future<void> changePeriod(Period period) async {
    emit(state.copyWith(period: period, loading: true));
    final s = await _getStats(uid: uid, period: period);
    if (s is Error) {
      emit(state.copyWith(loading: false, error: (s as Error).message));
    } else {
      emit(state.copyWith(loading: false, stats: (s as Success).data));
    }
  }

  Future<void> saveProfile(PlayerProfile updated) async {
    emit(state.copyWith(loading: true));
    final res = await _saveProfile(uid: uid, profile: updated);
    if (res is Error) {
      emit(state.copyWith(loading: false, error: (res as Error).message));
    } else {
      emit(state.copyWith(loading: false, profile: updated));
    }
  }
}
