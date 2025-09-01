import '../entities/your_team.dart';

abstract class IYourTeamsRepository {
  Future<List<YourTeam>> getRecent(String uid, {int limit = 20});
  Future<YourTeam?> getById(String uid, String id);

  Future<void> upsertFromMatch(
      String uid, {
        required String name,
        DateTime? playedAt,
        String? logoUrl,
      });

  Future<String> uploadLogo(
      String uid, {
        required String teamId,
        required List<int> bytes,
        String contentType,
      });
}
