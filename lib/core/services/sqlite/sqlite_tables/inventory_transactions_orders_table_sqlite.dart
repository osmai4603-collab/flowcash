import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_orders_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';

class InventoryTransactionsOrdersTableSqlite extends InventoryTransactionsOrdersTable implements SqliteTable {
  static final InventoryTransactionsOrdersTableSqlite _instance = InventoryTransactionsOrdersTableSqlite._internal();

  factory InventoryTransactionsOrdersTableSqlite() => _instance;

  InventoryTransactionsOrdersTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${inventoryId} INTEGER,
        ${countUnits} REAL NOT NULL DEFAULT 0.0,
        ${tranId} INTEGER NOT NULL,
        FOREIGN KEY (${inventoryId}) REFERENCES ${InventoriesTable().tableName} (${InventoriesTable().id}) ON DELETE SET NULL,
        FOREIGN KEY (${tranId}) REFERENCES ${InventoryTransactionsTable().tableName} (${InventoryTransactionsTable().id}) ON DELETE CASCADE
      )
  ''';
}
