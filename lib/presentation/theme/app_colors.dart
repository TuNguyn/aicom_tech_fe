import 'package:flutter/material.dart';
import 'app_colors/base_color_scheme.dart';
import 'app_colors/color_scheme_registry.dart';

class AppColors {
  AppColors._();

  static BaseColorScheme _currentScheme =
      ColorSchemeRegistry.getScheme('nature_harmony');

  static void updateScheme(BaseColorScheme scheme) {
    _currentScheme = scheme;
  }

  static BaseColorScheme get currentScheme => _currentScheme;

  // Color accessors
  static Color get primary => _currentScheme.primary;
  static Color get secondary => _currentScheme.secondary;
  static Color get accent => _currentScheme.accent;
  static Color get background => _currentScheme.background;
  static Color get surface => _currentScheme.surface;
  static Color get cardBackground => _currentScheme.cardBackground;
  static Color get success => _currentScheme.success;
  static Color get error => _currentScheme.error;
  static Color get warning => _currentScheme.warning;
  static Color get info => _currentScheme.info;
  static Color get textPrimary => _currentScheme.textPrimary;
  static Color get textSecondary => _currentScheme.textSecondary;
  static Color get textHint => _currentScheme.textHint;
  static Color get divider => _currentScheme.divider;
  static Color get hoverColor => _currentScheme.hoverColor;

  // Gradient accessors
  static LinearGradient get mainBackgroundGradient =>
      _currentScheme.mainBackgroundGradient;
  static LinearGradient get headerGradient => _currentScheme.headerGradient;
}
