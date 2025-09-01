import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:footlog/core/app_theme.dart';
import 'package:footlog/presentation/cubit/stats/stats_cubit.dart';
import 'package:footlog/presentation/cubit/stats/stats_state.dart';
import 'package:footlog/presentation/widgets/stats/stats_bar_card.dart';

class StatsPage extends StatefulWidget {
  final StatsCubit cubit;
  const StatsPage({super.key, required this.cubit});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    widget.cubit.load(months: 6);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsCubit, StatsState>(
      bloc: widget.cubit,
      builder: (context, s) {
        if (s.loading && s.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (s.error != null && s.data == null) {
          return Center(child: Text('Ошибка: ${s.error}'));
        }

        final data = s.data!;
        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Center(
              child: Text(
                'Статистика',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(height: 10.h),

            StatsBarCard(
              title: 'Количество голов',
              values: data.goals,
              labels: data.labels,
              centerTitle: true,
              showChevron: true,
              height: 180,
            ),
            SizedBox(height: 12.h),

            StatsBarCard(
              title: 'Количество матчей',
              values: data.matches,
              labels: data.labels,
              centerTitle: true,
              showChevron: true,
            ),
            SizedBox(height: 12.h),

            StatsBarCard(
              title: 'Количество ассистов',
              values: data.assists,
              labels: data.labels,
              centerTitle: true,
              showChevron: true,
            ),
            SizedBox(height: 12.h),

            StatsBarCard(
              title: 'Количество перехватов',
              values: data.interceptions,
              labels: data.labels,
              centerTitle: true,
              showChevron: true,
            ),
            SizedBox(height: 12.h),

            StatsBarCard(
              title: 'Количество отборов',
              values: data.tackles,
              labels: data.labels,
              centerTitle: true,
              showChevron: true,
            ),
            SizedBox(height: 12.h),

            // 👇 НОВАЯ КАРТА
            StatsBarCard(
              title: 'Количество сейвов',
              values: data.saves,
              labels: data.labels,
              centerTitle: true,
              showChevron: true,
            ),

            SizedBox(height: 24.h),
          ],
        );
      },
    );
  }
}
