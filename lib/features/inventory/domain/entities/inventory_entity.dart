import 'package:flowcash/core/entities/entity.dart';

abstract class InventoryEntity extends Entity {
  final int id;
  final int categoryId;
  final int storeId;
  final int? revenueAccountId;
  final int? expenseAccountId;
  final int? incomeStockId;
  final int? outcomeStockId;
  final String inventoryName;
  final double unitCost;
  final double countUnits;

  const InventoryEntity({
    required this.id,
    required this.categoryId,
    required this.storeId,
    this.revenueAccountId,
    this.expenseAccountId,
    this.incomeStockId,
    this.outcomeStockId,
    required this.inventoryName,
    required this.unitCost,
    required this.countUnits,
  });

  @override
  List<Object?> get props => [
        id,
        categoryId,
        storeId,
        revenueAccountId,
        expenseAccountId,
        incomeStockId,
        outcomeStockId,
        inventoryName,
        unitCost,
        countUnits,
      ];

  @override
  InventoryEntity copyWith({
    int? id,
    int? categoryId,
    int? storeId,
    int? revenueAccountId,
    int? expenseAccountId,
    int? incomeStockId,
    int? outcomeStockId,
    String? inventoryName,
    double? unitCost,
    double? countUnits,
  });
}

class InventoryItemEntity extends InventoryEntity {
  const InventoryItemEntity({
    required super.id,
    required super.categoryId,
    required super.storeId,
    super.revenueAccountId,
    super.expenseAccountId,
    super.incomeStockId,
    super.outcomeStockId,
    required super.inventoryName,
    required super.unitCost,
    required super.countUnits,
  });

  @override
  InventoryItemEntity copyWith({
    int? id,
    int? categoryId,
    int? storeId,
    int? revenueAccountId,
    int? expenseAccountId,
    int? incomeStockId,
    int? outcomeStockId,
    String? inventoryName,
    double? unitCost,
    double? countUnits,
  }) {
    return InventoryItemEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      revenueAccountId: revenueAccountId ?? this.revenueAccountId,
      expenseAccountId: expenseAccountId ?? this.expenseAccountId,
      incomeStockId: incomeStockId ?? this.incomeStockId,
      outcomeStockId: outcomeStockId ?? this.outcomeStockId,
      inventoryName: inventoryName ?? this.inventoryName,
      unitCost: unitCost ?? this.unitCost,
      countUnits: countUnits ?? this.countUnits,
    );
  }
}
