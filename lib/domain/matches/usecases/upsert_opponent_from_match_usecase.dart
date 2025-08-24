import '../repositories/opponents_repository.dart';

class UpsertOpponentFromMatchUseCase {
  final IOpponentsRepository _repo;
  UpsertOpponentFromMatchUseCase(this._repo);

  Future<void> call(
      String uid, {
        required String name,
        DateTime? playedAt,
        String? logoUrl,
      }) {
    return _repo.upsertFromMatch(uid, name: name, playedAt: playedAt, logoUrl: logoUrl);
  }
}
