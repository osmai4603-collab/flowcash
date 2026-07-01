import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول الأصناف.
class CategoriesTable extends TableById {
  static final CategoriesTable _instance = CategoriesTable.internal();

  factory CategoriesTable() => _instance;

  CategoriesTable.internal();

  @override
  final String tableName = 'categories';

  final String id = 'category_id';
  final String categoryType = 'category_type';
  final String categoryName = 'category_name';
  final String categoryNumber = 'category_number';
  final String barcode = 'barcode';
  final String categoryUnitId = 'category_unit_id';
  final String pricingUnitId = 'pricing_unit_id';
  final String inventoryUnitId = 'inventory_unit_id';
  final String subcategoryId = 'subcategory_id';

  @override
  List<String> get columns => [id,
    categoryType,
    categoryNumber,
    categoryName,
    barcode,
    categoryUnitId,
    pricingUnitId,
    inventoryUnitId,
    subcategoryId,];
}
