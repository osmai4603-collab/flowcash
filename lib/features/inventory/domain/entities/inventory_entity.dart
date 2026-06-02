import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/inventory_cost_type_enum.dart';

abstract class InventoryEntity extends Entity {
  final int id;
  final int categoryId;
  final int storeId;
  final InventoryCostType costType;
  final int? revenueAccountId;
  final int? expenseAccountId;
  final int? incomeStockId;
  final int? outcomeStockId;
  final double countUnits;

  const InventoryEntity({
    required this.id,
    required this.categoryId,
    required this.storeId,
    required this.costType,
    this.revenueAccountId,
    this.expenseAccountId,
    this.incomeStockId,
    this.outcomeStockId,
    required this.countUnits,
  });

  @override
  List<Object?> get props => [
        id,
        categoryId,
        storeId,
        costType,
        revenueAccountId,
        expenseAccountId,
        incomeStockId,
        outcomeStockId,
        countUnits,
      ];

  @override
  InventoryEntity copyWith({
    int? id,
    int? categoryId,
    int? storeId,
    InventoryCostType? costType,
    int? revenueAccountId,
    int? expenseAccountId,
    int? incomeStockId,
    int? outcomeStockId,
    double? countUnits,
  });
}

class InventoryItemEntity extends InventoryEntity {
  const InventoryItemEntity({
    required super.id,
    required super.categoryId,
    required super.storeId,
    required super.costType,
    super.revenueAccountId,
    super.expenseAccountId,
    super.incomeStockId,
    super.outcomeStockId,
    required super.countUnits,
  });

  @override
  InventoryItemEntity copyWith({
    int? id,
    int? categoryId,
    int? storeId,
    InventoryCostType? costType,
    int? revenueAccountId,
    int? expenseAccountId,
    int? incomeStockId,
    int? outcomeStockId,
    double? countUnits,
  }) {
    return InventoryItemEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      costType: costType ?? this.costType,
      revenueAccountId: revenueAccountId ?? this.revenueAccountId,
      expenseAccountId: expenseAccountId ?? this.expenseAccountId,
      incomeStockId: incomeStockId ?? this.incomeStockId,
      outcomeStockId: outcomeStockId ?? this.outcomeStockId,
      countUnits: countUnits ?? this.countUnits,
    );
  }
}
