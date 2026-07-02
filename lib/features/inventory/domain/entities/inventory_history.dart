import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';

class InventoryHistory extends Entity {
  final int transactionOrderId;
  final InventoryTransactionType transactionType;
  final double countUnits;
  final String categoryName;
  final String categoryUnit;
  final int inventoryId;
  final double openingQuantity;

  const InventoryHistory({
    required this.transactionOrderId,
    required this.transactionType,
    required this.countUnits,
    required this.categoryName,
    required this.categoryUnit,
    required this.inventoryId,
    this.openingQuantity = 0.0,
  });

  @override
  List<Object?> get props => [
        transactionOrderId,
        transactionType,
        countUnits,
        categoryName,
        categoryUnit,
        inventoryId,
        openingQuantity,
      ];

  @override
  InventoryHistory copyWith({
    int? transactionOrderId,
    InventoryTransactionType? transactionType,
    double? countUnits,
    String? categoryName,
    String? categoryUnit,
    int? inventoryId,
    double? openingQuantity,
  }) {
    return InventoryHistory(
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
