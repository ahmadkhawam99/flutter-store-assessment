import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppColors {
  static const primary = Color(0xFF146CFF);
  static const primaryDark = Color(0xFF0647C8);
  static const cyan = Color(0xFF13B8EE);
  static const background = Colors.white;
  static const text = Color(0xFF102044);
  static const secondaryText = Color(0xFF68738A);
  static const fieldFill = Color(0xFFF4F7FC);
  static const border = Color(0xFFDCE5F2);
  static const error = Color(0xFFD92D20);
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.cyan,
      surface: AppColors.background,
      onSurface: AppColors.text,
      error: AppColors.error,
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.text,
        fontSize: 30.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      titleLarge: TextStyle(
        color: AppColors.text,
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: AppColors.secondaryText,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.text,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: TextStyle(
        color: AppColors.secondaryText,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size.fromHeight(54.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

extension ThemeContext on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
