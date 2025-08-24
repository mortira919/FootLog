// lib/presentation/widgets/matches/team_inputs.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_theme.dart';

class TeamInputs extends StatefulWidget {
  final String yourTeam;
  final String opponentTeam;
  final ValueChanged<String>? onYourChanged;
  final ValueChanged<String>? onOpponentChanged;

  const TeamInputs({
    super.key,
    required this.yourTeam,
    required this.opponentTeam,
    this.onYourChanged,
    this.onOpponentChanged,
  });

  @override
  State<TeamInputs> createState() => _TeamInputsState();
}

class _TeamInputsState extends State<TeamInputs> {
  late final TextEditingController _yourC;
  late final TextEditingController _oppC;

  @override
  void initState() {
    super.initState();
    _yourC = TextEditingController(text: widget.yourTeam);
    _oppC  = TextEditingController(text: widget.opponentTeam);

    _yourC.addListener(() {
      final cb = widget.onYourChanged;
      if (cb != null) cb(_yourC.text);
    });
    _oppC.addListener(() {
      final cb = widget.onOpponentChanged;
      if (cb != null) cb(_oppC.text);
    });
  }

  @override
  void didUpdateWidget(covariant TeamInputs oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.yourTeam != oldWidget.yourTeam &&
        widget.yourTeam != _yourC.text) {
      _yourC.value = TextEditingValue(
        text: widget.yourTeam,
        selection: TextSelection.collapsed(offset: widget.yourTeam.length),
      );
    }

    if (widget.opponentTeam != oldWidget.opponentTeam &&
        widget.opponentTeam != _oppC.text) {
      _oppC.value = TextEditingValue(
        text: widget.opponentTeam,
        selection: TextSelection.collapsed(offset: widget.opponentTeam.length),
      );
    }
  }

  @override
  void dispose() {
    _yourC.dispose();
    _oppC.dispose();
    super.dispose();
  }

  // измеряем ширину текста с учётом текущего масштаба
  double _measure(BuildContext ctx, String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(ctx),
      maxLines: 1,
      textScaler: TextScaler.linear(MediaQuery.textScaleFactorOf(ctx)),
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    final labelStyleForMeasure = TextStyle(
      fontSize: 17.sp, fontWeight: FontWeight.w400, height: 1.0, color: AppColors.black,
    );

    // единая ширина колонки лейбла (адаптивная) для обеих строк
    final contentW = MediaQuery.of(context).size.width - 32.w; // padding карточки 16+16
    final maxTextW = math.max(
      _measure(context, 'Ваша', labelStyleForMeasure),
      _measure(context, 'Соперника', labelStyleForMeasure),
    );
    final desired = maxTextW + 6.w; // плотный буфер к каретке
    final double labelColumnWidth = desired.clamp(72.w, contentW * 0.38);

    return Column(
      children: [
        _InlineLinedFieldCtrl(
          label: 'Ваша',
          controller: _yourC,
          labelColumnWidth: labelColumnWidth,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 10.h),
        _InlineLinedFieldCtrl(
          label: 'Соперника',
          controller: _oppC,
          labelColumnWidth: labelColumnWidth,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

class _InlineLinedFieldCtrl extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double labelColumnWidth; // фиксированная (для обеих строк) ширина колонки лейбла
  final TextInputAction textInputAction;

  const _InlineLinedFieldCtrl({
    required this.label,
    required this.controller,
    required this.labelColumnWidth,
    required this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    // типографика: Regular 17, плотная посадка к линии
    final labelStyle = TextStyle(
      fontSize: 17.sp, fontWeight: FontWeight.w400, height: 1.0, color: AppColors.black,
    );
    final inputStyle = TextStyle(
      fontSize: 17.sp, fontWeight: FontWeight.w400, height: 1.0, color: AppColors.black,
    );
    final hintStyle = inputStyle.copyWith(color: AppColors.labelGray30);

    final strut = StrutStyle(
      forceStrutHeight: true, height: 1.0,
      fontSize: inputStyle.fontSize, fontWeight: inputStyle.fontWeight, fontFamily: inputStyle.fontFamily,
    );

    const double gap = 6; // плотный зазор лейбл ↔ каретка

    return SizedBox(
      height: 44.h, // вся строка 44, линия — внутри
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 0)), // hairline
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(
              width: labelColumnWidth,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Text(
                    label,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: labelStyle,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: gap.w),
            Expanded(
              child: TextFormField(
                controller: controller,
                textInputAction: textInputAction,
                cursorColor: AppColors.primary,
                style: inputStyle,
                strutStyle: strut,
                textAlignVertical: TextAlignVertical.bottom,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Название',
                  contentPadding: EdgeInsets.only(bottom: 1),
                ).copyWith(hintStyle: hintStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
