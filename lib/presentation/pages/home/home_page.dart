// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:footlog/presentation/cubit/home/home_cubit.dart';
import 'package:footlog/presentation/cubit/home/home_state.dart';

// ✅ импорт нашей шторки
// ✅ чтобы взять rootNavigatorKey
import 'package:footlog/presentation/navigation/app_router.dart';

import '../../widgets/bottom_nav.dart';
import '../../widgets/profile/profile_card.dart';
import '../../widgets/profile/quick_stats.dart';
import '../../widgets/profile/recent_matches.dart';
import '../../widgets/profile/show_edit_profile_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  void _onTabChanged(int i) {
    setState(() => _tabIndex = i);
    // TODO: добавить переходы на другие экраны при готовности
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (prev, curr) => prev.error != curr.error && curr.error != null,
      listener: (context, s) {
        if (s.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.error!), behavior: SnackBarBehavior.floating),
          );
        }
      },
      builder: (context, s) {
        if (s.loading && s.profile == null) {
          return const Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                children: [
                  ProfileCard(
                    profile: s.profile,
                    onEdit: () async {
                      final profile = s.profile;
                      if (profile == null) return;

                      // показываем шторку через root-navigator (чтобы пропорции были как в макете)
                      final updated = await showEditProfileBottomSheet(
                        context: rootNavigatorKey.currentContext ?? context,
                        initial: profile,
                      );


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
            ),
          ),
          bottomSheet: s.loading && s.profile != null
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
