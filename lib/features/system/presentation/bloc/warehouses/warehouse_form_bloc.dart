import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/core/enums/warehouse_type_enum.dart';
import 'package:equatable/equatable.dart';

part 'warehouse_form_event.dart';
part 'warehouse_form_state.dart';

class WarehouseFormBloc extends Bloc<WarehouseFormEvent, WarehouseFormState> {
  final InsertWarehouseUseCase _insertWarehouseUseCase;
  final UpdateWarehouseUseCase _updateWarehouseUseCase;
  final bool _isEdit;

  WarehouseFormBloc({
    required WarehouseEntity? initialValue,
    required InsertWarehouseUseCase insertWarehouseUseCase,
    required UpdateWarehouseUseCase updateWarehouseUseCase,
  })  : _insertWarehouseUseCase = insertWarehouseUseCase,
        _updateWarehouseUseCase = updateWarehouseUseCase,
        _isEdit = initialValue != null,
        super(WarehouseFormState.initial(initialValue)) {
    on<WarehouseFormNameChanged>(_onNameChanged);
    on<WarehouseFormLocationChanged>(_onLocationChanged);
    on<WarehouseFormTypeChanged>(_onTypeChanged);
    on<WarehouseFormParentIdChanged>(_onParentIdChanged);
    on<WarehouseFormSubmitted>(_onSubmitted);
  }

  void _onNameChanged(WarehouseFormNameChanged event, Emitter<WarehouseFormState> emit) {
    emit(state.copyWith(warehouse: state.warehouse.copyWith(warehouseName: event.name), errorMessage: null));
  }

  void _onLocationChanged(WarehouseFormLocationChanged event, Emitter<WarehouseFormState> emit) {
    emit(state.copyWith(warehouse: state.warehouse.copyWith(location: event.location), errorMessage: null));
  }

  void _onTypeChanged(WarehouseFormTypeChanged event, Emitter<WarehouseFormState> emit) {
    emit(state.copyWith(warehouse: state.warehouse.copyWith(warehouseType: event.warehouseType), errorMessage: null));
  }

  void _onParentIdChanged(WarehouseFormParentIdChanged event, Emitter<WarehouseFormState> emit) {
    emit(state.copyWith(warehouse: state.warehouse.copyWith(parentId: event.parentId), errorMessage: null));
  }

  Future<void> _onSubmitted(WarehouseFormSubmitted event, Emitter<WarehouseFormState> emit) async {
    final warehouse = state.warehouse;
    if (warehouse.warehouseName.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'الرجاء إدخال اسم المستودع'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final entityToSave = warehouse.copyWith(
      warehouseName: warehouse.warehouseName.trim(),
      location: warehouse.location.trim(),
    );

    final result = _isEdit
        ? await _updateWarehouseUseCase(entityToSave)
        : await _insertWarehouseUseCase(entityToSave);

    result.match(
      (failure) => emit(state.copyWith(isSubmitting: false, errorMessage: failure.message)),
      (saved) => emit(state.copyWith(isSubmitting: false, isSuccess: true, savedEntity: saved)),
    );
  }
}
