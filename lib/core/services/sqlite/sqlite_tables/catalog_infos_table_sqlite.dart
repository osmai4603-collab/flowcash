import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/catalog_infos_table.dart';
import 'package:flowcash/core/tables/catalogs_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/tables/category_properties_table.dart';

class SubcategoriesUnitsTableSqlite extends SubcategoriesUnitsTable implements SqliteTable {
  static final SubcategoriesUnitsTableSqlite _instance = SubcategoriesUnitsTableSqlite._internal();

  factory SubcategoriesUnitsTableSqlite() => _instance;

  SubcategoriesUnitsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${subcategoryId} INTEGER NOT NULL,
        ${unitId} INTEGER NOT NULL,
        ${propertyId} INTEGER NOT NULL,
        FOREIGN KEY (${subcategoryId}) REFERENCES ${SubcategoriesTable().tableName} (${SubcategoriesTable().id}) ON DELETE CASCADE,
        FOREIGN KEY (${propertyId}) REFERENCES ${CategoryPropertiesTable().tableName} (${CategoryPropertiesTable().id}),
        FOREIGN KEY (${unitId}) REFERENCES ${UnitsTable().tableName} (${UnitsTable().id}) ON DELETE CASCADE
      )
  ''';
}
