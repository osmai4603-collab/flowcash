import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول خصائص الأصناف.
class CategoryPropertiesTable extends TableInfo {
  static final CategoryPropertiesTable _instance = CategoryPropertiesTable.internal();

  factory CategoryPropertiesTable() => _instance;

  CategoryPropertiesTable.internal();

  @override
  final String tableName = 'categories_properties';

  final String id = 'property_id';
  final String mainCategoryId = 'main_category_id';
  final String propertyName = 'property_name';
  final String unitType = 'unit_type';
  final String isSingle = 'is_single';
  final String isCategoryUnit = 'is_category_unit';
  final String isPricingUnit = 'is_pricing_unit';
  final String isInventoryUnit = 'is_inventory_unit';

  @override
  List<String> get columns => [id,
    mainCategoryId,
    propertyName,
    unitType,
    isSingle,
    isCategoryUnit,
    isPricingUnit,
    isInventoryUnit,];
}
