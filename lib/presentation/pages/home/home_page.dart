// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:footlog/di/di.dart';

// ---- Stats (экран «Статистика»)
import 'package:footlog/domain/stats/repositories/stats_repository.dart';
import 'package:footlog/presentation/cubit/stats/stats_cubit.dart';
import 'package:footlog/presentation/pages/stats/stats_page.dart';

// ---- Wellbeing (экран «Состояние»)
import 'package:footlog/domain/wellbeing/repositories/wellbeing_repository.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_cubit.dart';
import 'package:footlog/presentation/pages/wellbeing/wellbeing_page.dart';

// ---- Home
import 'package:footlog/presentation/cubit/home/home_cubit.dart';
import 'package:footlog/presentation/cubit/home/home_state.dart';
import 'package:footlog/presentation/navigation/app_router.dart';
import 'package:footlog/presentation/navigation/route_names.dart';

import '../../widgets/bottom_nav.dart';
import '../../widgets/profile/edit_profile_sheet.dart';
import '../../widgets/profile/profile_card.dart';
import '../../widgets/profile/quick_stats.dart';
import '../../widgets/profile/recent_matches.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  late final StatsCubit _statsCubit;
  late final WellbeingCubit _wbCubit;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';

    // Экран «Статистика»
    _statsCubit = StatsCubit(getIt<StatsRepository>(), uid)..load(months: 6);

    // Экран «Состояние» — один инстанс на всё время жизни HomePage
    _wbCubit = WellbeingCubit(
      uid: uid,
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
    // Центральная кнопка «Добавить матч»
    if (i == 2) {
      final saved = await context.push<bool>(RouteNames.matchesAdd);
      if (!mounted) return; // сначала проверка
      if (saved == true) {
        context.read<HomeCubit>().load();
      }
      return; // не меняем выбранный таб
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

        // 1 — Экран «Статистика»
          1 => StatsPage(cubit: _statsCubit),

        // 3 — Экран «Состояние»
          3 => BlocProvider.value(
            value: _wbCubit,
            child: const WellbeingPage(),
          ),

        // остальные — пока пусто
          _ => const SizedBox.shrink(),
        };

        return Scaffold(
          body: SafeArea(child: content),
          bottomSheet: (s.loading && s.profile != null)
              ? const LinearProgressIndicator(minHeight: 2)
              : null,
          bottomNavigationBar: HomeBottomNav(
            index: _tabIndex,
            onChanged: _onTabChanged,
          ),
        );
      },
    );
  }
}
