import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:footlog/domain/stats/repositories/stats_repository.dart';

part 'stats_state.freezed.dart';

@freezed
class StatsState with _$StatsState {
  const factory StatsState({
    @Default(false) bool loading,
    String? error,
    StatsBundle? data,
  }) = _StatsState;
}