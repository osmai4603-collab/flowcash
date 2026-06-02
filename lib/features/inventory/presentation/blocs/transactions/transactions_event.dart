import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionsEvent {
  const LoadTransactionsEvent();
}

class AddTransactionEvent extends TransactionsEvent {
  final InventoryTransactionEntity transaction;
  final List<InventoryTransactionOrderEntity> items;
  const AddTransactionEvent(this.transaction, this.items);

  @override
  List<Object?> get props => [transaction, items];
}

class UpdateTransactionEvent extends TransactionsEvent {
  final InventoryTransactionEntity transaction;
  final List<InventoryTransactionOrderEntity> items;
  const UpdateTransactionEvent(this.transaction, this.items);

  @override
  List<Object?> get props => [transaction, items];
}

class DeleteTransactionEvent extends TransactionsEvent {
  final int id;
  const DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}
