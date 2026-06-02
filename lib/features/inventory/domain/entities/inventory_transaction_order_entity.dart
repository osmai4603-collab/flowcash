import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';

class InventoryTransactionOrderEntity extends Entity {
  final int id;
  final int? inventoryBatchId;
  final double countUnits;
  final int tranId;
  final InventoryTransactionType transactionType;

  const InventoryTransactionOrderEntity({
    required this.id,
    this.inventoryBatchId,
    this.countUnits = 0.0,
    this.tranId = 0,
    this.transactionType = InventoryTransactionType.inventoryReceipt,
  });

  @override
  List<Object?> get props => [id, inventoryBatchId, countUnits, tranId, transactionType];

  @override
  InventoryTransactionOrderEntity copyWith({
    int? id,
    int? inventoryBatchId,
    double? countUnits,
    int? tranId,
    InventoryTransactionType? transactionType,
  }) {
    return InventoryTransactionOrderEntity(
      id: id ?? this.id,
      inventoryBatchId: inventoryBatchId ?? this.inventoryBatchId,
      countUnits: countUnits ?? this.countUnits,
      tranId: tranId ?? this.tranId,
      transactionType: transactionType ?? this.transactionType,
    );
  }
}