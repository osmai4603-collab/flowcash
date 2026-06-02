import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/values/get_all_values.dart';
import '../../../domain/usecases/values/get_company_info.dart';
import '../../../domain/usecases/values/update_value.dart';
import '../../../domain/usecases/counters/get_counter.dart';
import '../../../domain/usecases/counters/increment_counter.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetAllValues _getAllValues;
  final UpdateValue _updateValue;
  final GetCompanyInfo _getCompanyInfo;
  final GetCounter _getCounter;
  final IncrementCounter _incrementCounter;

  SettingsBloc({
    required GetAllValues getAllValues,
    required UpdateValue updateValue,
    required GetCompanyInfo getCompanyInfo,
    required GetCounter getCounter,
    required IncrementCounter incrementCounter,
  })  : _getAllValues = getAllValues,
        _updateValue = updateValue,
        _getCompanyInfo = getCompanyInfo,
        _getCounter = getCounter,
        _incrementCounter = incrementCounter,
        super(SettingsState.initial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<LoadCompanyInfoEvent>(_onLoadCompanyInfo);
    on<UpdateSettingEvent>(_onUpdateSetting);
    on<LoadCounterEvent>(_onLoadCounter);
    on<IncrementCounterEvent>(_onIncrementCounter);
  }

  Future<void> _onLoadSettings(LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: null));
    final result = await _getAllValues();
    result.fold(
      (failure) => emit(state.copyWith(status: SettingsStatus.failure, errorMessage: failure.message)),
      (values) => emit(state.copyWith(status: SettingsStatus.success, values: values)),
    );
  }

  Future<void> _onLoadCompanyInfo(LoadCompanyInfoEvent event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: null));
    final result = await _getCompanyInfo();
    result.fold(
      (failure) => emit(state.copyWith(status: SettingsStatus.failure, errorMessage: failure.message)),
      (companyInfo) => emit(state.copyWith(status: SettingsStatus.success, companyInfo: companyInfo)),
    );
  }

  Future<void> _onUpdateSetting(UpdateSettingEvent event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: null));
    final result = await _updateValue(event.value);
    result.fold(
      (failure) => emit(state.copyWith(status: SettingsStatus.failure, errorMessage: failure.message)),
      (success) {
        final updatedValues = state.values.map((item) {
          return item.id == event.value.id ? event.value : item;
        }).toList();
        emit(state.copyWith(status: SettingsStatus.success, values: updatedValues));
      },
    );
  }

  Future<void> _onLoadCounter(LoadCounterEvent event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: null));
    final result = await _getCounter(event.counterType);
    result.fold(
      (failure) => emit(state.copyWith(status: SettingsStatus.failure, errorMessage: failure.message)),
      (counter) => emit(state.copyWith(status: SettingsStatus.success, counter: counter)),
    );
  }

  Future<void> _onIncrementCounter(IncrementCounterEvent event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: null));
    final result = await _incrementCounter(event.counterType);
    result.fold(
      (failure) => emit(state.copyWith(status: SettingsStatus.failure, errorMessage: failure.message)),
      (updatedCount) => emit(state.copyWith(status: SettingsStatus.success, currentCounter: updatedCount)),
    );
  }
}
