import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';

enum OpeningQuantitiesStatus { initial, loading, success, error }

class OpeningQuantitiesState extends Equatable {
  final List<OpeningQuantityEntity> items;
  final List<InventoryEntity> inventoryItems;
  final List<WarehouseEntity> warehouses;
  final OpeningQuantitiesStatus status;
  final String? errorMessage;

  const OpeningQuantitiesState({
    this.items = const [],
    this.inventoryItems = const [],
    this.warehouses = const [],
    this.status = OpeningQuantitiesStatus.initial,
    this.errorMessage,
  });

  OpeningQuantitiesState copyWith({
    List<OpeningQuantityEntity>? items,
    List<InventoryEntity>? inventoryItems,
    List<WarehouseEntity>? warehouses,
    OpeningQuantitiesStatus? status,
    String? errorMessage,
  }) {
    return OpeningQuantitiesState(
      items: items ?? this.items,
      inventoryItems: inventoryItems ?? this.inventoryItems,
      warehouses: warehouses ?? this.warehouses,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  OpeningQuantitiesState addItem(OpeningQuantityEntity item) {
    return copyWith(
      items: [item, ...items],
      status: OpeningQuantitiesStatus.success,
    );
  }

  OpeningQuantitiesState removeItem(int id) {
    return copyWith(
      items: items.where((i) => i.id != id).toList(),
      status: OpeningQuantitiesStatus.success,
    );
  }

  OpeningQuantitiesState toError(String message) {
    return copyWith(
      status: OpeningQuantitiesStatus.error,
      errorMessage: message,
    );
  }

  OpeningQuantitiesState toLoading() {
    return copyWith(status: OpeningQuantitiesStatus.loading);
  }

  @override
  List<Object?> get props => [
    items,
    inventoryItems,
    warehouses,
    status,
    errorMessage,
  ];
}
