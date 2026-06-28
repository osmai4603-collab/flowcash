import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول الكتالوجات.
class SubcategoriesTable extends TableInfo {
  static final SubcategoriesTable _instance = SubcategoriesTable.internal();

  factory SubcategoriesTable() => _instance;

  SubcategoriesTable.internal();

  @override
  final String tableName = 'subcategories';

  final String id = 'catalog_id';
  final String mainCategoryId = 'main_category_id';
  final String catalogName = 'catalog_name';
  final String catalogNumber = 'catalog_number';

  @override
  List<String> get columns => [id,
    mainCategoryId,
    catalogName,
    catalogNumber,];
}
