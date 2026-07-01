import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/data/models/unit_model.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_category_entity.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/models/model.dart';

final class InventoryCategoryModel extends InventoryCategoryEntity implements Model {
  const InventoryCategoryModel({
    required super.inventoryId,
    required super.categoryId,
    required super.warehouseId,
    required super.inventoryName,
    required super.countUnits,
    required super.costTotal,
    required super.propertyAccountId,
    required super.revenueAccountId,
    required super.expenseAccountId,
    required super.incomeAccountId,
    required super.outcomAccountId,
    super.categoryUnit,
  });

  factory InventoryCategoryModel.fromMap(Map<String, dynamic> r) {
    UnitEntity? unit;
    try {
      final unitId = r['category_unit_id'] as int?;
      if (unitId != null) {
        final unitTypeName = (r['unit_type'] as String?) ?? '';
        unit = UnitModel.fromMap(r);
      }
    } catch (_) {
      unit = null;
    }

    return InventoryCategoryModel(
      inventoryId: r['inventory_id'] as int,
      categoryId: r['category_id'] as int,
      warehouseId: r['store_id'] as int,
      inventoryName: (r['category_name'] as String?) ?? '',
      costTotal: ((r['cost_total'] ?? 0) as num).toDouble(),
      countUnits: ((r['count_units'] ?? 0) as num).toDouble(),
      propertyAccountId: (r['property_id'] ?? 0) as int,
      revenueAccountId: r['revenue_id'] as int,
      expenseAccountId: r['expense_id'] as int,
      incomeAccountId: r['income_stock_id'] as int,
      outcomAccountId: r['outcome_stock_id'] as int,
      categoryUnit: unit,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'inventory_id': inventoryId,
      'category_id': categoryId,
      'store_id': warehouseId,
      'category_name': inventoryName,
      'cost_total': costTotal,
      'count_units': countUnits,
      'property_id': propertyAccountId,
      'revenue_id': revenueAccountId,
      'expense_id': expenseAccountId,
      'income_stock_id': incomeAccountId,
      'outcome_stock_id': outcomAccountId,
    };
  }

  @override
  InventoryCategoryModel copyWith({
    int? inventoryId,
    int? categoryId,
    int? warehouseId,
    String? categoryName,
    double? countUnits,
    double? costTotal,
    int? propertyAccountId,
    int? revenueAccountId,
    int? expenseAccountId,
    int? incomeAccountId,
    int? outcomAccountId,
    UnitEntity? categoryUnit,
  }) {
    return InventoryCategoryModel(
      inventoryId: inventoryId ?? this.inventoryId,
      categoryId: categoryId ?? this.categoryId,
      warehouseId: warehouseId ?? this.warehouseId,
      inventoryName: categoryName ?? this.inventoryName,
      countUnits: countUnits ?? this.countUnits,
      costTotal: costTotal ?? this.costTotal,
      propertyAccountId: propertyAccountId ?? this.propertyAccountId,
      revenueAccountId: revenueAccountId ?? this.revenueAccountId,
      expenseAccountId: expenseAccountId ?? this.expenseAccountId,
      incomeAccountId: incomeAccountId ?? this.incomeAccountId,
      outcomAccountId: outcomAccountId ?? this.outcomAccountId,
      categoryUnit: categoryUnit ?? this.categoryUnit,
    );
  }
}
