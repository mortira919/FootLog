import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:footlog/di/di.dart';
import 'package:footlog/core/my_result.dart';

import 'package:footlog/domain/home/enums/outcome.dart';

import 'package:footlog/domain/matches/entities/match_item.dart';
import 'package:footlog/domain/matches/entities/opponent.dart';
import 'package:footlog/domain/matches/enums/field_type.dart';
import 'package:footlog/domain/matches/enums/weather.dart';

import 'package:footlog/domain/matches/usecases/add_match_usecase.dart';
import 'package:footlog/domain/matches/usecases/upload_opponent_logo_usecase.dart';
import 'package:footlog/domain/matches/usecases/upsert_opponent_from_match_usecase.dart';
import 'package:footlog/domain/matches/usecases/upload_your_team_logo_usecase.dart';

import 'add_match_state.dart';

class AddMatchCubit extends Cubit<AddMatchState> {
  final String uid;
  final AddMatchUseCase _addMatch;

  AddMatchCubit({
    required this.uid,
    required AddMatchUseCase addMatch,
  })  : _addMatch = addMatch,
        super(const AddMatchState());

  int _clamp(int v, {int min = 0, int max = 999}) =>
      v < min ? min : (v > max ? max : v);

  // ---------- setters ----------
  void setDateDuration(DateTime date, int durationMin) =>
      emit(state.copyWith(date: date, durationMin: durationMin));

  void setTeams({String? yours, String? opponent}) => emit(
    state.copyWith(
      yourTeam: yours ?? state.yourTeam,
      opponentTeam: opponent ?? state.opponentTeam,
    ),
  );

  void setGoals({int? you, int? opp}) => emit(
    state.copyWith(
      yourGoals: you ?? state.yourGoals,
      opponentGoals: opp ?? state.opponentGoals,
    ),
  );

  void setFieldType(FieldType f) => emit(state.copyWith(fieldType: f));
  void setWeather(Weather w) => emit(state.copyWith(weather: w));

  void setOpponentLogo(String? url) =>
      emit(state.copyWith(opponentLogoUrl: url));
  void setYourLogo(String? url) => emit(state.copyWith(yourLogoUrl: url));

  // выбрать соперника из «последних»
  void setOpponentFromRecent(Opponent o) => emit(
    state.copyWith(
      opponentId: o.id,
      opponentTeam: o.name,
      opponentLogoUrl: o.logoUrl,
    ),
  );

  // ---------- личная статистика ----------
  void setPersonalStats({
    int? goals,
    int? assists,
    int? interceptions,
    int? tackles,
    int? saves,
  }) {
    emit(state.copyWith(
      myGoals: _clamp(goals ?? state.myGoals),
      myAssists: _clamp(assists ?? state.myAssists),
      myInterceptions: _clamp(interceptions ?? state.myInterceptions),
      myTackles: _clamp(tackles ?? state.myTackles),
      mySaves: _clamp(saves ?? state.mySaves),
    ));
  }

  void incGoals() => setPersonalStats(goals: state.myGoals + 1);
  void decGoals() => setPersonalStats(goals: state.myGoals - 1);

  void incAssists() => setPersonalStats(assists: state.myAssists + 1);
  void decAssists() => setPersonalStats(assists: state.myAssists - 1);

  void incInterceptions() =>
      setPersonalStats(interceptions: state.myInterceptions + 1);
  void decInterceptions() =>
      setPersonalStats(interceptions: state.myInterceptions - 1);

  void incTackles() => setPersonalStats(tackles: state.myTackles + 1);
  void decTackles() => setPersonalStats(tackles: state.myTackles - 1);

  void incSaves() => setPersonalStats(saves: state.mySaves + 1);
  void decSaves() => setPersonalStats(saves: state.mySaves - 1);

  // ---------- загрузка логотипов ----------
  Future<void> pickAndUploadOpponentLogo() async {
    try {
      final name = state.opponentTeam.trim();
      if (name.isEmpty) return;

      final id = Opponent.idFromName(name);

      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      final url = await getIt<UploadOpponentLogoUseCase>()(
        uid,
        opponentId: id,
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      setOpponentLogo(url);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> pickAndUploadYourLogo() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      final url = await getIt<UploadYourTeamLogoUseCase>()(
        uid,
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      setYourLogo(url);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // ---------- submit ----------
  Future<MyResult<String>> submit() async {
    if (state.date == null) {
      const msg = 'Укажи дату';
      emit(state.copyWith(error: msg));
      return const Error(msg);
    }

    emit(state.copyWith(saving: true, error: null));

    try {
      // 1) апсерт соперника (RTDB)
      await getIt<UpsertOpponentFromMatchUseCase>()(
        uid,
        name: state.opponentTeam.trim(),
        playedAt: state.date,
        logoUrl: state.opponentLogoUrl,
      );

      // 2) создаём матч (позиции в матче больше нет)
      final outcome = state.yourGoals == state.opponentGoals
          ? Outcome.draw
          : (state.yourGoals > state.opponentGoals ? Outcome.win : Outcome.loss);

      final m = MatchItem(
        date: state.date!,
        durationMin: state.durationMin,
        yourTeam: state.yourTeam.trim(),
        opponentTeam: state.opponentTeam.trim(),
        yourGoals: state.yourGoals,
        opponentGoals: state.opponentGoals,
        fieldType: state.fieldType,
        weather: state.weather,
        outcome: outcome,
        opponentLogoUrl: state.opponentLogoUrl,
        myGoals: state.myGoals,
        myAssists: state.myAssists,
        myInterceptions: state.myInterceptions,
        myTackles: state.myTackles,
        mySaves: state.mySaves,
      );

      final res = await _addMatch(uid, m);
      emit(state.copyWith(saving: false));
      return res;
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
      return Error(e.toString());
    }
  }
}
