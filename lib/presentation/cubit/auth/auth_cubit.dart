import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/my_result.dart';
import '../../../../domain/auth/entities/user_entity.dart';
import '../../../../domain/auth/usecases/login_with_email_usecase.dart';
import '../../../../domain/auth/usecases/register_with_email_usecase.dart';
import '../../../../domain/auth/usecases/reset_password_usecase.dart';
import '../../../../domain/auth/usecases/sign_in_with_google_use_case.dart';
import '../../../../domain/auth/usecases/update_password_usecase.dart';
import '../../../../domain/auth/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginWithEmailUseCase loginUseCase;
  final RegisterWithEmailUseCase registerUseCase;
  final ResetPasswordUseCase resetUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final SignInWithGoogleUseCase googleUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.resetUseCase,
    required this.updatePasswordUseCase,
    required this.googleUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    final result = await loginUseCase(email, password);
    if (result is Success<UserEntity>) {
      emit(AuthState.authenticated(result.data));
    } else {
      emit(AuthState.error((result as Error).message));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(const AuthState.loading());
    final result = await registerUseCase(name, email, password);
    if (result is Success<UserEntity>) {
      emit(AuthState.authenticated(result.data));
    } else {
      emit(AuthState.error((result as Error).message));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());
    final result = await googleUseCase();
    if (result is Success<UserEntity>) {
      emit(AuthState.authenticated(result.data));
    } else {
      emit(AuthState.error((result as Error).message));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(const AuthState.loading());
    final result = await resetUseCase(email);
    if (result is Success<void>) {
      emit(const AuthState.resetLinkSent());
    } else {
      emit(AuthState.error((result as Error).message));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    emit(const AuthState.loading());
    final result = await updatePasswordUseCase(newPassword);
    if (result is Success<void>) {
      emit(const AuthState.passwordUpdated());
    } else {
      emit(AuthState.error((result as Error).message));
    }
  }

  Future<void> logout() async {
    await logoutUseCase();
    emit(const AuthState.initial());
  }
}
