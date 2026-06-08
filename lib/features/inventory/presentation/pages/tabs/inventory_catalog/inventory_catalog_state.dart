import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_catalog_entity.dart';

enum CatalogStatus { initial, loading, success, error }

class InventoryCatalogState extends Equatable {
  final List<InventoryEntity> items;
  final List<InventorySubcategoryEntity> subcategories;
  final CatalogStatus status;
  final String? errorMessage;
  final InventoryEntity? selectedItem;

  const InventoryCatalogState({
    this.items = const [],
    this.subcategories = const [],
    this.status = CatalogStatus.initial,
    this.errorMessage,
    this.selectedItem,
  });

  InventoryCatalogState copyWith({
    List<InventoryEntity>? items,
    List<InventorySubcategoryEntity>? subcategories,
    CatalogStatus? status,
    String? errorMessage,
    InventoryEntity? selectedItem,
  }) {
    return InventoryCatalogState(
      items: items ?? this.items,
      subcategories: subcategories ?? this.subcategories,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedItem: selectedItem ?? this.selectedItem,
    );
  }

  InventoryCatalogState addItem(InventoryEntity item) {
    return copyWith(items: [item, ...items], status: CatalogStatus.success);
  }

  InventoryCatalogState updateItem(InventoryEntity item) {
    final updated = items.map((i) => i.id == item.id ? item : i).toList();
    return copyWith(
      items: updated,
      selectedItem: selectedItem?.id == item.id ? item : selectedItem,
      status: CatalogStatus.success,
    );
  }

  InventoryCatalogState removeItem(int id) {
    final updated = items.where((i) => i.id != id).toList();
    return copyWith(
      items: updated,
      selectedItem: selectedItem?.id == id ? null : selectedItem,
      status: CatalogStatus.success,
    );
  }

  InventoryCatalogState toError(String message) {
    return copyWith(status: CatalogStatus.error, errorMessage: message);
  }

  InventoryCatalogState toLoading() {
    return copyWith(status: CatalogStatus.loading);
  }

  @override
  List<Object?> get props => [
    items,
    subcategories,
    status,
    errorMessage,
    selectedItem,
  ];
}
