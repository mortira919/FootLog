import '../entities/opponent.dart';

abstract class IOpponentsRepository {
  Future<List<Opponent>> getRecent(String uid, {int limit = 20});
  Future<Opponent?> getById(String uid, String id);
  Future<void> upsertFromMatch(
      String uid, {
        required String name,
        DateTime? playedAt,
        String? logoUrl,
      });
  Future<String> uploadLogo(
      String uid, {
        required String opponentId,
        required List<int> bytes,
        String contentType = 'image/jpeg',
      });
}
