import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/cost_good_bill_orders_table.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/core/tables/cost_good_bills_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';

class CostGoodBillOrdersTableSqlite extends CostGoodBillOrdersTable implements SqliteTable {
  static final CostGoodBillOrdersTableSqlite _instance = CostGoodBillOrdersTableSqlite._internal();

  factory CostGoodBillOrdersTableSqlite() => _instance;

  CostGoodBillOrdersTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${billId} INTEGER NOT NULL,
        ${categoryId} INTEGER NOT NULL,
        ${countUnits} REAL NOT NULL DEFAULT 0.0,
        ${totalPrice} REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (${billId}) REFERENCES ${CostGoodBillsTable().tableName} (${CostGoodBillsTable().id}) ON DELETE CASCADE,
        FOREIGN KEY (${categoryId}) REFERENCES ${CategoriesTable().tableName} (${CategoriesTable().id}) ON DELETE RESTRICT
      )
  ''';
}
