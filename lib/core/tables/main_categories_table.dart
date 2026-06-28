import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول الأصناف الرئيسية.
class MainCategoriesTable extends TableInfo {
  static final MainCategoriesTable _instance = MainCategoriesTable.internal();

  factory MainCategoriesTable() => _instance;

  MainCategoriesTable.internal();

  @override
  final String tableName = 'main_categories';

  final String id = 'category_id';
  final String categoryName = 'category_name';
  final String unitType = 'unit_type';
  final String categoryType = 'category_type';
  final String unitName = 'unit_name';

  @override
  List<String> get columns => [id,
    categoryName,
    unitType,
    categoryType,
    unitName,];
}
