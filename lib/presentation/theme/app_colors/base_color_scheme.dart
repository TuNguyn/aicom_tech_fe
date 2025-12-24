import 'package:flutter/material.dart';

abstract class BaseColorScheme {
  // Core theme colors
  Color get primary;
  Color get secondary;
  Color get accent;

  // Background colors
  Color get background;
  Color get surface;
  Color get cardBackground;

  // Status colors
  Color get success => const Color(0xFF4CAF50);
  Color get error => const Color(0xFFF44336);
  Color get warning => const Color(0xFFFF9800);
  Color get info => const Color(0xFF2196F3);

  // Text colors (auto-calculated for contrast)
  Color get textPrimary => _getContrastingTextColor(surface);
  Color get textSecondary => _getContrastingTextColor(surface).withValues(alpha: 0.7);
  Color get textHint => _getContrastingTextColor(surface).withValues(alpha: 0.5);

  // Interactive colors
  Color get divider => Colors.grey.withValues(alpha: 0.2);
  Color get hoverColor => Colors.black.withValues(alpha: 0.04);

  // Gradients
  LinearGradient get mainBackgroundGradient;
  LinearGradient get headerGradient;

  // Metadata
  String get name;
  String get description;
  IconData get icon;

  // Helper method for contrast calculation
  Color _getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
