import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:footlog/presentation/cubit/wellbeing/wellbeing_cubit.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_state.dart';

import 'shared.dart';

class EnergySleepCard extends StatelessWidget {
  final WellbeingState state;
  const EnergySleepCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WellbeingCubit>();

    return WellCard(
      title: 'Энергия и выносливость',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SubTitle('Уровень до игры'),
          SizedBox(height: 6.h),
          EnergySlider(value: state.energy, onChanged: cubit.setEnergy),
          SizedBox(height: 8.h),
          SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: () => cubit.setEnergy(state.energy),
              child: const Text('Выбрать'),
            ),
          ),
          SizedBox(height: 16.h),
          const SubTitle('Качество сна'),
          SizedBox(height: 8.h),
          QualitySegmented(value: state.sleepQuality, onChanged: cubit.setSleepQuality),
        ],
      ),
    );
  }
}
