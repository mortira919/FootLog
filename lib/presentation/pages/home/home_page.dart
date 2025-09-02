import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:footlog/di/di.dart';

// ---- Stats
import 'package:footlog/domain/stats/repositories/stats_repository.dart';
import 'package:footlog/presentation/cubit/stats/stats_cubit.dart';
import 'package:footlog/presentation/pages/stats/stats_page.dart';

// ---- Wellbeing
import 'package:footlog/domain/wellbeing/repositories/wellbeing_repository.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_cubit.dart';
import 'package:footlog/presentation/pages/wellbeing/wellbeing_page.dart';

// ---- Home
import 'package:footlog/presentation/cubit/home/home_cubit.dart';
import 'package:footlog/presentation/cubit/home/home_state.dart';
import 'package:footlog/presentation/navigation/app_router.dart';
import 'package:footlog/presentation/navigation/route_names.dart';

// ---- Профиль
import 'package:footlog/presentation/cubit/profile/profile_cubit.dart';
import 'package:footlog/presentation/pages/profile/profile_page.dart';

import '../../widgets/bottom_nav.dart';
import '../../widgets/profile/edit_profile_sheet.dart';
import '../../widgets/profile/profile_card.dart';
import '../../widgets/profile/quick_stats.dart';
import '../../widgets/profile/recent_matches.dart';

// обёртка со встроенным CoachChat FAB
import '../../widgets/page_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  late final String _uid;
  late final StatsCubit _statsCubit;
  late final WellbeingCubit _wbCubit;

  @override
  void initState() {
    super.initState();

    _uid = FirebaseAuth.instance.currentUser?.uid ?? 'mock-uid';

    _statsCubit = StatsCubit(getIt<StatsRepository>(), _uid)..load(months: 6);

    _wbCubit = WellbeingCubit(
      uid: _uid,
      repo: getIt<WellbeingRepository>(),
    )..load(DateTime.now());
  }

  @override
  void dispose() {
    _statsCubit.close();
    _wbCubit.close();
    super.dispose();
  }

  Future<void> _onTabChanged(int i) async {
    // центральная кнопка "Добавить матч"
    if (i == 2) {
      final saved = await context.push<bool>(RouteNames.matchesAdd);
      if (!mounted) return;
      if (saved == true) context.read<HomeCubit>().load();
      return;
    }
    setState(() => _tabIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (prev, curr) => prev.error != curr.error && curr.error != null,
      listener: (context, s) {
        final err = s.error;
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
          );
        }
      },
      builder: (context, s) {
        if (s.loading && s.profile == null) {
          return const Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        final Widget content = switch (_tabIndex) {
        // 0 — Главная
          0 => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            children: [
              ProfileCard(
                profile: s.profile,
                onEdit: () async {
                  final profile = s.profile;
                  if (profile == null) return;

                  final updated = await showEditProfileBottomSheet(
                    rootNavigatorKey.currentContext ?? context,
                    initial: profile,
                  );
                  if (!mounted) return;
                  if (updated != null) {
                    await context.read<HomeCubit>().saveProfile(updated);
                  }
                },
              ),
              SizedBox(height: 12.h),
              QuickStats(
                period: s.period,
                stats: s.stats,
                onChange: (p) => context.read<HomeCubit>().changePeriod(p),
              ),
              SizedBox(height: 12.h),
              RecentMatchesCard(list: s.recent),
              SizedBox(height: 24.h),
            ],
          ),

        // 1 — Статистика
          1 => StatsPage(cubit: _statsCubit),

        // 3 — Состояние
          3 => BlocProvider.value(value: _wbCubit, child: const WellbeingPage()),

        // 4 — Профиль
          4 => BlocProvider(
            create: (_) => getIt<ProfileCubit>(param1: _uid)..load(),
            child: const ProfilePage(),
          ),

          _ => const SizedBox.shrink(),
        };

        // Обёртка с FAB тренера
        return PageScaffold(
          body: SafeArea(child: content),
          bottomNavigationBar: HomeBottomNav(
            index: _tabIndex,
            onChanged: _onTabChanged,
          ),
          showCoachFab: const {0, 1, 3, 4}.contains(_tabIndex),

          // topProgress: (s.loading && s.profile != null), // если нужен тонкий индикатор сверху
        );
      },
    );
  }
}
