import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';
import 'package:flowcash/core/tables/categories_attributes_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/catalog_infos_table.dart';

class V9Migration extends SqliteMigration {
  @override
  int get version => 9;

  @override
  void execute(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS ${CategoriesAttributesTable().tableName} (
        ${CategoriesAttributesTable().id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${CategoriesAttributesTable().categoryId} INTEGER NOT NULL,
        ${CategoriesAttributesTable().subcategoryUnitId} INTEGER NOT NULL,
        FOREIGN KEY (${CategoriesAttributesTable().categoryId}) REFERENCES ${CategoriesTable().tableName} (${CategoriesTable().id}) ON DELETE CASCADE,
        FOREIGN KEY (${CategoriesAttributesTable().subcategoryUnitId}) REFERENCES ${SubcategoriesUnitsTable().tableName} (${SubcategoriesUnitsTable().id}) ON DELETE CASCADE
      )
    ''');
  }
}
