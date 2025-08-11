import '../repositories/auth_repository.dart';
import '../../../core/my_result.dart';

class UpdatePasswordUseCase {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<MyResult<void>> call(String newPassword) {
    return repository.updatePassword(newPassword);
  }
}
