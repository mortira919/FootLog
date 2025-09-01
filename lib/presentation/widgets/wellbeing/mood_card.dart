import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:footlog/core/app_theme.dart';
import 'package:footlog/domain/wellbeing/entities/wellbeing_entry.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_cubit.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_state.dart';

import 'shared.dart';

class MoodCard extends StatefulWidget {
  final WellbeingState state;
  const MoodCard({super.key, required this.state});

  @override
  State<MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<MoodCard> {
  late Mood _before = widget.state.moodBefore;
  late Mood _after  = widget.state.moodAfter;

  @override
  void didUpdateWidget(covariant MoodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.moodBefore != widget.state.moodBefore) _before = widget.state.moodBefore;
    if (oldWidget.state.moodAfter  != widget.state.moodAfter ) _after  = widget.state.moodAfter;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WellbeingCubit>();

    return WellCard(
      title: 'Настроение',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SubTitle('Настроение до матча'),
          SizedBox(height: 6.h),
          MoodRow(selected: _before, onChanged: (m) => setState(() => _before = m)),
          SizedBox(height: 12.h),
          SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: () => cubit.setMoodBefore(_before),
              child: const Text('Выбрать'),
            ),
          ),
          SizedBox(height: 16.h),
          const SubTitle('Настроение после матча'),
          SizedBox(height: 6.h),
          MoodRow(selected: _after, onChanged: (m) => setState(() => _after = m)),
          SizedBox(height: 12.h),
          SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: () => cubit.setMoodAfter(_after),
              child: const Text('Выбрать'),
            ),
          ),
        ],
      ),
    );
  }
}
