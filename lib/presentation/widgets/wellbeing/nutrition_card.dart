import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:footlog/presentation/cubit/wellbeing/wellbeing_cubit.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_state.dart';

import 'package:footlog/presentation/widgets/wellbeing/shared.dart';
import 'package:footlog/presentation/widgets/wellbeing/cupertino_wheels.dart';

class NutritionCard extends StatelessWidget {
  final WellbeingState state;
  const NutritionCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WellbeingCubit>();

    return WellCard(
      title: 'Питание',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SubTitle('За сколько до матча ел?'),
          SizedBox(height: 8.h),

          // Центрируем пикер по карточке и задаём ширину по макету
          Center(
            child: SizedBox(
              width: 329.w,
              child: MealDelayPicker(
                initialMinutes: state.mealDelay.inMinutes,
                onConfirm: (total) =>
                    cubit.setMealDelay(Duration(minutes: total)),
              ),
            ),
          ),

          SizedBox(height: 16.h),
          const SubTitle('Качество питания'),
          SizedBox(height: 8.h),
          QualitySegmented(
            value: state.nutritionQuality,
            onChanged: cubit.setNutritionQuality,
          ),
        ],
      ),
    );
  }
}
