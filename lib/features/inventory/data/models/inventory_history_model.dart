import 'package:flowcash/features/inventory/domain/entities/inventory_history.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/models/model.dart';

class InventoryHistoryModel extends InventoryHistory implements Model {
  const InventoryHistoryModel({
    required super.transactionOrderId,
    required super.transactionType,
    required super.countUnits,
    required super.categoryName,
    required super.categoryUnit,
    required super.inventoryId,
    required super.openingQuantity,
  });

  factory InventoryHistoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryHistoryModel(
      transactionOrderId: map[InventoryTransactionsOrdersTable().id] as int,
      transactionType: InventoryTransactionType.of(
        map[InventoryTransactionsTable().transactionType] as String,
      ),
      countUnits: (map[InventoryTransactionsOrdersTable().countUnits] as num).toDouble(),
      categoryName: map[CategoriesTable().categoryName] as String,
      categoryUnit: map[UnitsTable().unitName] as String,
      inventoryId: map[InventoryTransactionsOrdersTable().inventoryId] as int,
      openingQuantity: (map['opening_quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  @override
  Map<String, dynamic> toMap() {
    return {
      InventoryTransactionsOrdersTable().id: transactionOrderId,
      InventoryTransactionsTable().transactionType: transactionType.name,
      InventoryTransactionsOrdersTable().countUnits: countUnits,
      CategoriesTable().categoryName: categoryName,
      UnitsTable().unitName: categoryUnit,
      InventoryTransactionsOrdersTable().inventoryId: inventoryId,
      'opening_quantity': openingQuantity,
    };
  }

  @override
  InventoryHistoryModel copyWith({
    int? transactionOrderId,
    InventoryTransactionType? transactionType,
    double? countUnits,
    String? categoryName,
    String? categoryUnit,
    int? inventoryId,
    double? openingQuantity,
  }) {
    return InventoryHistoryModel(
      transactionOrderId: transactionOrderId ?? this.transactionOrderId,
      transactionType: transactionType ?? this.transactionType,
      countUnits: countUnits ?? this.countUnits,
      categoryName: categoryName ?? this.categoryName,
      categoryUnit: categoryUnit ?? this.categoryUnit,
      inventoryId: inventoryId ?? this.inventoryId,
      openingQuantity: openingQuantity ?? this.openingQuantity,
    );
  }
}
