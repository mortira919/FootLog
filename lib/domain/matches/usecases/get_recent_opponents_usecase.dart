import '../entities/opponent.dart';
import '../repositories/opponents_repository.dart';

class GetRecentOpponentsUseCase {
  final IOpponentsRepository _repo;
  GetRecentOpponentsUseCase(this._repo);
  Future<List<Opponent>> call(String uid, {int limit = 20}) =>
      _repo.getRecent(uid, limit: limit);
}
