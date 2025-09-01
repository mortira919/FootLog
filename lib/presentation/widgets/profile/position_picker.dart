// lib/presentation/widgets/profile/position_picker.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:footlog/core/app_theme.dart';

class PositionPickerMini extends StatelessWidget {
  final String value; // 'GK','CB','CM',...
  final ValueChanged<String> onChanged;

  const PositionPickerMini({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () async {
          HapticFeedback.selectionClick();
          final picked = await showPositionPickerSheet(
            context,
            initial: value,
          );
          if (picked != null) onChanged(picked);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEEF0),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            _labelRu(value),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> showPositionPickerSheet(
    BuildContext context, {
      required String initial,
    }) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _InsetSheetFrame(
      maxWidth: 361,
      margin: const EdgeInsets.all(16),
      child: _PositionSheet(initial: initial),
    ),
  );
}

class _InsetSheetFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets margin;
  const _InsetSheetFrame({
    required this.child,
    this.maxWidth = 361,
    this.margin = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final safeTop = mq.padding.top;
    final kb = mq.viewInsets.bottom;

    const figmaTop = 20.0;
    final topGap = math.max(safeTop + 6.0, figmaTop - margin.top);

    final sheetMaxHeight = mq.size.height - topGap - margin.bottom - kb;
    final availableWidth = mq.size.width - margin.horizontal;
    final effectiveMaxWidth = math.min(maxWidth, availableWidth);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(top: topGap, bottom: kb),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: margin,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
            child: SizedBox(
              height: sheetMaxHeight,
              child: Material(
                color: AppColors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionSheet extends StatefulWidget {
  final String initial;
  const _PositionSheet({required this.initial});

  @override
  State<_PositionSheet> createState() => _PositionSheetState();
}

class _PositionSheetState extends State<_PositionSheet> {
  late String _selected = widget.initial;

  double _hairline(BuildContext context) =>
      1 / MediaQuery.of(context).devicePixelRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      checkboxTheme: CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: WidgetStateBorderSide.resolveWith(
              (_) => const BorderSide(color: AppColors.primary, width: 2),
        ),
        fillColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.white),
        visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
      ),
    );

    return Theme(
      data: theme,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Text(
                  'Укажите новую позицию',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _group('Вратарь'),
                    _row(context, 'GK'),
                    _divider(context),
                    _group('Защитники'),
                    _row(context, 'CB'),
                    _row(context, 'LB'),
                    _row(context, 'RB'),
                    _divider(context),
                    _group('Полузащитники'),
                    _row(context, 'CDM'),
                    _row(context, 'CM'),
                    _row(context, 'CAM'),
                    _row(context, 'RM'),
                    _row(context, 'LM'),
                    _divider(context),
                    _group('Вингеры'),
                    _row(context, 'RW'),
                    _row(context, 'LW'),
                    _divider(context),
                    _group('Нападающие'),
                    _row(context, 'ST'),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
              SizedBox(
                height: 48.h,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, _selected),
                  child: const Text('Готово'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _group(String t) => Padding(
    padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
    child: Center(
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
      ),
    ),
  );

  Widget _divider(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      height: _hairline(context),
      color: const Color(0x4A3C3C43),
    ),
  );

  Widget _row(BuildContext context, String code) {
    final compact = MediaQuery.of(context).size.height < 760;
    final h = compact ? 38.0 : 40.0;
    final isSel = _selected == code;

    return InkWell(
      onTap: () {
        setState(() => _selected = code);
        HapticFeedback.selectionClick();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: h,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$code — ${_labelRu(code)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 15.5 : 16,
                    height: 1.05,
                  ),
                ),
              ),
              Transform.scale(
                scale: compact ? 0.86 : 0.9,
                child: Checkbox(
                  value: isSel,
                  onChanged: (_) => setState(() => _selected = code),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _labelRu(String code) {
  switch (code) {
    case 'GK':
      return 'Вратарь';
    case 'CB':
      return 'Центральный защитник';
    case 'LB':
      return 'Левый защитник';
    case 'RB':
      return 'Правый защитник';
    case 'CDM':
      return 'Опорный полузащитник';
    case 'CM':
      return 'Центральный полузащитник';
    case 'CAM':
      return 'Атакующий полузащитник';
    case 'RM':
      return 'Правый полузащитник';
    case 'LM':
      return 'Левый полузащитник';
    case 'RW':
      return 'Правый вингер';
    case 'LW':
      return 'Левый вингер';
    case 'ST':
      return 'Страйкер';
    default:
      return code;
  }
}
