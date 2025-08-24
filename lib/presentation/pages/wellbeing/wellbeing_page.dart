import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/wellbeing/entities/wellbeing_entry.dart';
import '../../cubit/wellbeing/wellbeing_cubit.dart';
import '../../cubit/wellbeing/wellbeing_state.dart';

class WellbeingPage extends StatelessWidget {
  const WellbeingPage({super.key});

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h}ч ${m}м';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WellbeingCubit>();

    return BlocBuilder<WellbeingCubit, WellbeingState>(
      builder: (context, s) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Твоё самочувствие'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: cubit.nextDay,
              ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: cubit.prevDay,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(24),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _fmtDate(s.date),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // === Настроение ===
              _SectionCard(
                title: 'Настроение',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SubTitle('Настроение до матча'),
                    _MoodRow(
                      value: s.moodBefore,
                      onChanged: cubit.setMoodBefore,
                    ),
                    const SizedBox(height: 12),
                    const _SubTitle('Настроение после матча'),
                    _MoodRow(
                      value: s.moodAfter,
                      onChanged: cubit.setMoodAfter,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // === Энергия и сон ===
              _SectionCard(
                title: 'Энергия и выносливость',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SubTitle('Уровень до игры'),
                    Slider(
                      value: s.energy.toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: '${s.energy}',
                      onChanged: (v) => cubit.setEnergy(v.round()),
                    ),
                    const SizedBox(height: 8),
                    const _SubTitle('Сон'),
                    Text('Длительность сна: ${_fmtDuration(s.sleepDuration)}'),
                    Slider(
                      value: s.sleepDuration.inMinutes.toDouble(),
                      min: 0,
                      max: 12 * 60,
                      divisions: 24,
                      label: _fmtDuration(s.sleepDuration),
                      onChanged: (v) => cubit.setSleepDuration(Duration(minutes: v.round())),
                    ),
                    const SizedBox(height: 8),
                    const _SubTitle('Качество сна'),
                    _QualityChips(
                      value: s.sleepQuality,
                      onChanged: cubit.setSleepQuality,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // === Питание ===
              _SectionCard(
                title: 'Питание',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SubTitle('За сколько до матча ел?'),
                        Text(_fmtDuration(s.mealDelay)),
                      ],
                    ),
                    Slider(
                      value: s.mealDelay.inMinutes.toDouble(),
                      min: 0,
                      max: 6 * 60,
                      divisions: 24,
                      label: _fmtDuration(s.mealDelay),
                      onChanged: (v) => cubit.setMealDelay(Duration(minutes: v.round())),
                    ),
                    const SizedBox(height: 8),
                    const _SubTitle('Качество питания'),
                    _QualityChips(
                      value: s.nutritionQuality,
                      onChanged: cubit.setNutritionQuality,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // === Травмы/дискомфорт ===
              _SectionCard(
                title: 'Травмы и дискомфорт',
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Дискомфорт'),
                      value: s.discomfort,
                      onChanged: (v) => cubit.toggleDiscomfort(v),
                    ),
                    SwitchListTile(
                      title: const Text('Травма'),
                      value: s.injury,
                      onChanged: (v) => cubit.toggleInjury(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: s.saving ? null : cubit.save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(s.saving ? 'Сохраняем…' : 'Сохранить'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===== мелкие виджеты =====

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  final String text;
  const _SubTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13));
  }
}

class _MoodRow extends StatelessWidget {
  final Mood value;
  final ValueChanged<Mood> onChanged;
  const _MoodRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = Mood.values;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((m) {
        final selected = m == value;
        final emoji = switch (m) {
          Mood.veryBad => '😡',
          Mood.bad => '☹️',
          Mood.neutral => '😐',
          Mood.good => '🙂',
          Mood.veryGood => '😁',
        };
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(m),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? Colors.green.shade50 : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? Colors.green : Colors.grey.shade300,
              ),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        );
      }).toList(),
    );
  }
}

class _QualityChips extends StatelessWidget {
  final Quality3 value;
  final ValueChanged<Quality3> onChanged;
  const _QualityChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Chip _chip(Quality3 q, String label) {
      final sel = q == value;
      return Chip(
        label: Text(label),
        backgroundColor: sel ? Colors.green.shade100 : null,
        shape: StadiumBorder(
          side: BorderSide(color: sel ? Colors.green : Colors.grey.shade300),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      children: [
        InkWell(onTap: () => onChanged(Quality3.bad),    child: _chip(Quality3.bad, 'Плохо')),
        InkWell(onTap: () => onChanged(Quality3.normal), child: _chip(Quality3.normal, 'Нормально')),
        InkWell(onTap: () => onChanged(Quality3.good),   child: _chip(Quality3.good, 'Хорошо')),
      ],
    );
  }
}
