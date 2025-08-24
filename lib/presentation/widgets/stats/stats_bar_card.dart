import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:footlog/core/app_theme.dart';

class StatsBarCard extends StatelessWidget {
  final String title;
  final List<int> values;
  final List<String> labels;

  /// Итоговая высота карточки.
  final double? height;

  /// Минимальная ширина столбика; при недостатке места включится горизонтальный скролл.
  final double minBarWidth;

  /// Центрировать заголовок внутри карточки.
  final bool centerTitle;

  /// Показывать стрелку в правом нижнем углу.
  final bool showChevron;

  const StatsBarCard({
    super.key,
    required this.title,
    required this.values,
    required this.labels,
    this.height,
    this.minBarWidth = 18,
    this.centerTitle = true,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    assert(values.length == labels.length,
    'values и labels должны быть одинаковой длины');

    final double cardHeight = (height ?? 180).h;
    final double titleH = 28.h;
    final double topValueBoxH = 18.h;
    final double bottomLabelH = 16.h;
    final double verticalGap = 6.h;
    final double sidePadding = 12.w;
    final double barRound = 12.r;

    final int count = values.length;
    final int maxVal = max<int>(1, values.isEmpty ? 1 : values.reduce(max));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: AppColors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 12.h),
        child: LayoutBuilder(
          builder: (ctx, c) {
            final chartH = max<double>(60, cardHeight - titleH);
            final reservedVertical =
                topValueBoxH + verticalGap + bottomLabelH + verticalGap;
            final maxBarH = max<double>(0, chartH - reservedVertical);

            final totalW = c.maxWidth - sidePadding * 2;
            final spacing = 10.w;
            final barW =
            ((totalW - spacing * (count - 1)) / count).clamp(10.0, 38.0);
            final needScroll = barW < minBarWidth;

            Widget bars = Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(count, (i) {
                final v = values[i];
                final hNorm = v / maxVal;
                final thisBarH = maxBarH * hNorm;

                return Padding(
                  padding: EdgeInsets.only(right: i == count - 1 ? 0 : spacing),
                  child: SizedBox(
                    width: needScroll ? minBarWidth : barW,
                    height: chartH,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: topValueBoxH,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$v',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: verticalGap),
                        Container(
                          height: thisBarH,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(barRound),
                          ),
                        ),
                        SizedBox(height: verticalGap),
                        SizedBox(
                          height: bottomLabelH,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              labels[i],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );

            if (needScroll) {
              bars = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: bars,
              );
            }

            return Stack(
              children: [
                Column(
                  crossAxisAlignment:
                  centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: titleH,
                      child: Center(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: chartH, child: bars),
                  ],
                ),
                if (showChevron)
                  Positioned(
                    right: 2.w,
                    bottom: 2.h,
                    child: Icon(Icons.chevron_right,
                        size: 18.sp, color: AppColors.textGray),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
