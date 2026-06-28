import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/categories_attributes_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/tables/catalog_infos_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';

class CategoriesAttributesTableSqlite extends CategoriesAttributesTable implements SqliteTable {
  static final CategoriesAttributesTableSqlite _instance = CategoriesAttributesTableSqlite._internal();

  factory CategoriesAttributesTableSqlite() => _instance;

  CategoriesAttributesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${categoryId} INTEGER NOT NULL,
        ${subcategoryUnitId} INTEGER NOT NULL,
        FOREIGN KEY (${categoryId}) REFERENCES ${CategoriesTable().tableName} (${CategoriesTable().id}) ON DELETE CASCADE,
        FOREIGN KEY (${subcategoryUnitId}) REFERENCES ${SubcategoriesUnitsTable().tableName} (${SubcategoriesUnitsTable().id}) ON DELETE CASCADE
      )
  ''';
}
