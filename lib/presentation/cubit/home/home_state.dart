import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:footlog/domain/home/entities/player_profile.dart';
import 'package:footlog/domain/home/entities/quick_stats.dart';
import 'package:footlog/domain/home/entities/recent_match.dart';
import 'package:footlog/domain/home/enums/period.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(true) bool loading,
    String? error,
    @Default(Period.m1) Period period,
    PlayerProfile? profile,
    QuickStats? stats,
    @Default(<RecentMatch>[]) List<RecentMatch> recent,
  }) = _HomeState;
}
