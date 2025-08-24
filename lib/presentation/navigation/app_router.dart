// lib/presentation/navigation/app_router.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:footlog/presentation/navigation/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:footlog/presentation/pages/matches/add_match_page.dart';
import 'package:footlog/presentation/cubit/matches/add_match/add_match_cubit.dart';
import 'package:footlog/domain/matches/usecases/add_match_usecase.dart';

// pages
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/reset_password_page.dart';
import '../pages/home/home_page.dart';

// cubit + usecases для Home
import 'package:footlog/presentation/cubit/home/home_cubit.dart';
import 'package:footlog/domain/home/usecases/get_player_profile_usecase.dart';
import 'package:footlog/domain/home/usecases/save_player_profile_usecase.dart';
import 'package:footlog/domain/home/usecases/get_quick_stats_usecase.dart';
import 'package:footlog/domain/home/usecases/get_recent_matches_usecase.dart';

class Routes {
  static const register = '/register';
  static const login    = '/login';
  static const forgot   = '/forgot';
  static const home     = '/home';
}

/// root/shell ключи навигаторов
final GlobalKey<NavigatorState> rootNavigatorKey  = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(); // на будущее (табы)

/// Helper, чтобы GoRouter обновлялся при изменении auth state
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _auth = GetIt.I<FirebaseAuth>();
final _refresh = GoRouterRefreshStream(_auth.authStateChanges());

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,                 // ✅ корневой навигатор
  initialLocation: Routes.login,
  refreshListenable: _refresh,                    // ✅ один инстанс refresher
  redirect: (context, state) {
    final loggedIn = _auth.currentUser != null;
    final loc = state.matchedLocation;
    final goingToAuth =
        loc == Routes.login || loc == Routes.register || loc == Routes.forgot;

    if (!loggedIn && !goingToAuth) return Routes.login;
    if (loggedIn && goingToAuth)   return Routes.home;
    return null;
  },
  routes: [
    GoRoute(path: Routes.register, builder: (_, __) => const RegisterPage()),
    GoRoute(path: Routes.login,    builder: (_, __) => const LoginPage()),
    GoRoute(path: Routes.forgot,   builder: (_, __) => const ResetPasswordPage()),
    GoRoute(
      path: Routes.home,
      builder: (context, __) {
        final uid = _auth.currentUser?.uid ?? 'mock-uid';
        return BlocProvider(
          create: (_) => HomeCubit(
            uid: uid,
            getProfile: GetIt.I<GetPlayerProfileUseCase>(),
            saveProfile: GetIt.I<SavePlayerProfileUseCase>(),
            getStats:   GetIt.I<GetQuickStatsUseCase>(),
            getRecent:  GetIt.I<GetRecentMatchesUseCase>(),
          )..load(),
          child: const HomePage(),
        );
      },
    ),
    GoRoute(
      path: RouteNames.matchesAdd,
      builder: (context, __) {
        final uid = _auth.currentUser?.uid ?? 'mock-uid';
        return BlocProvider(
          create: (_) => AddMatchCubit(uid: uid, addMatch: GetIt.I<AddMatchUseCase>()),
          child: const AddMatchPage(),
        );
      },
    ),
  ],
);

