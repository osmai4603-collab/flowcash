import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول معلومات الكتالوج.
class SubcategoriesUnitsTable extends TableInfo {
  static final SubcategoriesUnitsTable _instance = SubcategoriesUnitsTable.internal();

  factory SubcategoriesUnitsTable() => _instance;

  SubcategoriesUnitsTable.internal();

  @override
  final String tableName = 'subcategories_units';

  final String id = 'info_id';
  final String subcategoryId = 'subcategory_id';
  final String unitId = 'unit_id';
  final String propertyId = 'property_id';

  @override
  List<String> get columns => [id, subcategoryId, unitId, propertyId];
}
