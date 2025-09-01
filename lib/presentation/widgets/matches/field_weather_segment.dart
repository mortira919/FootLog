// lib/presentation/widgets/wellbeing/field_weather_segment.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:footlog/domain/matches/enums/field_type.dart';
import 'package:footlog/domain/matches/enums/weather.dart';
import '../../../core/app_theme.dart';

class FieldWeatherSegment extends StatelessWidget {
  final FieldType fieldType;
  final Weather weather;
  final ValueChanged<FieldType> onFieldChanged;
  final ValueChanged<Weather> onWeatherChanged;

  const FieldWeatherSegment({
    super.key,
    required this.fieldType,
    required this.weather,
    required this.onFieldChanged,
    required this.onWeatherChanged,
  });

  @override
  Widget build(BuildContext context) {
    final title = TextStyle(
      fontSize: 17.sp,
      fontWeight: FontWeight.w400,
      height: 18 / 17,
      color: AppColors.black,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: Text('Тип поля', style: title)),
        SizedBox(height: 8.h),
        _TrackSegmented<FieldType>(
          value: fieldType,
          onChanged: onFieldChanged,
          items: const [
            _SegItem(FieldType.natural, 'Натуральное'),
            _SegItem(FieldType.artificial, 'Искусственное'),
            _SegItem(FieldType.indoor, 'Зал'),
          ],
        ),
        SizedBox(height: 16.h),
        Center(child: Text('Погода', style: title)),
        SizedBox(height: 8.h),
        _TrackSegmented<Weather>(
          value: weather,
          onChanged: onWeatherChanged,
          items: const [
            _SegItem(Weather.sunny, 'Солнечно'),
            _SegItem(Weather.cloudy, 'Пасмурно'),
            _SegItem(Weather.rainSnow, 'Дождь/Снег'),
          ],
        ),
      ],
    );
  }
}

/// Фиксированная ширина трека по фигме и центрирование (329 px).
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

/// Трек 329×28, равные секции с разделителями.
/// Выбранная секция — белая «таблетка» 24 px с тенью. Текст масштабируется вниз.
class _TrackSegmented<T> extends StatelessWidget {
  final T value;
  final ValueChanged<T> onChanged;
  final List<_SegItem<T>> items;

  const _TrackSegmented({
    required this.value,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final idx = items.indexWhere((e) => e.value == value).clamp(0, items.length - 1);
    final trackH = 28.h;
    final pillH = 24.h;
    final trackR = 7.r;  // как в исходном контроле
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
        child: LayoutBuilder(builder: (ctx, c) {
          final w = c.maxWidth; // 329w
          final segW = w / items.length;

          return Stack(
            children: [
              // фон трека + разделители
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
              // активная белая «пилюля» строго внутри сегмента
              Positioned(
                top: (trackH - pillH) / 2,
                left: idx * segW + 4.w,
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
              // кликабельные области с подписями
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
                              child: Text(
                                items[i].label,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: i == idx ? textSel : textDef,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _SegItem<T> {
  final T value;
  final String label;
  const _SegItem(this.value, this.label);
}
