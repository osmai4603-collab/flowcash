import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/app_entity.dart';

enum AppStatus { initial, loading, success, failure }

class AppState extends Equatable {
  final AppStatus status;
  final AppEntity appData;
  final int themeVersion;
  final String? errorMessage;

  const AppState({
    this.status = AppStatus.initial,
    this.appData = const AppEntity(
      themeMode: ThemeMode.system,
      locale: Locale('ar', 'YE'),
    ),
    this.themeVersion = 0,
    this.errorMessage,
  });

  AppState copyWith({
    AppStatus? status,
    AppEntity? appData,
    int? themeVersion,
    String? errorMessage,
  }) {
    return AppState(
      status: status ?? this.status,
      appData: appData ?? this.appData,
      themeVersion: themeVersion ?? this.themeVersion,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, appData, themeVersion, errorMessage];
}
