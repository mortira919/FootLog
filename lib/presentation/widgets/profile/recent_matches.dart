import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_theme.dart';
// важно: импортируем модель из domain
import '../../../domain/home/entities/recent_match.dart' as model;
import '../../../domain/home/enums/outcome.dart';

class RecentMatchesCard extends StatelessWidget {
  final List<model.RecentMatch> list;
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
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          if (list.isEmpty)
            Center(
              child: Text(
                'Пока нет матчей',
                style: TextStyle(fontSize: 14.sp, color: AppColors.textGray),
              ),
            )
          else
            ...list.map((m) => _item(context, m)).toList(),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, model.RecentMatch m) {
    final yourName = m.yourTeam.isEmpty ? 'Ваша команда' : m.yourTeam;
    final oppName = m.opponentTeam.isEmpty ? 'Соперник' : m.opponentTeam;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 66.w,
            child: Text(
              _date(m.date),
              style: TextStyle(fontSize: 12.sp, color: AppColors.textGray),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ТЕПЕРЬ с логотипом вашей команды
                _teamLine(
                  title: yourName,
                  score: m.yourGoals,
                  dim: false,
                  logoUrl: m.yourLogoUrl, // 👈 добавили
                ),
                SizedBox(height: 4.h),
                _teamLine(
                  title: oppName,
                  score: m.opponentGoals,
                  dim: true,
                  logoUrl: m.opponentLogoUrl,
                ),
              ],
            ),
          ),
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

  Widget _teamLine({
    required String title,
    required int score,
    required bool dim,
    String? logoUrl,
  }) {
    final color = dim ? const Color(0x663C3C43) : AppColors.black;
    final textStyle = TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.0,
    );

    return Row(
      children: [
        _avatar(logoUrl),
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
          child: Text('$score', textAlign: TextAlign.right, style: textStyle),
        ),
      ],
    );
  }

  Widget _avatar(String? url) {
    final s = 14.w;
    if (url == null || url.isEmpty) {
      return Container(
        width: s,
        height: s,
        decoration: const BoxDecoration(
          color: Color(0xFFBDBDBD),
          shape: BoxShape.circle,
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: s,
        height: s,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: s,
          height: s,
          decoration: const BoxDecoration(
            color: Color(0xFFBDBDBD),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
