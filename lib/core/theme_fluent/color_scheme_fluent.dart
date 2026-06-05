import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ColorSchemesFluent {
  const ColorSchemesFluent._();

  static Color _lightPrimaryColor = material.Colors.green.shade900;
  static Color _lightSecondaryColor = material.Colors.green.shade100;
  static Color _lightTertiaryColor = material.Colors.green.shade50;

  static Color _darkPrimaryColor = material.Colors.green.shade900;
  static Color _darkSecondaryColor = material.Colors.green.shade100;
  static Color _darkTertiaryColor = material.Colors.green.shade50;

  static Color get primaryColor => _lightPrimaryColor;
  static Color get secondaryColor => _lightSecondaryColor;
  static Color get tertiaryColor => _lightTertiaryColor;

  static Color get lightPrimaryColor => _lightPrimaryColor;
  static Color get lightSecondaryColor => _lightSecondaryColor;
  static Color get lightTertiaryColor => _lightTertiaryColor;

  static Color get darkPrimaryColor => _darkPrimaryColor;
  static Color get darkSecondaryColor => _darkSecondaryColor;
  static Color get darkTertiaryColor => _darkTertiaryColor;

  static AccentColor get lightAccent => createAccentColor(_lightPrimaryColor);
  static AccentColor get darkAccent => createAccentColor(_darkPrimaryColor);

  static AccentColor createAccentColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    
    Color adjust(double sMod, double vMod) {
      return hsv
          .withSaturation((hsv.saturation * sMod).clamp(0.0, 1.0))
          .withValue((hsv.value * vMod).clamp(0.0, 1.0))
          .toColor();
    }

    return AccentColor.swatch({
      'darkest': adjust(1.1, 0.4),
      'darker': adjust(1.1, 0.6),
      'dark': adjust(1.05, 0.8),
      'normal': color,
      'light': adjust(0.9, 1.15),
      'lighter': adjust(0.8, 1.3),
      'lightest': adjust(0.7, 1.4),
    });
  }

  static Future<void> setLightPrimaryColor([Color? color]) async {
    color ??= await getLightPrimaryColor();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('Light Primary Color', (color).toHexString());
    _lightPrimaryColor = color;
  }

  static Future<Color> getLightPrimaryColor() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final result = pref.getString('Light Primary Color')?.toColor();
    return result ?? material.Colors.green.shade900;
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
    return result ?? material.Colors.green.shade100;
  }

  static Future<void> loadLightSecondaryColor() async {
    _lightSecondaryColor = await getLightSecondaryColor();
  }

  static Future<void> setLightTertiaryColor([Color? color]) async {
    color ??= await getLightTertiaryColor();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('Light Tertiary Color', (color).toHexString());
    _lightSecondaryColor = color; 
    _lightTertiaryColor = color;
  }

  static Future<Color> getLightTertiaryColor() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final result = pref.getString('Light Tertiary Color')?.toColor();
    return result ?? material.Colors.green.shade50;
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
    return result ?? material.Colors.green.shade900;
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
    return result ?? material.Colors.green.shade100;
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
    return result ?? material.Colors.green.shade50;
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
}
