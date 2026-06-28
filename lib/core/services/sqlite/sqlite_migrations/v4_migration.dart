import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';
import 'package:flowcash/core/tables/catalogs_table.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';

class V4Migration extends SqliteMigration {
  @override
  int get version => 4;

  @override
  void execute(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS subcategories_new (
        ${SubcategoriesTable().id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${SubcategoriesTable().mainCategoryId} INTEGER,
        ${SubcategoriesTable().catalogName} TEXT NOT NULL,
        ${SubcategoriesTable().catalogNumber} TEXT,
        UNIQUE (${SubcategoriesTable().catalogName}, ${SubcategoriesTable().mainCategoryId}),
        FOREIGN KEY (${SubcategoriesTable().mainCategoryId}) REFERENCES ${MainCategoriesTable().tableName} (${MainCategoriesTable().id}) ON DELETE SET NULL
      )
    ''');

    db.execute('''
      INSERT INTO subcategories_new (
        ${SubcategoriesTable().id},
        ${SubcategoriesTable().mainCategoryId},
        ${SubcategoriesTable().catalogName},
        ${SubcategoriesTable().catalogNumber}
      )
      SELECT 
        ${SubcategoriesTable().id},
        ${SubcategoriesTable().mainCategoryId},
        ${SubcategoriesTable().catalogName},
        ${SubcategoriesTable().catalogNumber}
      FROM ${SubcategoriesTable().tableName}
    ''');

    db.execute('DROP TABLE ${SubcategoriesTable().tableName}');
    db.execute(
      'ALTER TABLE subcategories_new RENAME TO ${SubcategoriesTable().tableName}',
    );
  }
}
