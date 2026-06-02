import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/usecases/opening_quantity_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'opening_quantities_event.dart';
import 'opening_quantities_state.dart';

class OpeningQuantitiesBloc
    extends Bloc<OpeningQuantitiesEvent, OpeningQuantitiesState> {
  final GetOpeningQuantitysUseCase _getOpeningQuantities;
  final InsertOpeningQuantityUseCase _insertOpeningQuantity;
  final DeleteOpeningQuantityUseCase _deleteOpeningQuantity;
  final GetInventorysUseCase _getInventorys;
  final GetWarehousesUseCase _getWarehouses;

  OpeningQuantitiesBloc({
    required GetOpeningQuantitysUseCase getOpeningQuantities,
    required InsertOpeningQuantityUseCase insertOpeningQuantity,
    required DeleteOpeningQuantityUseCase deleteOpeningQuantity,
    required GetInventorysUseCase getInventorys,
    required GetWarehousesUseCase getWarehouses,
  }) : _getOpeningQuantities = getOpeningQuantities,
       _insertOpeningQuantity = insertOpeningQuantity,
       _deleteOpeningQuantity = deleteOpeningQuantity,
       _getInventorys = getInventorys,
       _getWarehouses = getWarehouses,
       super(const OpeningQuantitiesState()) {
    on<LoadOpeningQuantitiesEvent>(_onLoad);
    on<AddOpeningQuantityEvent>(_onAdd);
    on<DeleteOpeningQuantityEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadOpeningQuantitiesEvent event,
    Emitter<OpeningQuantitiesState> emit,
  ) async {
    emit(state.toLoading());

    final oRes = await _getOpeningQuantities();
    final iRes = await _getInventorys();
    final wRes = await _getWarehouses();

    oRes.fold((f) => emit(state.toError(f.message)), (items) {
      iRes.fold((f) => emit(state.toError(f.message)), (invItems) {
        wRes.fold((f) => emit(state.toError(f.message)), (warehousesList) {
          emit(
            state.copyWith(
              status: OpeningQuantitiesStatus.success,
              items: items,
              inventoryItems: invItems,
              warehouses: warehousesList,
            ),
          );
        });
      });
    });
  }

  Future<void> _onAdd(
    AddOpeningQuantityEvent event,
    Emitter<OpeningQuantitiesState> emit,
  ) async {
    final result = await _insertOpeningQuantity(event.entity);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (newItem) => emit(state.addItem(newItem)),
    );
  }

  Future<void> _onDelete(
    DeleteOpeningQuantityEvent event,
    Emitter<OpeningQuantitiesState> emit,
  ) async {
    final result = await _deleteOpeningQuantity(event.id);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (_) => emit(state.removeItem(event.id)),
    );
  }
}
