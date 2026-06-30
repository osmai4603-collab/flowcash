import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/main_categories_table.dart';

class MainCategoriesTableSqlite extends MainCategoriesTable
    implements SqliteTable {
  static final MainCategoriesTableSqlite _instance =
      MainCategoriesTableSqlite._internal();

  factory MainCategoriesTableSqlite() => _instance;

  MainCategoriesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable =>
      '''
CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        $categoryName TEXT NOT NULL,
        $categoryType TEXT NOT NULL,
        $categoryUnitId INTEGER NOT NULL,
        FOREIGN KEY($categoryUnitId) REFERENCES units(unit_id)
      )
  ''';
}
