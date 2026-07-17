import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';

abstract final class AppTypography {
  static const String? fontFamily = null;

  static const TextStyle splashBrand = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 8,
    color: AppColors.splashBrand,
  );

  static const TextTheme textTheme = TextTheme(
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
  );
}
