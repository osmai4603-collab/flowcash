import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';

final class InventoryTransactionOrderModel
    extends InventoryTransactionOrderEntity {
  const InventoryTransactionOrderModel({
    required super.id,
    super.inventoryId,
    super.countUnits = 0.0,
    super.tranId = 0,
    super.transactionType = InventoryTransactionType.importInventory,
  });

  factory InventoryTransactionOrderModel.fromMap(Map<String, dynamic> map) {
    return InventoryTransactionOrderModel(
      id: map[InventoryTransactionsOrdersTable.id] as int,
      inventoryId: map[InventoryTransactionsOrdersTable.inventoryId] as int?,
      countUnits: ((map[InventoryTransactionsOrdersTable.countUnits]) as num)
          .toDouble(),
      tranId: map[InventoryTransactionsOrdersTable.tranId] as int,
      transactionType: InventoryTransactionType.of(
        map[InventoryTransactionsOrdersTable.transactionType] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) InventoryTransactionsOrdersTable.id: id,
      InventoryTransactionsOrdersTable.inventoryId: inventoryId,
      InventoryTransactionsOrdersTable.countUnits: countUnits,
      InventoryTransactionsOrdersTable.tranId: tranId,
      InventoryTransactionsOrdersTable.transactionType: transactionType.name,
    };
  }

  @override
  InventoryTransactionOrderModel copyWith({
    int? id,
    int? inventoryId,
    double? countUnits,
    int? tranId,
    InventoryTransactionType? transactionType,
  }) {
    return InventoryTransactionOrderModel(
      id: id ?? this.id,
      inventoryId: inventoryId ?? this.inventoryId,
      countUnits: countUnits ?? this.countUnits,
      tranId: tranId ?? this.tranId,
      transactionType: transactionType ?? this.transactionType,
    );
  }
}
