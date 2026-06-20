import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_value_entity.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final List<AppValueEntity> values;
  final List<AppValueEntity> companyInfo;
  final ValueCounterEntity? counter;
  final int? currentCounter;
  final String? errorMessage;
  final SettingsStatus backupStatus;
  final SettingsStatus restoreStatus;
  final String? databaseErrorMessage;

  const SettingsState({
    required this.status,
    required this.values,
    required this.companyInfo,
    this.counter,
    this.currentCounter,
    this.errorMessage,
    required this.backupStatus,
    required this.restoreStatus,
    this.databaseErrorMessage,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      status: SettingsStatus.initial,
      values: [],
      companyInfo: [],
      counter: null,
      currentCounter: null,
      errorMessage: null,
      backupStatus: SettingsStatus.initial,
      restoreStatus: SettingsStatus.initial,
      databaseErrorMessage: null,
    );
  }

  SettingsState copyWith({
    SettingsStatus? status,
    List<AppValueEntity>? values,
    List<AppValueEntity>? companyInfo,
    ValueCounterEntity? counter,
    int? currentCounter,
    String? errorMessage,
    SettingsStatus? backupStatus,
    SettingsStatus? restoreStatus,
    String? databaseErrorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      values: values ?? this.values,
      companyInfo: companyInfo ?? this.companyInfo,
      counter: counter ?? this.counter,
      currentCounter: currentCounter ?? this.currentCounter,
      errorMessage: errorMessage,
      backupStatus: backupStatus ?? this.backupStatus,
      restoreStatus: restoreStatus ?? this.restoreStatus,
      databaseErrorMessage: databaseErrorMessage ?? this.databaseErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        values,
        companyInfo,
        counter,
        currentCounter,
        errorMessage,
        backupStatus,
        restoreStatus,
        databaseErrorMessage,
      ];
}
