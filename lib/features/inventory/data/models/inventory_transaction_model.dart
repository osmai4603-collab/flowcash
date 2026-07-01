import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/core/enums/inventory_transaction_nature_enum.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/models/model.dart';

final class InventoryTransactionModel extends InventoryTransactionEntity implements Model {
  const InventoryTransactionModel({
    required super.id,
    required super.createdAt,
    required super.createdBy,
    super.note,
    super.warehouseId = 0,
    super.personId = 0,
    super.billNumber = 0,
    super.transactionType = InventoryTransactionType.importInventory,
    super.transactionNature = InventoryTransactionNature.purchases,
    super.orders = const [],
  });

  factory InventoryTransactionModel.fromMap(Map<String, dynamic> map) {
    return InventoryTransactionModel(
      id: map[InventoryTransactionsTable().id] as int,
      createdAt: DateTime.parse(
        map[InventoryTransactionsTable().createdAt] as String? ?? "",
      ),
      createdBy: map[InventoryTransactionsTable().createdBy],
      note: map[InventoryTransactionsTable().note] as String?,
      warehouseId: map[InventoryTransactionsTable().warehouseId] as int,
      personId: map[InventoryTransactionsTable().personId] as int,
      billNumber: map[InventoryTransactionsTable().billNumber] as int,
      transactionType: InventoryTransactionType.of(
        map[InventoryTransactionsTable().transactionType] as String,
      ),
      transactionNature: InventoryTransactionNature.of(
        map[InventoryTransactionsTable().transactionNature] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id > 0) InventoryTransactionsTable().id: id,
      InventoryTransactionsTable().createdAt: createdAt.toIso8601String(),
      InventoryTransactionsTable().createdBy: createdBy,
      InventoryTransactionsTable().note: note,
      InventoryTransactionsTable().warehouseId: warehouseId,
      InventoryTransactionsTable().personId: personId,
      InventoryTransactionsTable().billNumber: billNumber,
      InventoryTransactionsTable().transactionType: transactionType.name,
      InventoryTransactionsTable().transactionNature: transactionNature.name,
    };
  }

  @override
  InventoryTransactionModel copyWith({
    int? id,
    DateTime? createdAt,
    int? createdBy,
    String? note,
    int? warehouseId,
    int? personId,
    int? billNumber,
    InventoryTransactionType? transactionType,
    InventoryTransactionNature? transactionNature,
    List<InventoryTransactionOrderEntity>? orders,
  }) {
    return InventoryTransactionModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      note: note ?? this.note,
      warehouseId: warehouseId ?? this.warehouseId,
      personId: personId ?? this.personId,
      billNumber: billNumber ?? this.billNumber,
      transactionType: transactionType ?? this.transactionType,
      transactionNature: transactionNature ?? this.transactionNature,
      orders: orders ?? this.orders,
    );
  }
}

