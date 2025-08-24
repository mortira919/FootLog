import '../repositories/opponents_repository.dart';

class UploadOpponentLogoUseCase {
  final IOpponentsRepository _repo;
  UploadOpponentLogoUseCase(this._repo);

  Future<String> call(
      String uid, {
        required String opponentId,
        required List<int> bytes,
        String contentType = 'image/jpeg',
      }) {
    return _repo.uploadLogo(uid, opponentId: opponentId, bytes: bytes, contentType: contentType);
  }
}
