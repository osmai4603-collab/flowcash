import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/main_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'inventory_catalog_event.dart';
import 'inventory_catalog_state.dart';

class InventoryCatalogBloc
    extends Bloc<InventoryCatalogEvent, InventoryCatalogState> {
  final GetInventorysUseCase _getInventorys;
  final InsertInventoryUseCase _insertInventory;
  final UpdateInventoryUseCase _updateInventory;
  final DeleteInventoryUseCase _deleteInventory;

  InventoryCatalogBloc({
    required GetInventorysUseCase getInventorys,
    required InsertInventoryUseCase insertInventory,
    required UpdateInventoryUseCase updateInventory,
    required DeleteInventoryUseCase deleteInventory,
    required GetMainAccountsUseCase getMainAccounts,
    required GetSubAccountsUseCase getSubAccounts,
  }) : _getInventorys = getInventorys,
       _insertInventory = insertInventory,
       _updateInventory = updateInventory,
       _deleteInventory = deleteInventory,
       super(const InventoryCatalogState()) {
    on<LoadInventoryCatalogEvent>(_onLoadCatalog);
    on<AddInventoryItemEvent>(_onAddItem);
    on<UpdateInventoryItemEvent>(_onUpdateItem);
    on<DeleteInventoryItemEvent>(_onDeleteItem);
  }

  Future<void> _onLoadCatalog(
    LoadInventoryCatalogEvent event,
    Emitter<InventoryCatalogState> emit,
  ) async {
    emit(state.toLoading());

    final inventoriesResult = await _getInventorys();

    inventoriesResult.fold((f) => emit(state.toError(f.message)), (items) {
      emit(
        state.copyWith(
          status: CatalogStatus.success,
          items: items,
        ),
      );
    });
  }

  Future<void> _onAddItem(
    AddInventoryItemEvent event,
    Emitter<InventoryCatalogState> emit,
  ) async {
    final result = await _insertInventory(event.item);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (newItem) => emit(state.addItem(newItem)),
    );
  }

  Future<void> _onUpdateItem(
    UpdateInventoryItemEvent event,
    Emitter<InventoryCatalogState> emit,
  ) async {
    final result = await _updateInventory(event.item);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (updatedItem) => emit(state.updateItem(updatedItem)),
    );
  }

  Future<void> _onDeleteItem(
    DeleteInventoryItemEvent event,
    Emitter<InventoryCatalogState> emit,
  ) async {
    final result = await _deleteInventory(event.id);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (_) => emit(state.removeItem(event.id)),
    );
  }
}
