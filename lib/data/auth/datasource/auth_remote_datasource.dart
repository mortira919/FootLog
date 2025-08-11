abstract class AuthRemoteDataSource {
  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> loginWithEmail({
    required String email,
    required String password,
  });

  Future<void> loginWithGoogle();

  Future<void> resetPassword(String email);

  Future<void> logout();
}
