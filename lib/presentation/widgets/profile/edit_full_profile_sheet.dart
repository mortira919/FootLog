// lib/presentation/widgets/profile/edit_full_profile_sheet.dart
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:footlog/core/app_theme.dart';
import 'package:footlog/presentation/widgets/common_form_fields.dart';
import 'package:footlog/presentation/widgets/profile/position_picker.dart';
import 'package:footlog/domain/profile/entities/player_profile.dart';

Future<PlayerProfile?> showFullProfileSheet(
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
      maxWidth: 361,
      margin: const EdgeInsets.all(16),
      child: _FullProfileSheet(initial: initial),
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

class _FullProfileSheet extends StatefulWidget {
  final PlayerProfile initial;
  const _FullProfileSheet({required this.initial});

  @override
  State<_FullProfileSheet> createState() => _FullProfileSheetState();
}

class _FullProfileSheetState extends State<_FullProfileSheet> {
  late final TextEditingController _name;
  late final FocusNode _nameFocus;
  late final TextEditingController _team;
  late final TextEditingController _kit;
  late final TextEditingController _height;
  late final TextEditingController _weight;

  DateTime? _birth;
  late String _foot;     // 'left' | 'right'
  late String _position; // 'GK','CB','CM',...

  @override
  void initState() {
    super.initState();
    final init = widget.initial;

    _nameFocus = FocusNode();
    _name   = TextEditingController(text: init.name);
    _team   = TextEditingController(text: init.teamName ?? '');
    _kit    = TextEditingController(text: init.kitNumber ?? '');
    _height = TextEditingController(text: init.heightCm?.toString() ?? '');
    _weight = TextEditingController(text: init.weightKg?.toString() ?? '');

    _birth    = init.birthDate;
    _foot     = init.dominantFoot.isEmpty ? 'right' : init.dominantFoot;
    _position = init.position.isEmpty ? 'ST' : init.position;
  }

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    _team.dispose();
    _kit.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  double _hairline(BuildContext context) =>
      1 / MediaQuery.of(context).devicePixelRatio;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birth ?? DateTime(now.year - 20, 1, 1);

    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (_) => _CupertinoDatePickerSheet(
        title: 'Дата рождения',
        initial: initial,
        min: DateTime(now.year - 70, 1, 1),
        max: now,
      ),
    );
    if (picked != null) setState(() => _birth = picked);
  }

  String _fmtDateChip(DateTime d) {
    const mm = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${mm[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.height < 760;

    return SafeArea(
      top: false,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Column(
            children: [
              _header(context),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _sectionTitle('Дата рождения'),
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: _pickBirthDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEEF0),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            _birth == null ? 'Выбрать' : _fmtDateChip(_birth!),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _sectionTitle('Рост и вес'),
                    _metricRow(
                      label: 'Рост',
                      controller: _height,
                      inputAction: TextInputAction.next,
                      maxLength: 3,
                    ),
                    _metricRow(
                      label: 'Вес',
                      controller: _weight,
                      inputAction: TextInputAction.next,
                      maxLength: 3,
                    ),
                    SizedBox(height: 12.h),

                    _sectionTitle('Рабочая нога'),
                    Theme(
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
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
                        ),
                      ),
                      child: Column(
                        children: [
                          _footRow(
                            'Правая',
                            selected: _foot == 'right',
                            onTap: () {
                              setState(() => _foot = 'right');
                              HapticFeedback.selectionClick();
                            },
                          ),
                          _footRow(
                            'Левая',
                            selected: _foot == 'left',
                            onTap: () {
                              setState(() => _foot = 'left');
                              HapticFeedback.selectionClick();
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _sectionTitle('Позиция'),
                    PositionPickerMini(
                      value: _position,
                      onChanged: (v) => setState(() => _position = v),
                    ),
                    SizedBox(height: 12.h),

                    // === Игровой номер (как на макете: Номер | [17] | х | линия)
                    _sectionTitle('Игровой номер'),
                    _metricRow(
                      label: 'Номер',
                      controller: _kit,
                      inputAction: TextInputAction.next,
                      maxLength: 2, // 1..99
                    ),
                    SizedBox(height: 12.h),

                    // === Название вашей команды (заголовок по центру + ряд "Название")
                    _sectionTitle('Название вашей команды'),
                    _labeledTextRow(
                      label: 'Название',
                      controller: _team,
                      hint: 'Название команды',
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: compact ? 12.h : 16.h),
                  ],
                ),
              ),

              PrimaryButton(
                label: 'Готово',
                onPressed: () {
                  final h = int.tryParse(_height.text.trim());
                  final w = int.tryParse(_weight.text.trim());

                  final updated = PlayerProfile(
                    name: _name.text.trim().isEmpty ? widget.initial.name : _name.text.trim(),
                    teamName: _team.text.trim().isEmpty ? null : _team.text.trim(),
                    kitNumber: _kit.text.trim().isEmpty ? null : _kit.text.trim(),
                    birthDate: _birth,
                    heightCm: h,
                    weightKg: w,
                    dominantFoot: _foot,
                    position: _position,
                  );

                  Navigator.pop(context, updated);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Text(
      t,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.black,
      ),
    ),
  );

  // Ряд «лейбл слева — цифры по центру — крестик справа — нижний разделитель»
  Widget _metricRow({
    required String label,
    required TextEditingController controller,
    required TextInputAction inputAction,
    required int maxLength,
  }) {
    final double kRowH = 44.h;
    final double kClearSize = 20.r;

    final TextStyle labelStyle = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: Colors.black,
      height: 1.2,
    );
    final TextStyle valueStyle = TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w400,
      color: Colors.black,
      height: 1.2,
    );
    final StrutStyle valueStrut = StrutStyle(
      forceStrutHeight: true,
      height: 1.2,
      fontSize: valueStyle.fontSize,
      fontWeight: valueStyle.fontWeight,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: kRowH,
          child: Row(
            children: [
              Text(label, style: labelStyle),
              const Spacer(),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 48.w, maxWidth: 96.w),
                child: TextField(
                  controller: controller,
                  textInputAction: inputAction,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(maxLength),
                  ],
                  cursorColor: AppColors.primary,
                  style: valueStyle,
                  strutStyle: valueStrut,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '',
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
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
                          controller.clear();
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Container(height: _hairline(context), color: const Color(0x4A3C3C43)),
      ],
    );
  }

  // Ряд «лейбл — текстовое поле (с подсказкой) — нижний разделитель»
  Widget _labeledTextRow({
    required String label,
    required TextEditingController controller,
    String? hint,
    required TextInputAction textInputAction,
  }) {
    final double kRowH = 44.h;

    final TextStyle labelStyle = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: Colors.black,
      height: 1.2,
    );
    final TextStyle fieldStyle = TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w400,
      color: Colors.black,
      height: 1.2,
    );
    final StrutStyle fieldStrut = StrutStyle(
      forceStrutHeight: true,
      height: 1.2,
      fontSize: fieldStyle.fontSize,
      fontWeight: fieldStyle.fontWeight,
    );

    return Column(
      children: [
        SizedBox(
          height: kRowH,
          child: Row(
            children: [
              Text(label, style: labelStyle),
              SizedBox(width: 16.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: textInputAction,
                  cursorColor: AppColors.primary,
                  style: fieldStyle,
                  strutStyle: fieldStrut,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: hint,
                    hintStyle: fieldStyle.copyWith(color: Colors.black38),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: _hairline(context), color: const Color(0x4A3C3C43)),
      ],
    );
  }

  Widget _footRow(
      String label, {
        required bool selected,
        required VoidCallback onTap,
      }) {
    final compact = MediaQuery.of(context).size.height < 760;
    final h = compact ? 38.0 : 40.0;

    return InkWell(
      onTap: onTap,
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
                  onChanged: (v) {
                    if (v == true) onTap();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final double kLeft = 16.w;
    final double kRight = 16.w;
    final double kTop = 12.h;
    final double kBottom = 4.h;
    final double kLabelGap = 24.w;
    final double kClearGap = 12.w;
    final double kClearSize = 24.r;
    final double kRowH = 44.h;

    final TextStyle kInputText = TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.w400,
      height: 1.25,
      color: Colors.black,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Имя', style: kInputText, strutStyle: kStrut),
                SizedBox(width: kLabelGap),
                Expanded(
                  child: TextField(
                    controller: _name,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
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
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
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
        Padding(
          padding: EdgeInsets.only(left: kLeft, right: kRight),
          child: Container(
            height: _hairline(context),
            color: const Color(0x4A3C3C43),
          ),
        ),
      ],
    );
  }
}

class _CupertinoDatePickerSheet extends StatefulWidget {
  final String title;
  final DateTime initial;
  final DateTime min;
  final DateTime max;
  const _CupertinoDatePickerSheet({
    required this.title,
    required this.initial,
    required this.min,
    required this.max,
  });

  @override
  State<_CupertinoDatePickerSheet> createState() => _CupertinoDatePickerSheetState();
}

class _CupertinoDatePickerSheetState extends State<_CupertinoDatePickerSheet> {
  late DateTime value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Text(widget.title, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: value,
                minimumDate: widget.min,
                maximumDate: widget.max,
                onDateTimeChanged: (d) => setState(() => value = d),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h + safeBottom),
              child: SizedBox(
                height: 48.h,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, value),
                  child: const Text('Готово'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  const _ClearCircleButton({required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.52;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFF8E8E93),
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
