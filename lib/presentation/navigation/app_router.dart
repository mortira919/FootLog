import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

// matches
import 'package:footlog/presentation/pages/matches/add_match_page.dart';
import 'package:footlog/presentation/cubit/matches/add_match/add_match_cubit.dart';
import 'package:footlog/domain/matches/usecases/add_match_usecase.dart';

// auth + home
import 'package:footlog/presentation/navigation/route_names.dart';
import 'package:footlog/presentation/pages/auth/login_page.dart';
import 'package:footlog/presentation/pages/auth/register_page.dart';
import 'package:footlog/presentation/pages/auth/reset_password_page.dart';
import 'package:footlog/presentation/pages/home/home_page.dart';
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

final GlobalKey<NavigatorState> rootNavigatorKey  = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();


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


GoRouter createAppRouter() {
  final auth = GetIt.I<FirebaseAuth>();
  final refresh = GoRouterRefreshStream(auth.authStateChanges());

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.login,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final loc = state.matchedLocation;
      final goingToAuth = loc == Routes.login || loc == Routes.register || loc == Routes.forgot;

      if (!loggedIn && !goingToAuth) return Routes.login;
      if (loggedIn && goingToAuth)   return Routes.home;
      return null;
    },
    errorBuilder: (ctx, st) => Scaffold(
      body: Center(child: Text('Routing error: ${st.error}', textAlign: TextAlign.center)),
    ),
    routes: [
      GoRoute(path: Routes.register, builder: (_, __) => const RegisterPage()),
      GoRoute(path: Routes.login,    builder: (_, __) => const LoginPage()),
      GoRoute(path: Routes.forgot,   builder: (_, __) => const ResetPasswordPage()),

      GoRoute(
        path: Routes.home,
        builder: (context, __) {
          final uid = auth.currentUser?.uid ?? 'mock-uid';
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
          final uid = auth.currentUser?.uid ?? 'mock-uid';
          return BlocProvider(
            create: (_) => AddMatchCubit(uid: uid, addMatch: GetIt.I<AddMatchUseCase>()),
            child: const AddMatchPage(),
          );
        },
      ),
    ],
  );
}
