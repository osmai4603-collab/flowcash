import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';

abstract class WarehouseTransfersEvent extends Equatable {
  const WarehouseTransfersEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransfersEvent extends WarehouseTransfersEvent {
  const LoadTransfersEvent();
}

class AddTransferEvent extends WarehouseTransfersEvent {
  final InventoryTransactionEntity fromTransaction;
  final InventoryTransactionEntity toTransaction;
  final List<InventoryTransactionOrderEntity> items;
  
  const AddTransferEvent({
    required this.fromTransaction,
    required this.toTransaction,
    required this.items,
  });

  @override
  List<Object?> get props => [fromTransaction, toTransaction, items];
}

class DeleteTransferEvent extends WarehouseTransfersEvent {
  final int fromId;
  final int toId;
  const DeleteTransferEvent(this.fromId, this.toId);

  @override
  List<Object?> get props => [fromId, toId];
}
