import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../domain/entities/app_entity.dart';
import '../../domain/usecases/get_app_data.dart';
import '../../domain/usecases/save_app_data.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final GetAppData getAppData;
  final SaveAppData saveAppData;

  AppBloc({required this.getAppData, required this.saveAppData})
    : super(const AppState()) {
    on<AppStarted>(_onAppStarted);
    on<ThemeChanged>(_onThemeChanged);
    on<LocaleChanged>(_onLocaleChanged);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));

    await ColorSchemes.loadColors();

    final result = await getAppData();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (appData) =>
          emit(state.copyWith(status: AppStatus.success, appData: appData)),
    );
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<AppState> emit,
  ) async {
    final newAppData = AppEntity(
      themeMode: event.themeMode,
      locale: state.appData.locale,
    );
    final result = await saveAppData(newAppData);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: AppStatus.success,
          appData: newAppData,
          themeVersion: state.themeVersion + 1,
        ),
      ),
    );
  }

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<AppState> emit,
  ) async {
    final newAppData = AppEntity(
      themeMode: state.appData.themeMode,
      locale: event.locale,
    );
    final result = await saveAppData(newAppData);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AppStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) =>
          emit(state.copyWith(status: AppStatus.success, appData: newAppData)),
    );
  }
}
