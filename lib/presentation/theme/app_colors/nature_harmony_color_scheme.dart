import 'package:flutter/material.dart';
import 'base_color_scheme.dart';

class NatureHarmonyColorScheme extends BaseColorScheme {
  @override
  String get name => 'Nature Harmony';

  @override
  String get description => 'Harmonious blend of soft lavender and green';

  @override
  IconData get icon => Icons.eco;

  @override
  Color get primary => const Color(0xFF7D8EE1);

  @override
  Color get secondary => const Color(0xFF58C28A);

  @override
  Color get accent => const Color(0xFFE1C07D);

  @override
  Color get background => const Color(0xFFF5F5F5);

  @override
  Color get surface => Colors.white;

  @override
  Color get cardBackground => Colors.white;

  @override
  LinearGradient get mainBackgroundGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF7D8EE1),
          Color(0xFFE8E7E0),
          Color(0xFF94E4B8),
        ],
      );

  @override
  LinearGradient get headerGradient => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          primary,
          secondary,
        ],
      );
}
