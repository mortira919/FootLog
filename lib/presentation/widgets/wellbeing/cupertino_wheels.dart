import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MealDelayPicker extends StatefulWidget {
  final int initialMinutes;
  final ValueChanged<int> onConfirm;
  final int maxHours;
  final int minuteStep;
  final String hoursWord;
  final String minutesWord;

  const MealDelayPicker({
    super.key,
    required this.initialMinutes,
    required this.onConfirm,
    this.maxHours = 23,
    this.minuteStep = 5,
    this.hoursWord = 'hours',
    this.minutesWord = 'minutes',
  }) : assert(minuteStep > 0 && 60 % minuteStep == 0);

  @override
  State<MealDelayPicker> createState() => _MealDelayPickerState();
}

class _MealDelayPickerState extends State<MealDelayPicker> {
  late Duration _duration;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    final init = Duration(minutes: widget.initialMinutes);
    final m = init.inMinutes % 60;
    final rounded = (m ~/ widget.minuteStep) * widget.minuteStep;
    _duration = Duration(hours: init.inHours, minutes: rounded);
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      delegates: [
        _TimerUnitsCupertinoDelegate(
          hoursWord: widget.hoursWord,
          minutesWord: widget.minutesWord,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 170.h,
            child: Stack(
              children: [

                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _locked,
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hm,
                      minuteInterval: widget.minuteStep,
                      initialTimerDuration: _duration,
                      onTimerDurationChanged: (d) =>
                          setState(() => _duration = d),
                    ),
                  ),
                ),

                if (_locked)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: AnimatedOpacity(
                        opacity: 0.35,
                        duration: const Duration(milliseconds: 120),
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 48.h,
            child: _locked
                ? OutlinedButton(
              onPressed: () => setState(() => _locked = false),
              child: Text(
                'Изменить',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
                : ElevatedButton(
              onPressed: () {
                final total = _duration.inMinutes;
                final maxTotal = widget.maxHours * 60;
                final clamped = total.clamp(0, maxTotal).toInt();
                setState(() => _locked = true);
                widget.onConfirm(clamped);
              },
              child: Text(
                'Выбрать',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _TimerUnitsCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  final String hoursWord;
  final String minutesWord;

  const _TimerUnitsCupertinoDelegate({
    required this.hoursWord,
    required this.minutesWord,
  });

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return _TimerUnitsCupertinoLocalizations(
      hoursWord: hoursWord,
      minutesWord: minutesWord,
    );
  }

  @override
  bool shouldReload(_TimerUnitsCupertinoDelegate old) =>
      old.hoursWord != hoursWord || old.minutesWord != minutesWord;
}

class _TimerUnitsCupertinoLocalizations extends DefaultCupertinoLocalizations {
  final String hoursWord;
  final String minutesWord;

  const _TimerUnitsCupertinoLocalizations({
    required this.hoursWord,
    required this.minutesWord,
  });

  @override
  String timerPickerHourLabel(int hour) => hoursWord;

  @override
  String timerPickerMinuteLabel(int minute) => minutesWord;
}
