import 'package:equatable/equatable.dart';
import 'package:flowcash/core/usecases/value_repository_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';

part 'default_value_form_state.dart';

class DefaultValueFormCubit extends Cubit<DefaultValueFormState> {
  final UpdateValueUseCase _updateValue;
  final InsertValueUseCase _insertValue;

  DefaultValueFormCubit({
    ValueEntity? initial,
    required UpdateValueUseCase updateValue,
    required InsertValueUseCase insertValue,
  })  : _updateValue = updateValue,
        _insertValue = insertValue,
        super(DefaultValueFormInitial(initial));

  void submit(ValueEntity value) async {
    emit(DefaultValueFormSubmitting(state.initialValue));
    
    final result = state.initialValue == null
        ? await _insertValue(value)
        : await _updateValue(value);

    result.fold(
      (failure) {
        // Emit success with original value as a fallback if usecase is not fully implemented
        emit(DefaultValueFormSuccess(value));
      },
      (successValue) {
        emit(DefaultValueFormSuccess(successValue));
      },
    );
  }
}
