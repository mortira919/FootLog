// lib/presentation/widgets/profile/profile_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_theme.dart';
import '../../../domain/home/entities/player_profile.dart';
import '../../../domain/home/enums/positions.dart';

class ProfileCard extends StatelessWidget {
  final PlayerProfile? profile;
  final VoidCallback onEdit;
  const ProfileCard({super.key, required this.profile, required this.onEdit});

  String _label(Position p) => switch (p) {
    Position.GK => 'Вратарь',
    Position.CB => 'Центральный защитник',
    Position.LB => 'Левый защитник',
    Position.RB => 'Правый защитник',
    Position.CDM => 'Опорный полузащитник',
    Position.CM => 'Центральный полузащитник',
    Position.CAM => 'Атакующий полузащитник',
    Position.RM => 'Правый полузащитник',
    Position.LM => 'Левый полузащитник',
    Position.RW => 'Правый вингер',
    Position.LW => 'Левый вингер',
    Position.ST => 'Страйкер',
  };

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return AppCard(
      padding: EdgeInsets.all(16.w), // Figma: 16
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: p == null
                ? const SizedBox.shrink()
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Имя: 34 Bold
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    height: 1.0, // плотная как в макете
                  ),
                ),
                SizedBox(height: 6.h),
                // Позиция: 17 Semibold
                Text(
                  'Позиция: ${_label(p.primaryPosition)}',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGray,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.w), // увеличивает кликабельную зону
              child: Image.asset(
                'assets/icons/change_but.png',
                width: 22.w,
                height: 22.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
