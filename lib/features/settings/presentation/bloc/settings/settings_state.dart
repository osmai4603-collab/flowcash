import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_value_entity.dart';
import '../../../domain/entities/value_counter_entity.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final List<AppValueEntity> values;
  final List<AppValueEntity> companyInfo;
  final ValueCounterEntity? counter;
  final int? currentCounter;
  final String? errorMessage;

  const SettingsState({
    required this.status,
    required this.values,
    required this.companyInfo,
    this.counter,
    this.currentCounter,
    this.errorMessage,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      status: SettingsStatus.initial,
      values: [],
      companyInfo: [],
      counter: null,
      currentCounter: null,
      errorMessage: null,
    );
  }

  SettingsState copyWith({
    SettingsStatus? status,
    List<AppValueEntity>? values,
    List<AppValueEntity>? companyInfo,
    ValueCounterEntity? counter,
    int? currentCounter,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      values: values ?? this.values,
      companyInfo: companyInfo ?? this.companyInfo,
      counter: counter ?? this.counter,
      currentCounter: currentCounter ?? this.currentCounter,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, values, companyInfo, counter, currentCounter, errorMessage];
}
