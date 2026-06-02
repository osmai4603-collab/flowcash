import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppEntity extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;

  const AppEntity({required this.themeMode, required this.locale});

  @override
  List<Object?> get props => [themeMode, locale];

  AppEntity copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppEntity(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
