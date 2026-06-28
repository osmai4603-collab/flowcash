import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/category_properties_table.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';

class CategoryPropertiesTableSqlite extends CategoryPropertiesTable implements SqliteTable {
  static final CategoryPropertiesTableSqlite _instance = CategoryPropertiesTableSqlite._internal();

  factory CategoryPropertiesTableSqlite() => _instance;

  CategoryPropertiesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${mainCategoryId} INTEGER NOT NULL,
        ${propertyName} TEXT NOT NULL,
        ${unitType} TEXT NOT NULL,
        ${isSingle} INTEGER NOT NULL DEFAULT 0,
        ${isCategoryUnit} INTEGER NOT NULL DEFAULT 0,
        ${isPricingUnit} INTEGER NOT NULL DEFAULT 0,
        ${isInventoryUnit} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (${mainCategoryId}) REFERENCES ${MainCategoriesTable().tableName} (${MainCategoriesTable().id}) ON DELETE CASCADE
      )
  ''';
}
