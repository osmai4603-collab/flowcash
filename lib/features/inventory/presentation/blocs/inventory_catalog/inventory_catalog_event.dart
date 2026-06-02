import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';

abstract class InventoryCatalogEvent extends Equatable {
  const InventoryCatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventoryCatalogEvent extends InventoryCatalogEvent {
  const LoadInventoryCatalogEvent();
}

class AddInventoryItemEvent extends InventoryCatalogEvent {
  final InventoryEntity item;
  const AddInventoryItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateInventoryItemEvent extends InventoryCatalogEvent {
  final InventoryEntity item;
  const UpdateInventoryItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class DeleteInventoryItemEvent extends InventoryCatalogEvent {
  final int id;
  const DeleteInventoryItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}
