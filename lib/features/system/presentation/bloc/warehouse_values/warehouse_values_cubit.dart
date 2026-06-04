import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_value_usecases.dart';

part 'warehouse_values_state.dart';
part 'warehouse_values_event.dart';

class WarehouseValuesBloc extends Bloc<WarehouseValuesEvent, WarehouseValuesState> {
  final GetWarehouseValuesUseCase _getWarehouseValues;

  WarehouseValuesBloc(this._getWarehouseValues) : super(const WarehouseValuesInitial()) {
    on<LoadWarehouseValuesEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadWarehouseValuesEvent event, Emitter<WarehouseValuesState> emit) async {
    emit(const WarehouseValuesLoading());
    final result = await _getWarehouseValues();
    result.fold(
      (failure) => emit(WarehouseValuesFailure(failure.message)),
      (items) => emit(WarehouseValuesSuccess(items)),
    );
  }
}
