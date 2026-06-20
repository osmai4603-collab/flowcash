import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flowcash/core/usecases/value_repository_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'defaults_state.dart';
part 'defaults_event.dart';

class DefaultsBloc extends Bloc<DefaultsEvent, DefaultsState> {
  final GetValuesUseCase _getValues;

  DefaultsBloc(this._getValues) : super(const DefaultsInitial()) {
    on<LoadDefaultsEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDefaultsEvent event,
    Emitter<DefaultsState> emit,
  ) async {
    emit(const DefaultsLoading());
    final result = await _getValues();
    result.fold(
      (failure) => emit(DefaultsFailure(failure.message)),
      (items) => emit(DefaultsSuccess(items)),
    );
  }
}
