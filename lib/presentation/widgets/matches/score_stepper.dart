import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_theme.dart';


class ScoreRowFigma extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const ScoreRowFigma({
    super.key,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.black);
    final valueStyle = TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600, color: AppColors.black);

    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        SizedBox(width: 32.w, child: Text('$value', textAlign: TextAlign.right, style: valueStyle)),
        SizedBox(width: 12.w),
        _MiniStepper(onMinus: onMinus, onPlus: onPlus),
      ],
    );
  }
}

class _MiniStepper extends StatelessWidget {
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _MiniStepper({required this.onMinus, required this.onPlus});

  double _snap(BuildContext context, double v) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return (v * dpr).round() / dpr;
  }

  @override
  Widget build(BuildContext context) {
    final double w = _snap(context, 94.w); // пиксель-снап, чтобы не было микро-оверфлоу
    final double h = 32.h;
    final double r = 8.r;
    const Color trackBg = Color(0xFFF2F3F5);
    const Color divider = Color(0xFFD7D9DE);


    const double dividerW = 1.0; // 1 logical px
    final double leftW = _snap(context, (w - dividerW) / 2);
    final double rightW = w - dividerW - leftW;

    return SizedBox(
      width: w,
      height: h,
      child: Material(
        color: trackBg,
        borderRadius: BorderRadius.circular(r),
        child: Row(
          children: [
            _IconSide(onTap: onMinus, icon: Icons.remove, width: leftW, height: h),
            const SizedBox(width: dividerW, height: double.infinity, child: ColoredBox(color: divider)),
            _IconSide(onTap: onPlus, icon: Icons.add, width: rightW, height: h),
          ],
        ),
      ),
    );
  }
}

class _IconSide extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double width;
  final double height;

  const _IconSide({
    required this.onTap,
    required this.icon,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: icon == Icons.remove ? 'Уменьшить' : 'Увеличить',
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: SizedBox(
          width: width,
          height: height,
          child: Center(child: Icon(icon, size: 16.sp, color: AppColors.black)),
        ),
      ),
    );
  }
}
