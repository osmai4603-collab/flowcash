import 'package:flutter/material.dart';
import '../../domain/entities/app_entity.dart';

final class AppModel extends AppEntity {
  const AppModel({required super.themeMode, required super.locale});

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      themeMode: _parseThemeMode(json['themeMode'] as String?),
      locale: _parseLocale(json['locale'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    final localeValue = locale.countryCode != null && locale.countryCode!.isNotEmpty
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;

    return {'themeMode': themeMode.name, 'locale': localeValue};
  }

  @override
  AppModel copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppModel(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  static ThemeMode _parseThemeMode(String? themeStr) {
    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static Locale _parseLocale(String? localeStr) {
    if (localeStr != null && localeStr.isNotEmpty) {
      final parts = localeStr.split('_');
      if (parts.length == 2) {
        return Locale(parts[0], parts[1]);
      }
      switch (parts[0]) {
        case 'ar':
          return const Locale('ar', 'YE');
        case 'en':
          return const Locale('en', 'US');
        default:
          return Locale(parts[0]);
      }
    }
    return const Locale('ar', 'YE'); // Default locale
  }
}
