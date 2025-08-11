import '../entities/player_profile.dart';

abstract class ProfileRepository {
  Future<PlayerProfile> getProfile(String uid);
  Future<void> saveProfile(String uid, PlayerProfile profile);
}
