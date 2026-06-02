import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ColorSchemes {
  const ColorSchemes._();

  static Color _lightPrimaryColor = Colors.green.shade900;
  static Color _lightSecondaryColor = Colors.green.shade100;
  static Color _lightTertiaryColor = Colors.green.shade50;

  static Color _darkPrimaryColor = Colors.green.shade900;
  static Color _darkSecondaryColor = Colors.green.shade100;
  static Color _darkTertiaryColor = Colors.green.shade50;

  static Color get primaryColor => _lightPrimaryColor;
  static Color get secondaryColor => _lightSecondaryColor;
  static Color get tertiaryColor => _lightTertiaryColor;

  static Color get lightPrimaryColor => _lightPrimaryColor;
  static Color get lightSecondaryColor => _lightSecondaryColor;
  static Color get lightTertiaryColor => _lightTertiaryColor;

  static Color get darkPrimaryColor => _darkPrimaryColor;
  static Color get darkSecondaryColor => _darkSecondaryColor;
  static Color get darkTertiaryColor => _darkTertiaryColor;

  static Future<void> setLightPrimaryColor([Color? color]) async {
    color ??= await getLightPrimaryColor();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('Light Primary Color', (color).toHexString());
    _lightPrimaryColor = color;
  }

  static Future<Color> getLightPrimaryColor() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final result = pref.getString('Light Primary Color')?.toColor();
    return result ?? Colors.green.shade900;
  }

  static Future<void> loadLightPrimaryColor() async {
    _lightPrimaryColor = await getLightPrimaryColor();
  }

  static Future<void> setLightSecondaryColor([Color? color]) async {
    color ??= await getLightSecondaryColor();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('Light Secondary Color', (color).toHexString());
    _lightSecondaryColor = color;
  }

  static Future<Color> getLightSecondaryColor() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final result = pref.getString('Light Secondary Color')?.toColor();
    return result ?? Colors.green.shade100;
  }

  static Future<void> loadLightSecondaryColor() async {
    _lightSecondaryColor = await getLightSecondaryColor();
  }

  static Future<void> setLightTertiaryColor([Color? color]) async {
    color ??= await getLightTertiaryColor();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('Light Tertiary Color', (color).toHexString());
    _lightTertiaryColor = color;
  }

  static Future<Color> getLightTertiaryColor() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final result = pref.getString('Light Tertiary Color')?.toColor();
    return result ?? Colors.green.shade50;
  }

  static Future<void> loadLightTertiaryColor() async {
    _lightTertiaryColor = await getLightTertiaryColor();
  }

  static Future<void> setDarkPrimaryColor([Color? color]) async {
    color ??= await getDarkPrimaryColor();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('Dark Primary Color', (color).toHexString());
    _darkPrimaryColor = color;
  }

  static Future<Color> getDarkPrimaryColor() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final result = pref.getString('Dark Primary Color')?.toColor();
    return result ?? Colors.green.shade900;
  }

  static Future<void> loadDarkPrimaryColor() async {
    _darkPrimaryColor = await getDarkPrimaryColor();
  }

  static Future<void> setDarkSecondaryColor([Color? color]) async {
    color ??= await getDarkSecondaryColor();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('Dark Secondary Color', (color).toHexString());
    _darkSecondaryColor = color;
  }

  static Future<Color> getDarkSecondaryColor() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final result = pref.getString('Dark Secondary Color')?.toColor();
    return result ?? Colors.green.shade100;
  }

  static Future<void> loadDarkSecondaryColor() async {
    _darkSecondaryColor = await getDarkSecondaryColor();
  }

  static Future<void> setDarkTertiaryColor([Color? color]) async {
    color ??= await getDarkTertiaryColor();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('Dark Tertiary Color', (color).toHexString());
    _darkTertiaryColor = color;
  }

  static Future<Color> getDarkTertiaryColor() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final result = pref.getString('Dark Tertiary Color')?.toColor();
    return result ?? Colors.green.shade50;
  }

  static Future<void> loadDarkTertiaryColor() async {
    _darkTertiaryColor = await getDarkTertiaryColor();
  }

  static Future<void> loadColors() async {
    await loadLightPrimaryColor();
    await loadLightSecondaryColor();
    await loadLightTertiaryColor();
    await loadDarkPrimaryColor();
    await loadDarkSecondaryColor();
    await loadDarkTertiaryColor();
  }

  static ColorScheme get light => ColorScheme.light(
    primary: _lightPrimaryColor,
    onPrimary: Colors.white,
    secondary: _lightSecondaryColor,
    tertiary: _lightTertiaryColor,
    primaryContainer: _lightPrimaryColor.withValues(alpha: 0.12),
    onPrimaryContainer: _lightPrimaryColor,
    secondaryContainer: _lightSecondaryColor.withValues(alpha: 0.2),
    onSecondaryContainer: _lightPrimaryColor,
    tertiaryContainer: _lightTertiaryColor.withValues(alpha: 0.2),
    onTertiaryContainer: _lightPrimaryColor,
    surface: const Color(0xFFF5F5F5),
    onSurface: const Color(0xFF1E1E1E),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF7F7F7),
    surfaceContainer: const Color(0xFFF0F0F0),
    surfaceContainerHigh: const Color(0xFFE8E8E8),
    surfaceContainerHighest: const Color(0xFFDADADA),
    outline: const Color(0xFFB0B0B0),
    outlineVariant: const Color(0xFFCFD0D1),
    shadow: const Color(0x33000000),
    scrim: const Color(0x66000000),
    onSurfaceVariant: const Color(0xFF5F6368),
  );

  static ColorScheme get dark => ColorScheme.dark(
    surface: const Color(0xFF1C1C1C),
    onSurface: const Color(0xFFECECEC),
    primary: _darkPrimaryColor,
    onPrimary: Colors.white,
    secondary: _darkSecondaryColor,
    tertiary: _darkTertiaryColor,
    primaryContainer: _darkPrimaryColor.withValues(alpha: 0.24),
    onPrimaryContainer: Colors.white,
    secondaryContainer: _darkSecondaryColor.withValues(alpha: 0.24),
    onSecondaryContainer: Colors.white,
    tertiaryContainer: _darkTertiaryColor.withValues(alpha: 0.24),
    onTertiaryContainer: Colors.white,
    surfaceContainerLowest: const Color(0xFF0F0F0F),
    surfaceContainerLow: const Color(0xFF181818),
    surfaceContainer: const Color(0xFF242424),
    surfaceContainerHigh: const Color(0xFF2E2E2E),
    surfaceContainerHighest: const Color(0xFF393939),
    outline: const Color(0xFF6E6E6E),
    outlineVariant: const Color(0xFF4A4A4A),
    shadow: const Color(0x8A000000),
    scrim: const Color(0xCC000000),
    onSurfaceVariant: const Color(0xFFB0B0B0),
  );

  static ColorScheme of(BuildContext context) {
    return Theme.of(context).colorScheme;
  }
}
