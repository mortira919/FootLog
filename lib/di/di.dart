// lib/di/di.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// AUTH
import 'package:footlog/domain/auth/repositories/auth_repository.dart';
import 'package:footlog/domain/auth/usecases/login_with_email_usecase.dart';
import 'package:footlog/domain/auth/usecases/register_with_email_usecase.dart';
import 'package:footlog/domain/auth/usecases/reset_password_usecase.dart';
import 'package:footlog/domain/auth/usecases/update_password_usecase.dart';
import 'package:footlog/domain/auth/usecases/sign_in_with_google_use_case.dart';
import 'package:footlog/domain/auth/usecases/logout_usecase.dart';
import 'package:footlog/data/auth/repositories/auth_repository_impl.dart';
import 'package:footlog/presentation/cubit/auth/auth_cubit.dart';

// HOME repos (интерфейсы)
import 'package:footlog/domain/home/repositories/stats_repository.dart';
import 'package:footlog/domain/home/repositories/matches_repository.dart';

// HOME repos (mocks/impl)
import 'package:footlog/data/home/mocks/profile_repository_mock.dart';
import 'package:footlog/data/home/mocks/stats_repository_mock.dart';
import 'package:footlog/data/home/mocks/matches_repository_mock.dart';
import 'package:footlog/data/home/repositories/profile_repository_impl.dart';

// HOME use cases
import 'package:footlog/domain/home/usecases/get_player_profile_usecase.dart';
import 'package:footlog/domain/home/usecases/save_player_profile_usecase.dart';
import 'package:footlog/domain/home/usecases/get_quick_stats_usecase.dart';
import 'package:footlog/domain/home/usecases/get_recent_matches_usecase.dart';

import '../domain/home/repositories/profile_repositories.dart';

final getIt = GetIt.instance;

/// useMocks=true — всё на моках.
/// useMocks=false — профиль из Firestore, остальное пока моки.
Future<void> initDependencies({bool useMocks = true}) async {
  // ===== AUTH =====
  _lazy<FirebaseAuth>(() => FirebaseAuth.instance);
  _lazy<GoogleSignIn>(() => GoogleSignIn());

  _lazy<AuthRepository>(() => AuthRepositoryImpl(getIt<FirebaseAuth>(), getIt<GoogleSignIn>()));

  _factory(() => LoginWithEmailUseCase(getIt()));
  _factory(() => RegisterWithEmailUseCase(getIt()));
  _factory(() => ResetPasswordUseCase(getIt()));
  _factory(() => UpdatePasswordUseCase(getIt()));
  _factory(() => SignInWithGoogleUseCase(getIt()));
  _factory(() => LogoutUseCase(getIt()));

  _factory(() => AuthCubit(
    loginUseCase: getIt(),
    registerUseCase: getIt(),
    resetUseCase: getIt(),
    updatePasswordUseCase: getIt(),
    googleUseCase: getIt(),
    logoutUseCase: getIt(),
  ));

  // ===== HOME =====
  _lazy<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Profile repo: переключатель
  if (useMocks) {
    _lazy<ProfileRepository>(() => ProfileRepositoryMock());
  } else {
    _lazy<ProfileRepository>(() => ProfileRepositoryImpl(getIt<FirebaseFirestore>()));
  }

  // Остальные пока моки
  _lazy<StatsRepository>(() => StatsRepositoryMock());
  _lazy<MatchesRepository>(() => MatchesRepositoryMock());

  // UseCases
  _factory(() => GetPlayerProfileUseCase(getIt()));
  _factory(() => SavePlayerProfileUseCase(getIt()));
  _factory(() => GetQuickStatsUseCase(getIt()));
  _factory(() => GetRecentMatchesUseCase(getIt()));
}

// ---- helpers (идемпотентные регистрации)
void _lazy<T extends Object>(T Function() f) {
  if (!GetIt.I.isRegistered<T>()) getIt.registerLazySingleton<T>(f);
}
void _factory<T extends Object>(T Function() f) {
  if (!GetIt.I.isRegistered<T>()) getIt.registerFactory<T>(f);
}
