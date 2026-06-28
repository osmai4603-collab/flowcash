import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/catalogs_table.dart';
import 'package:flowcash/core/tables/units_table.dart';

class CategoriesTableSqlite extends CategoriesTable implements SqliteTable {
  static final CategoriesTableSqlite _instance = CategoriesTableSqlite._internal();

  factory CategoriesTableSqlite() => _instance;

  CategoriesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${categoryType} TEXT NOT NULL,
        ${categoryName} TEXT NOT NULL,
        ${categoryNumber} TEXT NOT NULL,
        ${barcode} TEXT,
        ${categoryUnitId} INTEGER,
        ${pricingUnitId} INTEGER,
        ${inventoryUnitId} INTEGER,
        ${subcategoryId} INTEGER,
        FOREIGN KEY (${categoryUnitId}) REFERENCES ${UnitsTable().tableName} (${UnitsTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${pricingUnitId}) REFERENCES ${UnitsTable().tableName} (${UnitsTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${inventoryUnitId}) REFERENCES ${UnitsTable().tableName} (${UnitsTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${subcategoryId}) REFERENCES ${SubcategoriesTable().tableName} (${SubcategoriesTable().id}) ON DELETE SET NULL
      )
  ''';
}
