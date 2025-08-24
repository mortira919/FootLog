import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_theme.dart';

/// Модалка выбора (дата начала + длительность), возвращает (DateTime, minutes) или null
Future<(DateTime, int)?> showDateDurationSheet(
    BuildContext context, {
      DateTime? initialDate,
      int initialDurationMin = 90,
    }) {
  return showModalBottomSheet<(DateTime, int)?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (_) => _DateDurationSheet(
      initialDate: initialDate,
      initialDurationMin: initialDurationMin,
    ),
  );
}

class _DateDurationSheet extends StatefulWidget {
  final DateTime? initialDate;
  final int initialDurationMin;
  const _DateDurationSheet({
    required this.initialDate,
    required this.initialDurationMin,
  });

  @override
  State<_DateDurationSheet> createState() => _DateDurationSheetState();
}

class _DateDurationSheetState extends State<_DateDurationSheet> {
  late final List<DateTime> _days;

  late FixedExtentScrollController _dayCtl;
  late FixedExtentScrollController _hourCtl;
  late FixedExtentScrollController _minCtl;
  late FixedExtentScrollController _durHourCtl;
  late FixedExtentScrollController _durMinCtl;

  int _dayIndex = 0;
  int _hourIndex = 0;
  int _minIndex = 0;
  int _durHourIndex = 0;
  int _durMinIndex = 0; // 0..11 => 0,5,10..55

  static const int _durMinuteStep = 5;
  late final double _itemExtent = 34.h;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Диапазон дат: 7 дней назад и ~18 месяцев вперёд
    const back = 7;
    const forwardDays = 550;
    _days = List.generate(
      back + forwardDays + 1,
          (i) => today.add(Duration(days: i - back)),
    );

    final init = widget.initialDate ?? now;
    final initDay = DateTime(init.year, init.month, init.day);

    _dayIndex = _days.indexWhere((d) => d == initDay).clamp(0, _days.length - 1);
    _hourIndex = init.hour;
    _minIndex = init.minute;

    _dayCtl = FixedExtentScrollController(initialItem: _dayIndex);
    _hourCtl = FixedExtentScrollController(initialItem: _hourIndex);
    _minCtl = FixedExtentScrollController(initialItem: _minIndex);

    _durHourIndex = (widget.initialDurationMin ~/ 60).clamp(0, 12);
    final durMinutes = widget.initialDurationMin % 60;
    _durMinIndex = (durMinutes ~/ _durMinuteStep).clamp(0, 11);

    _durHourCtl = FixedExtentScrollController(initialItem: _durHourIndex);
    _durMinCtl = FixedExtentScrollController(initialItem: _durMinIndex);
  }

  @override
  void dispose() {
    _dayCtl.dispose();
    _hourCtl.dispose();
    _minCtl.dispose();
    _durHourCtl.dispose();
    _durMinCtl.dispose();
    super.dispose();
  }

  // --- UI helpers ---

  Widget _selectionOverlay() => Center(
    child: Container(
      height: _itemExtent,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: ShapeDecoration(
        color: const Color(0xFFF2F3F5).withOpacity(0.6), // ПРОЗРАЧНОСТЬ!
        shape: const StadiumBorder(),
      ),
    ),
  );


  TextStyle get _selectedStyle =>
      TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.black);

  TextStyle get _unselectedStyle => TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.black.withOpacity(0.35),
  );

  String _fmtDayLabel(BuildContext ctx, DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (d == today) return 'Сегодня';

    final code = Localizations.localeOf(ctx).languageCode;
    if (code == 'ru') {
      const wd = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
      const mm = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
      final w = wd[(d.weekday + 6) % 7];
      return '$w ${d.day} ${mm[d.month - 1]}';
    } else {
      const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const mm = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final w = wd[(d.weekday + 6) % 7];
      return '$w ${d.day} ${mm[d.month - 1]}';
    }
  }

  Widget _title(String t) => Text(
    t,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppColors.black),
  );

  Widget _subtitle(String t) => Padding(
    padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
    child: Text(
      t,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.black),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final safeBottom =
        MediaQuery.of(context).padding.bottom + MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: safeBottom),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _title('Дата и длительность матча'),
              _subtitle('Дата и время начала матча'),

              // --- Дата + время ---
              SizedBox(
                height: (_itemExtent * 5).clamp(160.h, 200.h),
                child: Row(
                  children: [
                    // Дата
                    Expanded(
                      flex: 6,
                      child: CupertinoPicker.builder(
                        scrollController: _dayCtl,
                        itemExtent: _itemExtent,
                        useMagnifier: false,
                        magnification: 1.0,
                        squeeze: 1.0,
                        selectionOverlay: _selectionOverlay(),
                        childCount: _days.length,
                        itemBuilder: (ctx, i) {
                          final isSel = i == _dayIndex;
                          return Center(
                            child: Text(
                              _fmtDayLabel(ctx, _days[i]),
                              style: isSel ? _selectedStyle : _unselectedStyle,
                            ),
                          );
                        },
                        onSelectedItemChanged: (i) => setState(() => _dayIndex = i),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Часы
                    Expanded(
                      flex: 3,
                      child: CupertinoPicker.builder(
                        scrollController: _hourCtl,
                        itemExtent: _itemExtent,
                        useMagnifier: false,
                        magnification: 1.0,
                        squeeze: 1.0,
                        selectionOverlay: _selectionOverlay(),
                        childCount: 24,
                        itemBuilder: (ctx, i) {
                          final isSel = i == _hourIndex;
                          return Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: isSel ? _selectedStyle : _unselectedStyle,
                            ),
                          );
                        },
                        onSelectedItemChanged: (i) => setState(() => _hourIndex = i),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Минуты
                    Expanded(
                      flex: 3,
                      child: CupertinoPicker.builder(
                        scrollController: _minCtl,
                        itemExtent: _itemExtent,
                        useMagnifier: false,
                        magnification: 1.0,
                        squeeze: 1.0,
                        selectionOverlay: _selectionOverlay(),
                        childCount: 60,
                        itemBuilder: (ctx, i) {
                          final isSel = i == _minIndex;
                          return Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: isSel ? _selectedStyle : _unselectedStyle,
                            ),
                          );
                        },
                        onSelectedItemChanged: (i) => setState(() => _minIndex = i),
                      ),
                    ),
                  ],
                ),
              ),

              _subtitle('Длительность матча'),

              // --- Длительность ---
              SizedBox(
                height: (_itemExtent * 5).clamp(160.h, 200.h),
                child: Row(
                  children: [
                    // Часы
                    Expanded(
                      flex: 4,
                      child: CupertinoPicker.builder(
                        scrollController: _durHourCtl,
                        itemExtent: _itemExtent,
                        useMagnifier: false,
                        magnification: 1.0,
                        squeeze: 1.0,
                        selectionOverlay: _selectionOverlay(),
                        childCount: 13, // 0..12
                        itemBuilder: (ctx, i) {
                          final isSel = i == _durHourIndex;
                          return Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: isSel ? _selectedStyle : _unselectedStyle,
                            ),
                          );
                        },
                        onSelectedItemChanged: (i) => setState(() => _durHourIndex = i),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ru' ? 'часы' : 'hours',
                      style: TextStyle(fontSize: 15.sp, color: AppColors.black.withOpacity(0.55)),
                    ),
                    SizedBox(width: 10.w),
                    // Минуты (0,5,10..55)
                    Expanded(
                      flex: 4,
                      child: CupertinoPicker.builder(
                        scrollController: _durMinCtl,
                        itemExtent: _itemExtent,
                        useMagnifier: false,
                        magnification: 1.0,
                        squeeze: 1.0,
                        selectionOverlay: _selectionOverlay(),
                        childCount: 12,
                        itemBuilder: (ctx, i) {
                          final isSel = i == _durMinIndex;
                          final m = i * _durMinuteStep;
                          return Center(
                            child: Text(
                              m.toString().padLeft(2, '0'),
                              style: isSel ? _selectedStyle : _unselectedStyle,
                            ),
                          );
                        },
                        onSelectedItemChanged: (i) => setState(() => _durMinIndex = i),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ru' ? 'минуты' : 'minutes',
                      style: TextStyle(fontSize: 15.sp, color: AppColors.black.withOpacity(0.55)),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    final d = _days[_dayIndex];
                    final start = DateTime(
                      d.year,
                      d.month,
                      d.day,
                      _hourIndex % 24,
                      _minIndex % 60,
                    );
                    int duration = _durHourIndex * 60 + _durMinIndex * _durMinuteStep;
                    duration = duration.clamp(10, 180);
                    Navigator.of(context).pop((start, duration));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Готово',
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
