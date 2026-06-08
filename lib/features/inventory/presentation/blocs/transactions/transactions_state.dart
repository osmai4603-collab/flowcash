import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';

enum TransactionsStatus { initial, loading, success, error }

class TransactionsState extends Equatable {
  final List<InventoryTransactionEntity> transactions;
  final List<InventoryTransactionOrderEntity> allOrders;
  final List<InventoryEntity> batches;
  final List<WarehouseEntity> warehouses;
  final TransactionsStatus status;
  final String? errorMessage;
  final InventoryTransactionEntity? selectedTransaction;
  final List<InventoryTransactionOrderEntity> selectedTransactionOrders;

  const TransactionsState({
    this.transactions = const [],
    this.allOrders = const [],
    this.batches = const [],
    this.warehouses = const [],
    this.status = TransactionsStatus.initial,
    this.errorMessage,
    this.selectedTransaction,
    this.selectedTransactionOrders = const [],
  });

  TransactionsState copyWith({
    List<InventoryTransactionEntity>? transactions,
    List<InventoryTransactionOrderEntity>? allOrders,
    List<InventoryEntity>? batches,
    List<WarehouseEntity>? warehouses,
    TransactionsStatus? status,
    String? errorMessage,
    InventoryTransactionEntity? selectedTransaction,
    List<InventoryTransactionOrderEntity>? selectedTransactionOrders,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      allOrders: allOrders ?? this.allOrders,
      batches: batches ?? this.batches,
      warehouses: warehouses ?? this.warehouses,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedTransaction: selectedTransaction ?? this.selectedTransaction,
      selectedTransactionOrders:
          selectedTransactionOrders ?? this.selectedTransactionOrders,
    );
  }

  TransactionsState addTransaction(
    InventoryTransactionEntity transaction,
    List<InventoryTransactionOrderEntity> orders,
  ) {
    return copyWith(
      transactions: [transaction, ...transactions],
      allOrders: [...orders, ...allOrders],
      status: TransactionsStatus.success,
    );
  }

  TransactionsState updateTransaction(
    InventoryTransactionEntity transaction,
    List<InventoryTransactionOrderEntity> orders,
  ) {
    final updatedTrans = transactions
        .map((t) => t.id == transaction.id ? transaction : t)
        .toList();

    // Remove old orders for this tran, then add the updated ones
    final updatedOrders =
        allOrders.where((o) => o.tranId != transaction.id).toList()
          ..addAll(orders);

    return copyWith(
      transactions: updatedTrans,
      allOrders: updatedOrders,
      selectedTransaction: selectedTransaction?.id == transaction.id
          ? transaction
          : selectedTransaction,
      selectedTransactionOrders: selectedTransaction?.id == transaction.id
          ? orders
          : selectedTransactionOrders,
      status: TransactionsStatus.success,
    );
  }

  TransactionsState removeTransaction(int id) {
    final updatedTrans = transactions.where((t) => t.id != id).toList();
    final updatedOrders = allOrders.where((o) => o.tranId != id).toList();

    return copyWith(
      transactions: updatedTrans,
      allOrders: updatedOrders,
      selectedTransaction: selectedTransaction?.id == id
          ? null
          : selectedTransaction,
      selectedTransactionOrders: selectedTransaction?.id == id
          ? const []
          : selectedTransactionOrders,
      status: TransactionsStatus.success,
    );
  }

  TransactionsState toError(String message) {
    return copyWith(status: TransactionsStatus.error, errorMessage: message);
  }

  TransactionsState toLoading() {
    return copyWith(status: TransactionsStatus.loading);
  }

  @override
  List<Object?> get props => [
    transactions,
    allOrders,
    batches,
    warehouses,
    status,
    errorMessage,
    selectedTransaction,
    selectedTransactionOrders,
  ];
}
