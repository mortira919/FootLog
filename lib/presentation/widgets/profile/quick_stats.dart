import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_theme.dart';
import '../../../domain/home/enums/period.dart';
import '../../../domain/home/entities/quick_stats.dart' as M;

class QuickStats extends StatelessWidget {
  final Period period;
  final M.QuickStats? stats;
  final ValueChanged<Period> onChange;

  const QuickStats({
    super.key,
    required this.period,
    required this.stats,
    required this.onChange,
  });

  // цвета из макета
  static const _capsuleBg = Color(0xFFE8EBE9);
  static const _activeBorder = Color(0x0A000000);
  static const _dividerGray = Color(0x0A000000);

  static Color _labelColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0x99EBEBF5) : const Color(0x993C3C43);
  }

  Widget _metric(BuildContext context, String title, int? value) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '${value ?? 0}',
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
          height: 1,
        ),
      ),
      SizedBox(height: 8.h),
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          inherit: false,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          height: 22 / 17,
          color: _labelColor(context),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Быстрая статистика',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          _SegmentSwitcher(current: period, onChange: onChange),

          SizedBox(height: 16.h),

          // 1-й ряд (3 колонки)
          Row(
            children: [
              Expanded(child: _metric(context, 'Матчей', stats?.matches)),
              Expanded(child: _metric(context, 'Голов', stats?.goals)),
              Expanded(child: _metric(context, 'Ассистов', stats?.assists)),
            ],
          ),
          SizedBox(height: 12.h),

          // 2-й ряд (с отступом посередине — как в фигме)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // центры на 1/3 и 2/3
            children: [
              _metric(context, 'Перехватов', stats?.interceptions),
              _metric(context, 'Отборов',    stats?.tackles),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentSwitcher extends StatelessWidget {
  final Period current;
  final ValueChanged<Period> onChange;
  const _SegmentSwitcher({required this.current, required this.onChange});

  static const _capsuleBg = QuickStats._capsuleBg;
  static const _activeBorder = QuickStats._activeBorder;
  static const _dividerGray = QuickStats._dividerGray;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28.h,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: _capsuleBg,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        children: [
          _seg('1 месяц', current == Period.m1, () => onChange(Period.m1)),
          _divider(),
          _seg('6 месяцев', current == Period.m6, () => onChange(Period.m6)),
          _divider(),
          _seg('12 месяцев', current == Period.m12, () => onChange(Period.m12)),
        ],
      ),
    );
  }

  Widget _seg(String label, bool selected, VoidCallback onTap) {
    final child = Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(
          color: selected ? _activeBorder : Colors.transparent,
          width: 0.5,
        ),
        boxShadow: selected
            ? const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
        ]
            : null,
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.black),
      ),
    );

    // Expanded => ровно 3 одинаковых сегмента
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(7.r),
        onTap: onTap,
        child: child,
      ),
    );
  }

  Widget _divider() => SizedBox(
    width: 1.w,
    child: Center(
      child: Container(
        width: 1,
        height: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 4.h), // чтобы не упирался в скругления
        color: _dividerGray,
      ),
    ),
  );
}
