import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
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
    on<AddMultipleInventoryItemsEvent>(_onAddMultipleItems);
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
      emit(state.copyWith(status: CatalogStatus.success, items: items));
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

  Future<void> _onAddMultipleItems(
    AddMultipleInventoryItemsEvent event,
    Emitter<InventoryCatalogState> emit,
  ) async {
    emit(state.toLoading());
    List<InventoryEntity> newItems = List.from(state.items);
    String? error;
    for (final item in event.items) {
      final exists = newItems.any((i) => i.categoryId == item.categoryId && i.storeId == item.storeId);
      if (exists) continue;

      final result = await _insertInventory(item);
      result.fold(
        (f) => error = f.message,
        (newItem) => newItems.add(newItem),
      );
      if (error != null) break;
    }
    if (error != null) {
      emit(state.toError(error!));
    } else {
      emit(state.copyWith(status: CatalogStatus.success, items: newItems));
    }
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
