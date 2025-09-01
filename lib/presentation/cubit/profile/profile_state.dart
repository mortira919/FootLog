import 'package:footlog/domain/profile/entities/player_profile.dart';

class ProfileState {
  final bool loading;
  final bool saving;
  final PlayerProfile data;
  final String? error;

  const ProfileState({
    required this.loading,
    required this.saving,
    required this.data,
    this.error,
  });

  factory ProfileState.initial() =>
      const ProfileState(loading: true, saving: false, data: PlayerProfile());

  ProfileState copyWith({
    bool? loading,
    bool? saving,
    PlayerProfile? data,
    String? error,            // pass empty string to clear
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      data: data ?? this.data,
      error: error == '' ? null : (error ?? this.error),
    );
  }
}
