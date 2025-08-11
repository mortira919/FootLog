// presentation/widgets/profile/recent_matches.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_theme.dart';
import '../../../domain/home/entities/recent_match.dart';
import '../../../domain/home/enums/outcome.dart';

class RecentMatchesCard extends StatelessWidget {
  final List<RecentMatch> list;
  final bool showTitle;

  const RecentMatchesCard({
    super.key,
    required this.list,
    this.showTitle = true,
  });

  String _date(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.$yy';
  }

  String _status(Outcome o) => switch (o) {
    Outcome.win => 'Победа',
    Outcome.loss => 'Поражение',
    Outcome.draw => 'Ничья',
  };

  Color _statusColor(Outcome o) => switch (o) {
    Outcome.win => AppStatusColors.success,
    Outcome.loss => AppStatusColors.danger,
    Outcome.draw => AppColors.textGray,
  };

  (int, int) _scorePair(String? score) {
    if (score != null) {
      final parts = score.split(':');
      if (parts.length == 2) {
        final a = int.tryParse(parts[0].trim());
        final b = int.tryParse(parts[1].trim());
        if (a != null && b != null) return (a, b);
      }
    }
    return (4, 3);
  }

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showTitle) ...[
            Center(
              child: Text(
                'Последние матчи',
                // Явный стиль — чтобы не «съедался» темой
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          ...list.map((m) => _item(context, m)).toList(),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, RecentMatch m) {
    final (home, away) = _scorePair(m.score);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Дата — узкая колонка
          SizedBox(
            width: 66.w,
            child: Text(
              _date(m.date),
              style: TextStyle(fontSize: 12.sp, color: AppColors.textGray),
            ),
          ),

          // Блок из двух строк
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _teamLine('Название', home, dim: false),
                SizedBox(height: 4.h),
                _teamLine('Название', away, dim: true),
              ],
            ),
          ),

          // Статус — фиксированная ширина
          SizedBox(
            width: 92.w,
            child: Center(
              child: Text(
                _status(m.outcome),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _statusColor(m.outcome),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamLine(String title, int score, {required bool dim}) {
    final color = dim ? const Color(0x663C3C43) : AppColors.black;
    final textStyle = TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.0,
    );

    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: const BoxDecoration(
            color: Color(0xFFBDBDBD),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
        SizedBox(width: 6.w),
        SizedBox(
          width: 20.w,
          child: Text(
            '$score',
            textAlign: TextAlign.right,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
