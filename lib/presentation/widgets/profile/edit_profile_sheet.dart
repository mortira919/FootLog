import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:footlog/domain/home/entities/player_profile.dart';
import 'package:footlog/domain/home/enums/positions.dart';
import 'dart:math' as math;

import '../../../core/app_theme.dart';

/// Хелпер: открыть мини-шторку редактирования профиля.
Future<PlayerProfile?> showEditProfileBottomSheet(
    BuildContext context, {
      required PlayerProfile initial,
    }) {
  return showModalBottomSheet<PlayerProfile>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _InsetSheetFrame(
      maxWidth: 361, // подгон под макет Фигмы
      margin: const EdgeInsets.all(16),
      child: EditProfileBottomSheet(initial: initial),
    ),
  );
}

/// Внешняя рамка/«карточка»: центр, фикс. ширина, скругления, тень.
class _InsetSheetFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets margin;
  const _InsetSheetFrame({
    super.key,
    required this.child,
    this.maxWidth = 361,
    this.margin = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final safeTop = mq.padding.top;
    final kb = mq.viewInsets.bottom;

    const figmaTop = 20.0; // из макета
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

/// Содержимое мини-шита.
class EditProfileBottomSheet extends StatefulWidget {
  final PlayerProfile initial;
  const EditProfileBottomSheet({super.key, required this.initial});

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  late final TextEditingController _name;
  late final FocusNode _nameFocus;
  late Position _primary;
  late Set<Position> _positions;

  @override
  void initState() {
    super.initState();
    _nameFocus = FocusNode();
    _name = TextEditingController(text: widget.initial.name);
    _primary = widget.initial.primaryPosition;
    _positions = {_primary};
  }

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  double _hairline(BuildContext context) =>
      1 / MediaQuery.of(context).devicePixelRatio;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.height < 760; // авто-ужимание

    return SafeArea(
      top: false,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            checkboxTheme: CheckboxThemeData(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: WidgetStateBorderSide.resolveWith(
                    (_) => const BorderSide(color: AppColors.primary, width: 2),
              ),
              fillColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              checkColor: const WidgetStatePropertyAll(AppColors.white),
              visualDensity:
              const VisualDensity(horizontal: -2, vertical: -3),
            ),
            listTileTheme: const ListTileThemeData(
              dense: true,
              horizontalTitleGap: 8,
              minLeadingWidth: 0,
              minVerticalPadding: 4,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(context), // «Имя»
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: compact ? 4 : 6),
                  children: [
                    _group('Вратарь', extraTopGap: false),
                    _row(context, Position.GK, 'GK — Вратарь'),

                    _group('Защитники', extraTopGap: true),
                    _row(context, Position.CB, 'CB — Центральный защитник'),
                    _row(context, Position.LB, 'LB — Левый защитник'),
                    _row(context, Position.RB, 'RB — Правый защитник'),

                    _group('Полузащитники', extraTopGap: true),
                    _row(context, Position.CDM, 'CDM — Опорный полузащитник'),
                    _row(context, Position.CM, 'CM — Центральный полузащитник'),
                    _row(context, Position.CAM, 'CAM — Атакующий полузащитник'),
                    _row(context, Position.RM, 'RM — Правый полузащитник'),
                    _row(context, Position.LM, 'LM — Левый полузащитник'),

                    _group('Вингеры', extraTopGap: true),
                    _row(context, Position.RW, 'RW — Правый вингер'),
                    _row(context, Position.LW, 'LW — Левый вингер'),

                    _group('Нападающие', extraTopGap: true),
                    _row(context, Position.ST, 'ST — Страйкер'),
                  ],
                ),
              ),
              _saveButton(Theme.of(context).colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Header: «Имя | [ввод] | (очистить)» + длинный separator
  Widget _header(BuildContext context) {
    // отступы ВНУТРИ шита: 16 слева/справа → 32 от экрана
    final double kLeft = 16.w;
    final double kRight = 16.w;
    final double kTop = 12.h; // меньше «лоба»
    final double kBottom = 4.h; // линия ближе к полю
    final double kLabelGap = 24.w;
    final double kClearGap = 12.w;
    final double kClearSize = 24.r;
    final double kRowH = 44.h;

    // единые метрики текста (лейбл/хинт/ввод)
    final TextStyle kInputText = TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.w400,
      height: 1.25,
      color: Colors.black,
      // fontFamily: 'SF Pro Text',
    );
    final StrutStyle kStrut = StrutStyle(
      forceStrutHeight: true,
      height: 1.25,
      leading: 0,
      fontSize: kInputText.fontSize,
      fontWeight: kInputText.fontWeight,
      fontFamily: kInputText.fontFamily,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(kLeft, kTop, kRight, kBottom),
          child: SizedBox(
            height: kRowH,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Имя',
                  style: kInputText,
                  strutStyle: kStrut,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                ),
                SizedBox(width: kLabelGap),
                Expanded(
                  child: TextField(
                    controller: _name,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.done,
                    cursorColor: AppColors.primary,
                    style: kInputText,
                    strutStyle: kStrut,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Имя Фамилия',
                      hintStyle: kInputText,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SizedBox(
                  width: kClearGap + kClearSize,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _name,
                      builder: (context, value, _) {
                        final show = value.text.isNotEmpty;
                        return AnimatedOpacity(
                          opacity: show ? 1 : 0,
                          duration: const Duration(milliseconds: 120),
                          child: IgnorePointer(
                            ignoring: !show,
                            child: _ClearCircleButton(
                              size: kClearSize,
                              onTap: () {
                                _name.clear();
                                _nameFocus.requestFocus();
                                HapticFeedback.selectionClick();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Длинная серая линия (отступы по 16 внутри шита)
        Padding(
          padding: EdgeInsets.only(left: kLeft, right: kRight),
          child: Container(
            height: 1, // гарантированно видимый hairline (1dp)
            color: const Color(0x4A3C3C43), // iOS separator ~29% от #3C3C43
          ),
        ),
      ],
    );
  }

  // ====== компактные заголовки групп
  Widget _group(String t, {bool extraTopGap = false}) {
    final compact = MediaQuery.of(context).size.height < 760;
    final top = extraTopGap ? (compact ? 10.0 : 12.0) : (compact ? 6.0 : 8.0);
    final bottom = compact ? 2.0 : 4.0;
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom),
      child: Center(
        child: Text(
          t,
          style: TextStyle(
            fontSize: compact ? 19 : 20,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }

  // ====== тонкая строка позиции (вместо ListTile)
  Widget _row(BuildContext context, Position p, String label) {
    final compact = MediaQuery.of(context).size.height < 760;
    final h = compact ? 38.0 : 40.0;
    final selected = p == _primary;

    return InkWell(
      onTap: () => setState(() {
        _primary = p;
        _positions = {p};
        HapticFeedback.selectionClick();
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: h,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 15.5 : 16,
                    fontWeight: FontWeight.w400,
                    height: 1.05,
                  ),
                ),
              ),
              Transform.scale(
                scale: compact ? 0.86 : 0.9,
                child: Checkbox(
                  value: selected,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _primary = p;
                      _positions = {p};
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveButton(ColorScheme cs) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: SizedBox(
      height: 44,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final name = _name.text.trim().isEmpty
              ? widget.initial.name
              : _name.text.trim();
          final fixed = <Position>{_primary};
          Navigator.pop(
            context,
            PlayerProfile(
              name: name,
              primaryPosition: _primary,
              positions: fixed.toList(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Готово',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

/// Кнопка-«очистить» — маленький серый кружок как на iOS
class _ClearCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  const _ClearCircleButton({required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.52; // маленький крестик
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFF8E8E93), // iOS gray
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.close_rounded,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }
}
