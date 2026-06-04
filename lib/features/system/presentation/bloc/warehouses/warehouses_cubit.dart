import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';

part 'warehouses_state.dart';
part 'warehouses_event.dart';

class WarehousesBloc extends Bloc<WarehousesEvent, WarehousesState> {
  final GetWarehousesUseCase _getWarehouses;

  WarehousesBloc(this._getWarehouses) : super(const WarehousesInitial()) {
    on<LoadWarehousesEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadWarehousesEvent event, Emitter<WarehousesState> emit) async {
    emit(const WarehousesLoading());
    final result = await _getWarehouses();
    result.fold(
      (failure) => emit(WarehousesFailure(failure.message)),
      (warehouses) => emit(WarehousesSuccess(warehouses)),
    );
  }
}
