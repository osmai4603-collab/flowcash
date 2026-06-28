import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/tables/catalogs_table.dart';

class V5Migration extends SqliteMigration {
  @override
  int get version => 5;

  @override
  void execute(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS categories_new (
        ${CategoriesTable().id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CategoriesTable().categoryType} TEXT NOT NULL,
        ${CategoriesTable().categoryName} TEXT NOT NULL,
        ${CategoriesTable().categoryNumber} TEXT NOT NULL,
        ${CategoriesTable().barcode} TEXT,
        ${CategoriesTable().categoryUnitId} INTEGER,
        ${CategoriesTable().pricingUnitId} INTEGER,
        ${CategoriesTable().inventoryUnitId} INTEGER,
        ${CategoriesTable().subcategoryId} INTEGER,
        FOREIGN KEY (${CategoriesTable().categoryUnitId}) REFERENCES ${UnitsTable().tableName} (${UnitsTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable().pricingUnitId}) REFERENCES ${UnitsTable().tableName} (${UnitsTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable().inventoryUnitId}) REFERENCES ${UnitsTable().tableName} (${UnitsTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${CategoriesTable().subcategoryId}) REFERENCES ${SubcategoriesTable().tableName} (${SubcategoriesTable().id}) ON DELETE SET NULL
      )
    ''');

    db.execute('''
      INSERT INTO categories_new (
        ${CategoriesTable().id},
        ${CategoriesTable().categoryType},
        ${CategoriesTable().categoryName},
        ${CategoriesTable().categoryNumber},
        ${CategoriesTable().barcode},
        ${CategoriesTable().categoryUnitId},
        ${CategoriesTable().pricingUnitId},
        ${CategoriesTable().inventoryUnitId}
      )
      SELECT 
        ${CategoriesTable().id},
        ${CategoriesTable().categoryType},
        ${CategoriesTable().categoryName},
        ${CategoriesTable().categoryNumber},
        ${CategoriesTable().barcode},
        ${CategoriesTable().categoryUnitId},
        ${CategoriesTable().pricingUnitId},
        ${CategoriesTable().inventoryUnitId}
      FROM ${CategoriesTable().tableName}
    ''');

    db.execute('DROP TABLE ${CategoriesTable().tableName}');
    db.execute(
      'ALTER TABLE categories_new RENAME TO ${CategoriesTable().tableName}',
    );
  }
}
