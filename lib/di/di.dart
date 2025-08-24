// lib/di/di.dart
import 'package:get_it/get_it.dart';

// ===== Firebase core =====
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

// ===== AUTH =====
import 'package:footlog/domain/auth/repositories/auth_repository.dart';
import 'package:footlog/data/auth/repositories/auth_repository_impl.dart';
import 'package:footlog/domain/auth/usecases/login_with_email_usecase.dart';
import 'package:footlog/domain/auth/usecases/register_with_email_usecase.dart';
import 'package:footlog/domain/auth/usecases/reset_password_usecase.dart';
import 'package:footlog/domain/auth/usecases/update_password_usecase.dart';
import 'package:footlog/domain/auth/usecases/sign_in_with_google_use_case.dart';
import 'package:footlog/domain/auth/usecases/logout_usecase.dart';
import 'package:footlog/presentation/cubit/auth/auth_cubit.dart';
import 'package:footlog/domain/matches/usecases/upload_your_team_logo_usecase.dart';

// ===== HOME (Profile / QuickStats / Recent) =====
import 'package:footlog/domain/home/repositories/profile_repositories.dart';
import 'package:footlog/data/home/mocks/profile_repository_mock.dart';
import 'package:footlog/data/home/repositories/profile_repository_impl.dart';
// импорты


import 'package:footlog/domain/home/usecases/get_player_profile_usecase.dart';
import 'package:footlog/domain/home/usecases/save_player_profile_usecase.dart';
import 'package:footlog/domain/home/usecases/get_quick_stats_usecase.dart';
import 'package:footlog/domain/home/usecases/get_recent_matches_usecase.dart';

import 'package:footlog/data/home/repositories/home_matches_repository_adapter.dart';
import 'package:footlog/domain/home/repositories/matches_repository.dart' as home_repos;

// ===== MATCHES feature (add/update/delete) =====
import 'package:footlog/domain/matches/repositories/matches_repository.dart' as matches_repos;
import 'package:footlog/data/matches/repositories/matches_repository_impl.dart';
import 'package:footlog/domain/matches/usecases/add_match_usecase.dart';
import 'package:footlog/domain/matches/usecases/update_match_usecase.dart';
import 'package:footlog/domain/matches/usecases/delete_match_usecase.dart';
import 'package:footlog/data/home/mocks/stats_repository_mock.dart' as stats_mock;

// ===== OPPONENTS (recent + logo) =====
import 'package:footlog/domain/matches/repositories/opponents_repository.dart';
import 'package:footlog/data/matches/opponents/opponents_repository_rtdb.dart';
import 'package:footlog/domain/matches/usecases/get_recent_opponents_usecase.dart';
import 'package:footlog/domain/matches/usecases/upsert_opponent_from_match_usecase.dart';
import 'package:footlog/domain/matches/usecases/upload_opponent_logo_usecase.dart';

// ===== PERFORMANCE STATS (общий репозиторий для Home и экрана «Статистика») =====
import 'package:footlog/domain/stats/repositories/stats_repository.dart' as stats; // ← ЕДИНСТВЕННЫЙ интерфейс
import 'package:footlog/data/stats/stats_repository_impl.dart' as stats_impl;
// если мок лежит у тебя в другом месте — поменяй путь на свой:

import 'package:footlog/presentation/cubit/stats/stats_cubit.dart';

import '../data/wellbeing/repository/wellbeing_repository_impl.dart';
import '../domain/wellbeing/repositories/wellbeing_repository.dart';
import '../presentation/cubit/wellbeing/wellbeing_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies({bool useMocks = true}) async {
  // ===== CORE =====
  _lazy<FirebaseAuth>(() => FirebaseAuth.instance);
  _lazy<GoogleSignIn>(() => GoogleSignIn());
  _lazy<FirebaseFirestore>(() => FirebaseFirestore.instance);
  _lazy<FirebaseDatabase>(() => FirebaseDatabase.instance);
  _lazy<FirebaseStorage>(() => FirebaseStorage.instance);

  // ===== AUTH =====
  _lazy<AuthRepository>(() => AuthRepositoryImpl(
    getIt<FirebaseAuth>(),
    getIt<GoogleSignIn>(),
  ));
  _factory(() => UploadYourTeamLogoUseCase(getIt()));
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

  // ===== HOME: Profile =====
  if (useMocks) {
    _lazy<ProfileRepository>(() => ProfileRepositoryMock());
  } else {
    _lazy<ProfileRepository>(() => ProfileRepositoryImpl(getIt<FirebaseFirestore>()));
  }

  // ===== MATCHES (реальный Firestore) =====
  _lazy<matches_repos.MatchesRepository>(
          () => MatchesRepositoryImpl(getIt<FirebaseFirestore>()));

  // HOME.RecentMatches — адаптер над реальным репозиторием матчей
  _lazy<home_repos.MatchesRepository>(
          () => HomeMatchesRepositoryAdapter(getIt<matches_repos.MatchesRepository>()));

  // UseCases (HOME)
  _factory(() => GetPlayerProfileUseCase(getIt<ProfileRepository>()));
  _factory(() => SavePlayerProfileUseCase(getIt<ProfileRepository>()));
  _factory(() => GetRecentMatchesUseCase(getIt<home_repos.MatchesRepository>()));

  // ===== STATS (один общий источник для Home QuickStats и экрана «Статистика») =====
  if (useMocks) {
    _lazy<stats.StatsRepository>(() => stats_mock.StatsRepositoryMock());
  } else {
    _lazy<stats.StatsRepository>(() => stats_impl.StatsRepositoryImpl(getIt<FirebaseFirestore>()));
  }

  // QuickStats на Home считает из ЭТОГО ЖЕ репозитория
  _factory(() => GetQuickStatsUseCase(getIt<stats.StatsRepository>()));

  // Экран «Статистика»: кубит с параметром uid
  if (!GetIt.I.isRegistered<StatsCubit>()) {
    getIt.registerFactoryParam<StatsCubit, String, void>(
          (uid, _) => StatsCubit(getIt<stats.StatsRepository>(), uid),
    );
  }

  // ===== OPPONENTS =====
  _lazy<IOpponentsRepository>(() => OpponentsRepositoryRtdb(
    getIt<FirebaseDatabase>(),
    getIt<FirebaseStorage>(),
  ));
  _factory(() => GetRecentOpponentsUseCase(getIt<IOpponentsRepository>()));
  _factory(() => UpsertOpponentFromMatchUseCase(getIt<IOpponentsRepository>()));
  _factory(() => UploadOpponentLogoUseCase(getIt<IOpponentsRepository>()));

  // UseCases (MATCHES feature)
  _factory(() => AddMatchUseCase(getIt<matches_repos.MatchesRepository>()));
  _factory(() => UpdateMatchUseCase(getIt<matches_repos.MatchesRepository>()));
  _factory(() => DeleteMatchUseCase(getIt<matches_repos.MatchesRepository>()));
  // ===== WELLBEING =====
  _lazy<WellbeingRepository>(() => WellbeingRepositoryImpl(getIt<FirebaseFirestore>()));

// фабрика кубита с параметром uid
  if (!GetIt.I.isRegistered<WellbeingCubit>()) {
    getIt.registerFactoryParam<WellbeingCubit, String, DateTime?>(
          (uid, initialDate) {
        final c = WellbeingCubit(uid: uid, repo: getIt<WellbeingRepository>());
        c.load(initialDate ?? DateTime.now());
        return c;
      },
    );
  }

}

// ---- helpers
void _lazy<T extends Object>(T Function() f) {
  if (!GetIt.I.isRegistered<T>()) getIt.registerLazySingleton<T>(f);
}
void _factory<T extends Object>(T Function() f) {
  if (!GetIt.I.isRegistered<T>()) getIt.registerFactory<T>(f);
}
