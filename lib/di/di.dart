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

// ===== HOME (Profile / QuickStats / Recent) =====
import 'package:footlog/domain/home/repositories/profile_repositories.dart' as home_profile;
import 'package:footlog/data/home/mocks/profile_repository_mock.dart' as home_profile_mock;
import 'package:footlog/data/home/repositories/profile_repository_impl.dart' as home_profile_impl;

import 'package:footlog/domain/home/usecases/get_player_profile_usecase.dart';
import 'package:footlog/domain/home/usecases/save_player_profile_usecase.dart';
import 'package:footlog/domain/home/usecases/get_quick_stats_usecase.dart';
import 'package:footlog/domain/home/usecases/get_recent_matches_usecase.dart';

// читаем recent matches с обоими logoUrl
import 'package:footlog/data/home/repositories/matches_repository_impl.dart' as home_matches_impl;
import 'package:footlog/domain/home/repositories/matches_repository.dart' as home_repos;

// ===== MATCHES feature (add/update/delete) =====
import 'package:footlog/domain/matches/repositories/matches_repository.dart' as matches_repos;
import 'package:footlog/data/matches/repositories/matches_repository_impl.dart';
import 'package:footlog/domain/matches/usecases/add_match_usecase.dart';
import 'package:footlog/domain/matches/usecases/update_match_usecase.dart';
import 'package:footlog/domain/matches/usecases/delete_match_usecase.dart';

// ===== OPPONENTS (recent + logo) =====
import 'package:footlog/domain/matches/repositories/opponents_repository.dart';
import 'package:footlog/data/matches/opponents/opponents_repository_rtdb.dart';
import 'package:footlog/domain/matches/usecases/get_recent_opponents_usecase.dart';
import 'package:footlog/domain/matches/usecases/upsert_opponent_from_match_usecase.dart';
import 'package:footlog/domain/matches/usecases/upload_opponent_logo_usecase.dart';

// ===== YOUR TEAMS (аналог opponents) =====
import 'package:footlog/domain/matches/repositories/your_teams_repository.dart';
import 'package:footlog/data/matches/your_teams/your_teams_repository_rtdb.dart';
import 'package:footlog/domain/matches/usecases/upload_your_team_logo_usecase.dart';

// ===== STATS =====
import 'package:footlog/domain/stats/repositories/stats_repository.dart' as stats;
import 'package:footlog/data/stats/stats_repository_impl.dart' as stats_impl;
import 'package:footlog/data/home/mocks/stats_repository_mock.dart' as stats_mock;
import 'package:footlog/presentation/cubit/stats/stats_cubit.dart';

// ===== WELLBEING =====
import 'package:footlog/data/wellbeing/repository/wellbeing_repository_impl.dart';
import 'package:footlog/domain/wellbeing/repositories/wellbeing_repository.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_cubit.dart';

// ===== PROFILE (экран редактирования профиля) =====
import 'package:footlog/domain/profile/repositories/profile_repository.dart' as edit_profile;
import 'package:footlog/data/profile/repositories/profile_repository_impl.dart' as edit_profile_impl;
import 'package:footlog/presentation/cubit/profile/profile_cubit.dart';

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

  // ===== HOME: Profile (для главного экрана) =====
  if (useMocks) {
    _lazy<home_profile.ProfileRepository>(() => home_profile_mock.ProfileRepositoryMock());
  } else {
    _lazy<home_profile.ProfileRepository>(() => home_profile_impl.ProfileRepositoryImpl(getIt<FirebaseFirestore>()));
  }
  _factory(() => GetPlayerProfileUseCase(getIt<home_profile.ProfileRepository>()));
  _factory(() => SavePlayerProfileUseCase(getIt<home_profile.ProfileRepository>()));

  // ===== MATCHES (FS для добавления/редактирования) =====
  _lazy<matches_repos.MatchesRepository>(() => MatchesRepositoryImpl(getIt<FirebaseFirestore>()));
  _factory(() => AddMatchUseCase(getIt<matches_repos.MatchesRepository>()));
  _factory(() => UpdateMatchUseCase(getIt<matches_repos.MatchesRepository>()));
  _factory(() => DeleteMatchUseCase(getIt<matches_repos.MatchesRepository>()));

  // ===== HOME: RecentMatches (читает yourLogoUrl + opponentLogoUrl) =====
  _lazy<home_repos.MatchesRepository>(() => home_matches_impl.HomeMatchesRepositoryImpl(getIt<FirebaseFirestore>()));
  _factory(() => GetRecentMatchesUseCase(getIt<home_repos.MatchesRepository>()));

  // ===== STATS =====
  if (useMocks) {
    _lazy<stats.StatsRepository>(() => stats_mock.StatsRepositoryMock());
  } else {
    _lazy<stats.StatsRepository>(() => stats_impl.StatsRepositoryImpl(getIt<FirebaseFirestore>()));
  }
  _factory(() => GetQuickStatsUseCase(getIt<stats.StatsRepository>()));
  if (!getIt.isRegistered<StatsCubit>()) {
    getIt.registerFactoryParam<StatsCubit, String, void>(
          (uid, _) => StatsCubit(getIt<stats.StatsRepository>(), uid),
    );
  }

  // ===== OPPONENTS (RTDB + Storage) =====
  _lazy<IOpponentsRepository>(() => OpponentsRepositoryRtdb(
    getIt<FirebaseDatabase>(),
    getIt<FirebaseStorage>(),
  ));
  _factory(() => GetRecentOpponentsUseCase(getIt<IOpponentsRepository>()));
  _factory(() => UpsertOpponentFromMatchUseCase(getIt<IOpponentsRepository>()));
  _factory(() => UploadOpponentLogoUseCase(getIt<IOpponentsRepository>()));

  // ===== YOUR TEAMS (аналог opponents; хранит лого вашей команды) =====
  _lazy<IYourTeamsRepository>(() => YourTeamsRepositoryRtdb(
    getIt<FirebaseDatabase>(),
    getIt<FirebaseStorage>(),
  ));
  _factory(() => UploadYourTeamLogoUseCase(getIt<IYourTeamsRepository>()));

  // ===== WELLBEING =====
  _lazy<WellbeingRepository>(() => WellbeingRepositoryImpl(getIt<FirebaseFirestore>()));
  if (!getIt.isRegistered<WellbeingCubit>()) {
    getIt.registerFactoryParam<WellbeingCubit, String, DateTime?>(
          (uid, initialDate) {
        final c = WellbeingCubit(uid: uid, repo: getIt<WellbeingRepository>());
        c.load(initialDate ?? DateTime.now());
        return c;
      },
    );
  }

  // ===== PROFILE (экран редактирования профиля) =====
  _lazy<edit_profile.ProfileRepository>(() => edit_profile_impl.ProfileRepositoryImpl(getIt<FirebaseFirestore>()));
  if (!getIt.isRegistered<ProfileCubit>()) {
    getIt.registerFactoryParam<ProfileCubit, String, void>(
          (uid, _) => ProfileCubit(
        repo: getIt<edit_profile.ProfileRepository>(),
        uid: uid,
      ),
    );
  }
}

// ---- helpers
void _lazy<T extends Object>(T Function() f) {
  if (!getIt.isRegistered<T>()) getIt.registerLazySingleton<T>(f);
}

void _factory<T extends Object>(T Function() f) {
  if (!getIt.isRegistered<T>()) getIt.registerFactory<T>(f);
}
