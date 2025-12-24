import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Roboto';

  // Display styles
  static TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppDimensions.displayLarge,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppDimensions.displayMedium,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Headline styles
  static TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppDimensions.headlineLarge,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppDimensions.headlineMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Title styles
  static TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppDimensions.titleLarge,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body styles
  static TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppDimensions.bodyLarge,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppDimensions.bodyMedium,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppDimensions.bodySmall,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Label styles
  static TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppDimensions.labelLarge,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppDimensions.labelSmall,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
