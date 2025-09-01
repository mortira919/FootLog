// lib/presentation/widgets/wellbeing/shared.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:footlog/core/app_theme.dart';
import 'package:footlog/domain/wellbeing/entities/wellbeing_entry.dart';

/// ===== Каркас карточки + подзаголовок

class WellCard extends StatelessWidget {
  final String title;
  final Widget child;
  const WellCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}

class SubTitle extends StatelessWidget {
  final String text;
  const SubTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }
}

/// ===== Настроение: сегменты

class MoodRow extends StatelessWidget {
  final Mood selected;
  final bool readonly;
  final ValueChanged<Mood>? onChanged;
  const MoodRow({
    super.key,
    required this.selected,
    this.readonly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const items = [Mood.bad, Mood.neutral, Mood.good, Mood.veryGood];
    const segBg = Color(0xFFF2F2F7);
    const sepCol = Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(color: segBg, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(
              child: _MoodSegment(
                mood: items[i],
                selected: items[i] == selected,
                readonly: readonly,
                onTap: onChanged,
              ),
            ),
            if (i != items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: 1,
                  height: 22,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: sepCol),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MoodSegment extends StatelessWidget {
  final Mood mood;
  final bool selected;
  final bool readonly;
  final ValueChanged<Mood>? onTap;
  const _MoodSegment({
    required this.mood,
    required this.selected,
    required this.readonly,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readonly ? null : () => onTap?.call(mood),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))]
              : const [],
          border: selected ? Border.all(color: Color(0xFFE5E7EB)) : null,
        ),
        child: Text(moodEmoji(mood), style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}

String moodEmoji(Mood m) {
  switch (m) {
    case Mood.bad:
      return '😕';
    case Mood.neutral:
      return '🙂';
    case Mood.good:
      return '😊';
    case Mood.veryGood:
      return '😁';
  }
}

/// ===== Слайдер энергии (PNG-иконки слева/справа, белый пин)

class EnergySlider extends StatelessWidget {
  final int value; // 0..10
  final ValueChanged<int> onChanged;
  const EnergySlider({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = SliderTheme.of(context).copyWith(
      trackHeight: 4,
      activeTrackColor: const Color(0xFFE9EDF2),
      inactiveTrackColor: const Color(0xFFE9EDF2),
      trackShape: const RoundedRectSliderTrackShape(),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
      thumbColor: AppColors.white,
      thumbShape: const _ShadowThumbShape(radius: 12),
    );

    return Row(
      children: [
        Image.asset('assets/icons/bad.png', width: 28.w, height: 28.w, fit: BoxFit.contain),
        Expanded(
          child: SliderTheme(
            data: theme,
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
        Image.asset('assets/icons/good.png', width: 28.w, height: 28.w, fit: BoxFit.contain),
      ],
    );
  }
}

class _ShadowThumbShape extends SliderComponentShape {
  final double radius;
  const _ShadowThumbShape({this.radius = 12});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(radius);

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required Size sizeWithOverflow,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double textScaleFactor,
        required double value,
      }) {
    final canvas = context.canvas;
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(path, const Color(0x33000000), 4, true);
    final fill = Paint()..color = sliderTheme.thumbColor ?? Colors.white;
    canvas.drawCircle(center, radius, fill);
    final stroke = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, stroke);
  }
}

/// ===== Общий «трек» 329×28 и сегменты качества (Хорошо | Средне | Плохо)

class _TrackWidth extends StatelessWidget {
  final Widget child;
  const _TrackWidth({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 329.w),
        child: child,
      ),
    );
  }
}

class _SegItem<T> {
  final T value;
  final String label;
  const _SegItem(this.value, this.label);
}

class TrackSegmented<T> extends StatelessWidget {
  final T value;
  final ValueChanged<T> onChanged;
  final List<_SegItem<T>> items;
  const TrackSegmented({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final index = items.indexWhere((e) => e.value == value).clamp(0, items.length - 1);
    final trackH = 28.h;
    final pillH = 24.h;
    final trackR = 7.r;  // как в макете
    final pillR = 6.r;

    final textSel = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: AppColors.black,
    );
    final textDef = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      height: 1.1,
      color: AppColors.black.withOpacity(0.55),
    );

    return _TrackWidth(
      child: SizedBox(
        height: trackH,
        child: LayoutBuilder(
          builder: (ctx, c) {
            final w = c.maxWidth;
            final segW = w / items.length;

            return Stack(
              children: [
                // трек + разделители
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F5),
                    borderRadius: BorderRadius.circular(trackR),
                    border: Border.all(color: const Color(0xFFE0E2E6)),
                  ),
                  child: Row(
                    children: List.generate(items.length * 2 - 1, (i) {
                      if (i.isEven) return const Expanded(child: SizedBox());
                      return Container(
                        width: 1,
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        color: const Color(0xFFE0E2E6),
                      );
                    }),
                  ),
                ),
                // активная «пилюля»
                Positioned(
                  top: (trackH - pillH) / 2,
                  left: index * segW + 4.w,
                  width: segW - 8.w,
                  height: pillH,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(pillR),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ),
                // кликабельные сегменты с подписями
                Row(
                  children: [
                    for (int i = 0; i < items.length; i++)
                      SizedBox(
                        width: segW,
                        height: trackH,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(trackR),
                          onTap: () => onChanged(items[i].value),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(items[i].label, style: i == index ? textSel : textDef),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class QualitySegmented extends StatelessWidget {
  final Quality3 value;
  final ValueChanged<Quality3> onChanged;
  const QualitySegmented({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TrackSegmented<Quality3>(
      value: value,
      onChanged: onChanged,
      items: const [
        _SegItem(Quality3.good, 'Хорошо'),
        _SegItem(Quality3.normal, 'Средне'),
        _SegItem(Quality3.bad, 'Плохо'),
      ],
    );
  }
}

/// ===== чек-ряд для «Травмы и дискомфорт»

class CheckRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final TextStyle? textStyle;
  const CheckRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        child: Row(
          children: [
            Expanded(child: Text(label, style: textStyle)),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: value ? const Color(0xFF22C55E) : Colors.transparent,
                border: Border.all(
                  color: value ? const Color(0xFF22C55E) : const Color(0xFFE0E2E6),
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== форматтер длительности

String formatDurationRu(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h == 0) return '$m мин';
  if (m == 0) return '$h ч';
  return '$h ч $m мин';
}
