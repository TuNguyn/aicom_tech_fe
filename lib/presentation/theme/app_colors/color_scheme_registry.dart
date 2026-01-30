import 'base_color_scheme.dart';
import 'nature_harmony_color_scheme.dart';

class ColorSchemeRegistry {
  ColorSchemeRegistry._();

  static final Map<String, BaseColorScheme> _schemes = {
    'default': NatureHarmonyColorScheme(),
    'nature_harmony': NatureHarmonyColorScheme(),
  };

  static BaseColorScheme getScheme(String key) {
    return _schemes[key] ?? _schemes['default']!;
  }

  static List<BaseColorScheme> getAllSchemes() {
    return _schemes.values.toList();
  }

  static List<String> getAllSchemeKeys() {
    return _schemes.keys.toList();
  }

  static String getDefaultSchemeKey() => 'nature_harmony';
}
