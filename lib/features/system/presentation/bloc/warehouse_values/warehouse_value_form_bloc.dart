import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_value_usecases.dart';
import 'package:flowcash/core/enums/warehouse_value_type_enum.dart';

part 'warehouse_value_form_event.dart';
part 'warehouse_value_form_state.dart';

class WarehouseValueFormBloc
    extends Bloc<WarehouseValueFormEvent, WarehouseValueFormState> {
  final InsertWarehouseValueUseCase _insertUseCase;
  final UpdateWarehouseValueUseCase _updateUseCase;

  WarehouseValueFormBloc({
    WarehouseValueEntity? initialValue,
    required InsertWarehouseValueUseCase insertWarehouseValueUseCase,
    required UpdateWarehouseValueUseCase updateWarehouseValueUseCase,
  }) : _insertUseCase = insertWarehouseValueUseCase,
       _updateUseCase = updateWarehouseValueUseCase,
       super(WarehouseValueFormState.initial(initialValue)) {
    on<WarehouseValueFormWarehouseIdChanged>(_onWarehouseIdChanged);
    on<WarehouseValueFormTypeChanged>(_onValueTypeChanged);
    on<WarehouseValueFormValueChanged>(_onValueChanged);
    on<WarehouseValueFormSubmitted>(_onSubmitted);
  }

  void _onWarehouseIdChanged(
    WarehouseValueFormWarehouseIdChanged event,
    Emitter<WarehouseValueFormState> emit,
  ) {
    emit(
      state.copyWith(
        warehouseId: event.warehouseId,
        errorMessage: null,
        isSuccess: false,
      ),
    );
  }

  void _onValueTypeChanged(
    WarehouseValueFormTypeChanged event,
    Emitter<WarehouseValueFormState> emit,
  ) {
    emit(
      state.copyWith(
        valueType: event.valueType,
        valueText: '',
        errorMessage: null,
        isSuccess: false,
      ),
    );
  }

  void _onValueChanged(
    WarehouseValueFormValueChanged event,
    Emitter<WarehouseValueFormState> emit,
  ) {
    emit(
      state.copyWith(
        valueText: event.valueText,
        errorMessage: null,
        isSuccess: false,
      ),
    );
  }

  Future<void> _onSubmitted(
    WarehouseValueFormSubmitted event,
    Emitter<WarehouseValueFormState> emit,
  ) async {
    if (state.warehouseId <= 0) {
      emit(state.copyWith(errorMessage: 'الرجاء إدخال رقم مستودع صالح'));
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, errorMessage: null, isSuccess: false),
    );

    final rawValue = state.valueText.trim();
    final Object? parsedValue = rawValue.isEmpty
        ? null
        : int.tryParse(rawValue) ?? rawValue;
    final WarehouseValueEntity entity = state.isEditing
        ? state.initialValue!.copyWith(
            warehouseId: state.warehouseId,
            valueType: state.valueType,
            value: parsedValue,
          )
        : WarehouseValueEntity(
            id: 0,
            warehouseId: state.warehouseId,
            valueType: state.valueType,
            value: parsedValue,
          );

    final result = state.isEditing
        ? await _updateUseCase(entity)
        : await _insertUseCase(entity);

    result.match(
      (failure) => emit(
        state.copyWith(isSubmitting: false, errorMessage: failure.message),
      ),
      (savedEntity) => emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          savedEntity: savedEntity,
        ),
      ),
    );
  }
}
