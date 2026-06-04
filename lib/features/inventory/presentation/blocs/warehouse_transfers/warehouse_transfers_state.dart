import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';

enum TransfersStatus { initial, loading, success, error }

class WarehouseTransfersState extends Equatable {
  final List<InventoryTransactionEntity> transactions;
  final List<InventoryTransactionOrderEntity> allOrders;
  final List<InventoryEntity> batches;
  final List<WarehouseEntity> warehouses;
  final TransfersStatus status;
  final String? errorMessage;
  final InventoryTransactionEntity? selectedTransfer;
  final List<InventoryTransactionOrderEntity> selectedTransferOrders;

  const WarehouseTransfersState({
    this.transactions = const [],
    this.allOrders = const [],
    this.batches = const [],
    this.warehouses = const [],
    this.status = TransfersStatus.initial,
    this.errorMessage,
    this.selectedTransfer,
    this.selectedTransferOrders = const [],
  });

  WarehouseTransfersState copyWith({
    List<InventoryTransactionEntity>? transactions,
    List<InventoryTransactionOrderEntity>? allOrders,
    List<InventoryEntity>? batches,
    List<WarehouseEntity>? warehouses,
    TransfersStatus? status,
    String? errorMessage,
    InventoryTransactionEntity? selectedTransfer,
    List<InventoryTransactionOrderEntity>? selectedTransferOrders,
  }) {
    return WarehouseTransfersState(
      transactions: transactions ?? this.transactions,
      allOrders: allOrders ?? this.allOrders,
      batches: batches ?? this.batches,
      warehouses: warehouses ?? this.warehouses,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedTransfer: selectedTransfer ?? this.selectedTransfer,
      selectedTransferOrders: selectedTransferOrders ?? this.selectedTransferOrders,
    );
  }

  WarehouseTransfersState addTransfer(
    InventoryTransactionEntity fromT,
    InventoryTransactionEntity toT,
    List<InventoryTransactionOrderEntity> orders,
  ) {
    return copyWith(
      transactions: [fromT, toT, ...transactions],
      allOrders: [...orders, ...allOrders],
      status: TransfersStatus.success,
    );
  }

  WarehouseTransfersState removeTransfer(int fromId, int toId) {
    final updatedTrans = transactions.where((t) => t.id != fromId && t.id != toId).toList();
    final updatedOrders = allOrders.where((o) => o.tranId != fromId && o.tranId != toId).toList();
    
    return copyWith(
      transactions: updatedTrans,
      allOrders: updatedOrders,
      selectedTransfer: selectedTransfer?.id == fromId || selectedTransfer?.id == toId ? null : selectedTransfer,
      selectedTransferOrders: selectedTransfer?.id == fromId || selectedTransfer?.id == toId ? const [] : selectedTransferOrders,
      status: TransfersStatus.success,
    );
  }

  WarehouseTransfersState toError(String message) {
    return copyWith(
      status: TransfersStatus.error,
      errorMessage: message,
    );
  }

  WarehouseTransfersState toLoading() {
    return copyWith(
      status: TransfersStatus.loading,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        allOrders,
        batches,
        warehouses,
        status,
        errorMessage,
        selectedTransfer,
        selectedTransferOrders,
      ];
}
