import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

import 'package:footlog/presentation/cubit/wellbeing/wellbeing_cubit.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_state.dart';

// карточки
import 'package:footlog/presentation/widgets/wellbeing/mood_card.dart';
import 'package:footlog/presentation/widgets/wellbeing/energy_sleep_card.dart';
import 'package:footlog/presentation/widgets/wellbeing/nutrition_card.dart';
import 'package:footlog/presentation/widgets/wellbeing/injury_card.dart';

class WellbeingPage extends StatelessWidget {
  const WellbeingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WellbeingCubit>();

    return BlocBuilder<WellbeingCubit, WellbeingState>(
      builder: (context, s) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Твоё самочувствие'),
            leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: cubit.prevDay),
            actions: [IconButton(icon: const Icon(Icons.chevron_right), onPressed: cubit.nextDay)],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(28.h),
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(_fmtDate(s.date),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              MoodCard(state: s),
              SizedBox(height: 12.h),
              EnergySleepCard(state: s),
              SizedBox(height: 12.h),
// стало
              NutritionCard(state: s),
              SizedBox(height: 12.h),
              InjuryCard(state: s),
              SizedBox(height: 20.h),
              _SaveButton(saving: s.saving, onPressed: cubit.save),
              if (s.error != null) ...[
                SizedBox(height: 12.h),
                Text('Ошибка: ${s.error}',
                    style: TextStyle(color: Colors.red, fontSize: 12.sp)),
              ],
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onPressed;
  const _SaveButton({required this.saving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saving ? null : onPressed,
        child: saving
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Сохранить'),
      ),
    );
  }
}

String _fmtDate(DateTime d) => intl.DateFormat('dd.MM.yy').format(d);
