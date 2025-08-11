import '../repositories/auth_repository.dart';
import '../../../core/my_result.dart';
import '../entities/user_entity.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<MyResult<UserEntity>> call() {
    return repository.signInWithGoogle();
  }
}
