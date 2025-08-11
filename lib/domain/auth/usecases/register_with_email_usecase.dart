import '../repositories/auth_repository.dart';
import '../../../core/my_result.dart';
import '../entities/user_entity.dart';

class RegisterWithEmailUseCase {
  final AuthRepository repository;

  RegisterWithEmailUseCase(this.repository);

  Future<MyResult<UserEntity>> call(String name, String email, String password) {
    return repository.registerWithEmail(name, email, password);
  }
}
