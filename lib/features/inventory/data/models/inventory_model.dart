import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';

final class InventoryModel extends InventoryItemEntity {
  const InventoryModel({
    required super.id,
    required super.categoryId,
    required super.storeId,
    required super.propertyAccountId,
    required super.revenueAccountId,
    required super.expenseAccountId,
    required super.incomeStockId,
    required super.outcomeStockId,
    required super.inventoryName,
    required super.costTotal,
    required super.countUnits,
    required super.userId,
  });

  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map[InventoriesTable().id] as int,
      categoryId: map[InventoriesTable().categoryId] as int,
      storeId: map[InventoriesTable().storeId] as int,
      propertyAccountId: (map[InventoriesTable().propertyAccountId] ?? 0) as int,
      revenueAccountId: map[InventoriesTable().revenueAccountId] as int,
      expenseAccountId: map[InventoriesTable().expenseAccountId] as int,
      incomeStockId: map[InventoriesTable().incomeStockId] as int,
      outcomeStockId: map[InventoriesTable().outcomeStockId] as int,
      inventoryName: (map[CategoriesTable().categoryName] as String?) ?? '',
      costTotal: ((map[InventoriesTable().costTotal] ?? 0) as num).toDouble(),
      countUnits: ((map[InventoriesTable().countUnits]) as num).toDouble(),
      userId: (map[InventoriesTable().userId] ?? 1) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) InventoriesTable().id: id,
      InventoriesTable().categoryId: categoryId,
      InventoriesTable().storeId: storeId,
      InventoriesTable().propertyAccountId: propertyAccountId,
      InventoriesTable().revenueAccountId: revenueAccountId,
      InventoriesTable().expenseAccountId: expenseAccountId,
      InventoriesTable().incomeStockId: incomeStockId,
      InventoriesTable().outcomeStockId: outcomeStockId,
      // CategoriesTable().categoryName: inventoryName,
      InventoriesTable().costTotal: costTotal,
      InventoriesTable().countUnits: countUnits,
      InventoriesTable().userId: userId,
    };
  }

  @override
  InventoryModel copyWith({
    int? id,
    int? categoryId,
    int? storeId,
    int? propertyAccountId,
    int? revenueAccountId,
    int? expenseAccountId,
    int? incomeStockId,
    int? outcomeStockId,
    String? inventoryName,
    double? costTotal,
    double? countUnits,
    int? userId,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
      propertyAccountId: propertyAccountId ?? this.propertyAccountId,
      revenueAccountId: revenueAccountId ?? this.revenueAccountId,
      expenseAccountId: expenseAccountId ?? this.expenseAccountId,
      incomeStockId: incomeStockId ?? this.incomeStockId,
      outcomeStockId: outcomeStockId ?? this.outcomeStockId,
      inventoryName: inventoryName ?? this.inventoryName,
      costTotal: costTotal ?? this.costTotal,
      countUnits: countUnits ?? this.countUnits,
      userId: userId ?? this.userId,
    );
  }
}
