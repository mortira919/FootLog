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
    _yourC.addListener(() => widget.onYourChanged?.call(_yourC.text));
    _oppC.addListener(() => widget.onOpponentChanged?.call(_oppC.text));
  }

  @override
  void didUpdateWidget(covariant TeamInputs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.yourTeam != oldWidget.yourTeam && widget.yourTeam != _yourC.text) {
      _yourC.value = TextEditingValue(
        text: widget.yourTeam,
        selection: TextSelection.collapsed(offset: widget.yourTeam.length),
      );
    }
    if (widget.opponentTeam != oldWidget.opponentTeam && widget.opponentTeam != _oppC.text) {
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

    final contentW = MediaQuery.of(context).size.width - 32.w; // padding карточки 16+16
    final maxTextW = math.max(
      _measure(context, 'Ваша', labelStyleForMeasure),
      _measure(context, 'Соперника', labelStyleForMeasure),
    );
    final desired = maxTextW + 6.w;
    final double labelColumnWidth = desired.clamp(72.w, contentW * 0.38);

    final double hairline = 1 / MediaQuery.of(context).devicePixelRatio; // 1px линия

    return Column(
      children: [
        _InlineLinedFieldCtrl(
          label: 'Ваша',
          controller: _yourC,
          labelColumnWidth: labelColumnWidth,
          textInputAction: TextInputAction.next,
          hairline: hairline,
          bottomInset: 12.h, // расстояние от текста до линии
        ),
        SizedBox(height: 10.h),
        _InlineLinedFieldCtrl(
          label: 'Соперника',
          controller: _oppC,
          labelColumnWidth: labelColumnWidth,
          textInputAction: TextInputAction.done,
          hairline: hairline,
          bottomInset: 12.h,
        ),
      ],
    );
  }
}

class _InlineLinedFieldCtrl extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double labelColumnWidth;
  final TextInputAction textInputAction;
  final double hairline;
  final double bottomInset;

  const _InlineLinedFieldCtrl({
    required this.label,
    required this.controller,
    required this.labelColumnWidth,
    required this.textInputAction,
    required this.hairline,
    this.bottomInset = 12,
  });

  @override
  Widget build(BuildContext context) {
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

    final double gap = 6.w;

    return SizedBox(
      height: 56.h, // больше «воздуха», как в макете
      child: Stack(
        children: [
          // разделительная линия (1px)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: hairline, color: const Color(0x4A3C3C43)),
          ),
          // контент с отступом от линии
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
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
                      child: Text(label, style: labelStyle),
                    ),
                  ),
                ),
                SizedBox(width: gap),
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
                      contentPadding: EdgeInsets.zero,
                    ).copyWith(hintStyle: hintStyle),
                    autocorrect: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
