import '../repositories/auth_repository.dart';
import '../../../core/my_result.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<MyResult<void>> call(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}
