import '../entities/user_entity.dart';
import '../../../core/my_result.dart';

abstract class AuthRepository {
  Future<MyResult<UserEntity>> registerWithEmail(String name, String email, String password);
  Future<MyResult<UserEntity>> loginWithEmail(String email, String password);
  Future<MyResult<void>> sendPasswordResetEmail(String email);
  Future<MyResult<void>> updatePassword(String newPassword);
  Future<MyResult<UserEntity>> signInWithGoogle();
  Future<MyResult<void>> logout();
}
