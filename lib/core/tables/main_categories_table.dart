import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول الأصناف الرئيسية.
class MainCategoriesTable extends TableById {
  static final MainCategoriesTable _instance = MainCategoriesTable.internal();

  factory MainCategoriesTable() => _instance;

  MainCategoriesTable.internal();

  @override
  final String tableName = 'main_categories';

  final String id = 'category_id';
  final String categoryName = 'category_name';
  final String categoryType = 'category_type';
  final String categoryUnitId = 'category_unit_id';

  @override
  List<String> get columns => [
        id,
        categoryName,
        categoryType,
        categoryUnitId,
      ];
}
