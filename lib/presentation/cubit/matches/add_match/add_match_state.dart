import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:footlog/domain/matches/enums/field_type.dart';
import 'package:footlog/domain/matches/enums/weather.dart';

part 'add_match_state.freezed.dart';

@freezed
class AddMatchState with _$AddMatchState {
  const factory AddMatchState({
    @Default(false) bool saving,
    String? error,

    DateTime? date,
    @Default(90) int durationMin,
    @Default('') String yourTeam,
    @Default('') String opponentTeam,
    @Default(0) int yourGoals,
    @Default(0) int opponentGoals,

    String? opponentId,
    String? opponentLogoUrl,
    String? yourLogoUrl,

    @Default(false) bool isUploadingYourLogo,
    @Default(false) bool isUploadingOpponentLogo,

    @Default(FieldType.natural) FieldType fieldType,
    @Default(Weather.sunny) Weather weather,

    @Default(0) int myGoals,
    @Default(0) int myAssists,
    @Default(0) int myInterceptions,
    @Default(0) int myTackles,
    @Default(0) int mySaves,
  }) = _AddMatchState;
}
