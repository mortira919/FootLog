import '../repositories/auth_repository.dart';
import '../../../core/my_result.dart';
import '../entities/user_entity.dart';

class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<MyResult<UserEntity>> call(String email, String password) {
    return repository.loginWithEmail(email, password);
  }
}
