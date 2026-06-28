import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/catalogs_table.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';

class SubcategoriesTableSqlite extends SubcategoriesTable implements SqliteTable {
  static final SubcategoriesTableSqlite _instance = SubcategoriesTableSqlite._internal();

  factory SubcategoriesTableSqlite() => _instance;

  SubcategoriesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${mainCategoryId} INTEGER,
        ${catalogName} TEXT NOT NULL,
        ${catalogNumber} TEXT,
        UNIQUE (${catalogName}, ${mainCategoryId}),
        FOREIGN KEY (${mainCategoryId}) REFERENCES ${MainCategoriesTable().tableName} (${MainCategoriesTable().id}) ON DELETE RESTRICT
      )
  ''';
}
