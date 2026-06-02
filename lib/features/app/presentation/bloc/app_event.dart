import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AppEvent {}

class ThemeChanged extends AppEvent {
  final ThemeMode themeMode;

  const ThemeChanged({required this.themeMode});

  @override
  List<Object> get props => [themeMode];
}

class LocaleChanged extends AppEvent {
  final Locale locale;

  const LocaleChanged({required this.locale});

  @override
  List<Object> get props => [locale];
}
