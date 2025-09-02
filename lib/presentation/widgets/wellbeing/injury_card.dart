import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:footlog/core/app_theme.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_cubit.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_state.dart';

import 'shared.dart';

class InjuryCard extends StatelessWidget {
  final WellbeingState state;

  /// Колбэк для навигации в чат
  final VoidCallback? onAskCoach;

  const InjuryCard({
    super.key,
    required this.state,
    this.onAskCoach,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WellbeingCubit>();
    final titleStyle =
    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black);
    final rowStyle =
    TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black);

    return WellCard(
      title: 'Травмы и дискомфорт',
      titleStyle: titleStyle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckRow(
            label: 'Дискомфорт',
            value: state.discomfort,
            onChanged: cubit.toggleDiscomfort,
            textStyle: rowStyle,
          ),
          SizedBox(height: 8.h),
          CheckRow(
            label: 'Травма',
            value: state.injury,
            onChanged: cubit.toggleInjury,
            textStyle: rowStyle,
          ),
          SizedBox(height: 12.h),

          // CTA: обсудить с ассистентом
          InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: onAskCoach,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Хотите обсудить это с ассистентом?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20.sp, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
