import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:footlog/core/app_theme.dart';

class MatchPersonalStatsCard extends StatelessWidget {
  final int goals;
  final int assists;
  final int interceptions;
  final int tackles;
  final int saves;

  final ValueChanged<int> onGoals;
  final ValueChanged<int> onAssists;
  final ValueChanged<int> onInterceptions;
  final ValueChanged<int> onTackles;
  final ValueChanged<int> onSaves;

  const MatchPersonalStatsCard({
    super.key,
    required this.goals,
    required this.assists,
    required this.interceptions,
    required this.tackles,
    required this.saves,
    required this.onGoals,
    required this.onAssists,
    required this.onInterceptions,
    required this.onTackles,
    required this.onSaves,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Счёт матча',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textGray,
            ),
          ),
        ),
        SizedBox(height: 8.h),

        _StatRow(
          title: 'Забито голов',
          value: goals,
          onChanged: (v) => onGoals(v.clamp(0, 999)),
        ),
        _StatRow(
          title: 'Отдано ассистов',
          value: assists,
          onChanged: (v) => onAssists(v.clamp(0, 999)),
        ),
        _StatRow(
          title: 'Сделано перехватов',
          value: interceptions,
          onChanged: (v) => onInterceptions(v.clamp(0, 999)),
        ),
        _StatRow(
          title: 'Сделано отборов',
          value: tackles,
          onChanged: (v) => onTackles(v.clamp(0, 999)),
        ),
        _StatRow(
          title: 'Сделано сэйвов',
          value: saves,
          onChanged: (v) => onSaves(v.clamp(0, 999)),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  const _StatRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          _Stepper(
            value: value,
            onMinus: () => onChanged((value - 1).clamp(0, 999)),
            onPlus:  () => onChanged((value + 1).clamp(0, 999)),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _Stepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final radius = 8.r;
    return Container(
      width: 96.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        children: [
          _btn(Icons.remove, onMinus, left: true),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          _btn(Icons.add, onPlus, left: false),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, {required bool left}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(left ? 8.r : 0),
        right: Radius.circular(left ? 0 : 8.r),
      ),
      child: SizedBox(
        width: 32.w,
        height: 32.h,
        child: Icon(icon, size: 18.sp, color: AppColors.black),
      ),
    );
  }
}
