import 'package:flowcash/core/services/sqlite/table_info.dart';

class CategoriesAttributesTable extends TableInfo {
  static final CategoriesAttributesTable _instance = CategoriesAttributesTable.internal();

  factory CategoriesAttributesTable() => _instance;

  CategoriesAttributesTable.internal();

  @override
  final String tableName = 'categories_attributes';

  final String id = 'id';
  final String categoryId = 'category_id';
  final String subcategoryUnitId = 'subcategory_unit_id';

  @override
  List<String> get columns => [id, categoryId, subcategoryUnitId];
}
