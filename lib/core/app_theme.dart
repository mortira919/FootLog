// lib/core/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  AppColors._();
  static const Color labelGray30 = Color(0x4D3C3C43); // 30% от #3C3C43
  static const Color primary     = Color(0xFF34C759);
  static const Color primaryAlt  = Color(0xFF34A853);
  static const Color textGray    = Color(0xFF6C757D);
  static const Color black       = Color(0xFF000000);
  static const Color white       = Color(0xFFFFFFFF);

  static const Color fieldBg     = white;
  static const Color fieldBorder = Color(0x14000000);
  static const Color divider     = Color(0x1F000000);
  static const Color shadow      = Color(0x33000000);
  static const Color labelGray   = Color(0xFF3C3C43);
  static const Color labelGray60 = Color(0x993C3C43);

  static const Color panelBorder = Color(0xFFE5E7EB);
}

class AppDims {
  AppDims._();
  static double r12() => 12.r;
  static double r16() => 16.r;
  static double p16() => 16.w;
  static double h52() => 52.h;
}

class AppText {
  AppText._();
  static TextStyle h1 = TextStyle(
    fontSize: 34.sp, fontWeight: FontWeight.w700, color: AppColors.black,
  );
  static TextStyle body = TextStyle(
    fontSize: 15.sp, fontWeight: FontWeight.w400, color: AppColors.textGray,
  );
  static TextStyle link = TextStyle(
    fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.primary,
  );
  static TextStyle button = TextStyle(
    fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.white,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: const Color(0xFFF7F8FA),
    fontFamily: 'SF Pro Text', // можно убрать, если не подключал шрифт
  );

  return base.copyWith(
    textTheme: base.textTheme
        .apply(bodyColor: AppColors.black, displayColor: AppColors.black)
        .copyWith(
      titleLarge: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 15.sp, color: AppColors.textGray),
      labelMedium: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
    ),

    cardTheme: const CardThemeData(
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),

    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? AppColors.primary : const Color(0xFF6B7280),
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.black : const Color(0xFF6B7280),
        );
      }),
    ),

    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        side: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return BorderSide(
            color: selected ? AppColors.primary : AppColors.panelBorder,
          );
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return selected ? const Color(0xFFEFFAF3) : AppColors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return selected ? AppColors.black : AppColors.textGray;
        }),
        textStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
        iconColor: WidgetStateProperty.all(AppColors.primary),
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldBg,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDims.r12()),
        borderSide: const BorderSide(color: AppColors.fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDims.r12()),
        borderSide: const BorderSide(color: AppColors.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDims.r12()),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: AppColors.textGray, fontSize: 15.sp),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: Size(double.infinity, AppDims.h52()),
        textStyle: AppText.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, AppDims.h52()),
        side: BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        foregroundColor: AppColors.black,
        textStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
    ),

    dividerTheme: DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 24.h,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.black,
      centerTitle: true,
    ),
  );
}

/// Статусные цвета
class AppStatusColors {
  static const success = Color(0xFF22C55E);
  static const danger  = Color(0xFFEF4444);
}

/// Универсальная белая карточка с мягкой тенью (как в фигме)
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDims.r16()),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Белая панель с тонкой серой рамкой (без тени)
class AppPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppPanel({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDims.r16()),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
