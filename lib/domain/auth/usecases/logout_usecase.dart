import '../repositories/auth_repository.dart';
import '../../../core/my_result.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<MyResult<void>> call() {
    return repository.logout();
  }
}
