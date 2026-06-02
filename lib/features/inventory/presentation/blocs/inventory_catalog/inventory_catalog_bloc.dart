import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_catalog_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/main_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'inventory_catalog_event.dart';
import 'inventory_catalog_state.dart';

class InventoryCatalogBloc extends Bloc<InventoryCatalogEvent, InventoryCatalogState> {
  final GetInventorysUseCase _getInventorys;
  final InsertInventoryUseCase _insertInventory;
  final UpdateInventoryUseCase _updateInventory;
  final DeleteInventoryUseCase _deleteInventory;
  final GetInventorySubcategoriesUseCase _getInventorySubcategories;
  final GetMainAccountsUseCase _getMainAccounts;
  final GetSubAccountsUseCase _getSubAccounts;

  InventoryCatalogBloc({
    required GetInventorysUseCase getInventorys,
    required InsertInventoryUseCase insertInventory,
    required UpdateInventoryUseCase updateInventory,
    required DeleteInventoryUseCase deleteInventory,
    required GetInventorySubcategoriesUseCase getInventorySubcategories,
    required GetMainAccountsUseCase getMainAccounts,
    required GetSubAccountsUseCase getSubAccounts,
  })  : _getInventorys = getInventorys,
        _insertInventory = insertInventory,
        _updateInventory = updateInventory,
        _deleteInventory = deleteInventory,
        _getInventorySubcategories = getInventorySubcategories,
        _getMainAccounts = getMainAccounts,
        _getSubAccounts = getSubAccounts,
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
    final subcategoriesResult = await _getInventorySubcategories();

    inventoriesResult.fold(
      (f) => emit(state.toError(f.message)),
      (items) {
        subcategoriesResult.fold(
          (f) => emit(state.toError(f.message)),
          (subcats) {
            emit(state.copyWith(
              status: CatalogStatus.success,
              items: items,
              subcategories: subcats,
            ));
          },
        );
      },
    );
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
