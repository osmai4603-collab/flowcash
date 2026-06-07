import 'package:flowcash/core/entities/entity.dart';

abstract class InventoryEntity extends Entity {
  final int id;
  final int categoryId;
  final int storeId;
  final int revenueAccountId;
  final int expenseAccountId;
  final int incomeStockId;
  final int outcomeStockId;
  final String inventoryName;
  final double costTotal;
  final double countUnits;

  const InventoryEntity({
    required this.id,
    required this.categoryId,
    required this.storeId,
    required this.revenueAccountId,
    required this.expenseAccountId,
    required this.incomeStockId,
    required this.outcomeStockId,
    required this.inventoryName,
    required this.costTotal,
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
    costTotal,
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
    required super.revenueAccountId,
    required super.expenseAccountId,
    required super.incomeStockId,
    required super.outcomeStockId,
    required super.inventoryName,
    required super.costTotal,
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
      costTotal: unitCost ?? this.costTotal,
      countUnits: countUnits ?? this.countUnits,
    );
  }
}
