import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:footlog/core/app_theme.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_cubit.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_state.dart';

import 'shared.dart';

class InjuryCard extends StatelessWidget {
  final WellbeingState state;
  const InjuryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WellbeingCubit>();
    final rowStyle = TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: AppColors.black);

    return WellCard(
      title: 'Травмы и дискомфорт',
      child: Column(
        children: [
          CheckRow(label: 'Дискомфорт', value: state.discomfort, onChanged: cubit.toggleDiscomfort, textStyle: rowStyle),
          SizedBox(height: 8.h),
          CheckRow(label: 'Травма', value: state.injury, onChanged: cubit.toggleInjury, textStyle: rowStyle),
        ],
      ),
    );
  }
}
