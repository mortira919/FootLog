import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:footlog/domain/profile/entities/player_profile.dart';
import 'package:footlog/domain/profile/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repo;
  final String uid;

  ProfileCubit({required this.repo, required this.uid})
      : super(ProfileState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: ''));
    try {
      final data = await repo.getProfile(uid) ?? const PlayerProfile();
      emit(state.copyWith(loading: false, data: data));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> save() async {
    emit(state.copyWith(saving: true, error: ''));
    try {
      await repo.saveProfile(uid, state.data);
      emit(state.copyWith(saving: false));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }


  void updateName(String v) =>
      emit(state.copyWith(data: state.data.copyWith(name: v)));

  void updateTeamName(String v) =>
      emit(state.copyWith(data: state.data.copyWith(teamName: v.isEmpty ? null : v)));

  void updateKitNumber(String v) =>
      emit(state.copyWith(data: state.data.copyWith(kitNumber: v.isEmpty ? null : v)));

  void updateBirthDate(DateTime? d) =>
      emit(state.copyWith(data: state.data.copyWith(birthDate: d)));

  void updateHeight(String v) {
    final parsed = int.tryParse(v);
    emit(state.copyWith(data: state.data.copyWith(heightCm: parsed)));
  }

  void updateWeight(String v) {
    final parsed = int.tryParse(v);
    emit(state.copyWith(data: state.data.copyWith(weightKg: parsed)));
  }

  void updateDominantFoot(String foot) =>
      emit(state.copyWith(data: state.data.copyWith(dominantFoot: foot)));

  void updatePosition(String code) =>
      emit(state.copyWith(data: state.data.copyWith(position: code)));
}
