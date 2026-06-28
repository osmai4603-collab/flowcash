import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/bill_orders_table.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';

class BillOrdersTableSqlite extends BillOrdersTable implements SqliteTable {
  static final BillOrdersTableSqlite _instance = BillOrdersTableSqlite._internal();

  factory BillOrdersTableSqlite() => _instance;

  BillOrdersTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${billId} INTEGER NOT NULL,
        ${categoryId} INTEGER NOT NULL,
        ${countUnits} REAL NOT NULL DEFAULT 0.0,
        ${totalPrice} REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (${billId}) REFERENCES ${BillsTable().tableName} (${BillsTable().id}) ON DELETE CASCADE,
        FOREIGN KEY (${categoryId}) REFERENCES ${CategoriesTable().tableName} (${CategoriesTable().id}) ON DELETE RESTRICT
      )
  ''';
}
