import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

class InventoryCategoryEntity extends Entity {
  final int inventoryId;
  final int categoryId;
  final int warehouseId;
  final String inventoryName;
  final double countUnits;
  final double unitCost;
  final int? revenueAccountId;
  final int? expenseAccountId;
  final int? incomeAccountId;
  final int? outcomAccountId;
  final UnitEntity? categoryUnit;

  const InventoryCategoryEntity({
    required this.inventoryId,
    required this.categoryId,
    required this.warehouseId,
    required this.inventoryName,
    required this.countUnits,
    required this.unitCost,
    this.revenueAccountId,
    this.expenseAccountId,
    this.incomeAccountId,
    this.outcomAccountId,
    this.categoryUnit,
  });

  @override
  List<Object?> get props => [
    inventoryId,
    categoryId,
    inventoryName,
    countUnits,
    unitCost,
    revenueAccountId,
    expenseAccountId,
    incomeAccountId,
    outcomAccountId,
    warehouseId,
    categoryUnit,
  ];

  @override
  InventoryCategoryEntity copyWith({
    int? inventoryId,
    int? categoryId,
    int? warehouseId,
    String? categoryName,
    double? countUnits,
    double? unitCost,
    int? revenueAccountId,
    int? expenseAccountId,
    int? incomeAccountId,
    int? outcomAccountId,
    UnitEntity? categoryUnit,
  }) {
    return InventoryCategoryEntity(
      inventoryId: inventoryId ?? this.inventoryId,
      categoryId: categoryId ?? this.categoryId,
      warehouseId: warehouseId ?? this.warehouseId,
      inventoryName: categoryName ?? this.inventoryName,
      countUnits: countUnits ?? this.countUnits,
      unitCost: unitCost ?? this.unitCost,
      revenueAccountId: revenueAccountId ?? this.revenueAccountId,
      expenseAccountId: expenseAccountId ?? this.expenseAccountId,
      incomeAccountId: incomeAccountId ?? this.incomeAccountId,
      outcomAccountId: outcomAccountId ?? this.outcomAccountId,
      categoryUnit: categoryUnit ?? this.categoryUnit,
    );
  }
}
