import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../theme/app_colors/base_color_scheme.dart';
import '../theme/app_colors/color_scheme_registry.dart';

class ThemeNotifier extends StateNotifier<BaseColorScheme> {
  ThemeNotifier()
      : super(
          ColorSchemeRegistry.getScheme(
            ColorSchemeRegistry.getDefaultSchemeKey(),
          ),
        ) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      // Check if box is open before accessing
      if (!Hive.isBoxOpen(AppConstants.settingsBoxName)) {
        return;
      }

      final box = Hive.box<dynamic>(AppConstants.settingsBoxName);
      final themeKey = box.get(AppConstants.themeKey) as String?;

      if (themeKey != null) {
        final scheme = ColorSchemeRegistry.getScheme(themeKey);
        state = scheme;
      }
    } catch (e) {
      // Ignore error and use default theme
    }
  }

  Future<void> setTheme(BaseColorScheme scheme) async {
    final box = Hive.box<dynamic>(AppConstants.settingsBoxName);

    // Find key for this scheme
    String? schemeKey;
    final allKeys = ColorSchemeRegistry.getAllSchemeKeys();
    for (final key in allKeys) {
      if (ColorSchemeRegistry.getScheme(key).name == scheme.name) {
        schemeKey = key;
        break;
      }
    }

    if (schemeKey != null) {
      await box.put(AppConstants.themeKey, schemeKey);
      state = scheme;
    }
  }
}

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, BaseColorScheme>((ref) {
  return ThemeNotifier();
});
