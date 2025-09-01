import 'package:footlog/domain/matches/repositories/your_teams_repository.dart';

class UploadYourTeamLogoUseCase {
  final IYourTeamsRepository _repo;
  UploadYourTeamLogoUseCase(this._repo);

  Future<String> call(
      String uid, {
        required String teamId,
        required List<int> bytes,
        String contentType = 'image/jpeg',
      }) {
    return _repo.uploadLogo(
      uid,
      teamId: teamId,
      bytes: bytes,
      contentType: contentType,
    );
  }
}
