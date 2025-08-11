import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/my_result.dart';
import '../../../domain/auth/entities/user_entity.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._firebaseAuth, this._googleSignIn);

  @override
  Future<MyResult<UserEntity>> registerWithEmail(String name, String email, String password) async {
    try {
      final userCred = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await userCred.user?.updateDisplayName(name);
      final user = userCred.user!;
      final model = UserModel.fromFirebaseUser(user);
      return Success(model.toEntity());
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<MyResult<UserEntity>> loginWithEmail(String email, String password) async {
    try {
      final userCred = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final user = userCred.user!;
      final model = UserModel.fromFirebaseUser(user);
      return Success(model.toEntity());
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<MyResult<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<MyResult<void>> updatePassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
      return Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<MyResult<UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return Error('Google sign-in aborted');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _firebaseAuth.signInWithCredential(credential);
      final user = userCred.user!;
      final model = UserModel.fromFirebaseUser(user);
      return Success(model.toEntity());
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<MyResult<void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      return Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
