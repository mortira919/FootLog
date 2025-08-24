import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_theme.dart';

/// Белая карточка секции (радиус 16, мягкая тень), заголовок по центру.
class MatchSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const MatchSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,              // как в фигме
                fontWeight: FontWeight.w700,  // Semibold/700
                color: AppColors.black,
                height: 1.05,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

/// Зелёная «пилюля» (фон светло-зелёный, текст — primary).
class GreenPillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const GreenPillButton({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEFFAF3),
      borderRadius: BorderRadius.circular(1000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(1000),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 40.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Center(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.link.copyWith(fontSize: 16.sp, height: 1.1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
