import 'package:flowcash/core/enums/inventory_transaction_nature_enum.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/inventory_transactions_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/persons_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';

class InventoryTransactionsTableSqlite extends InventoryTransactionsTable
    implements SqliteTable {
  static final InventoryTransactionsTableSqlite _instance =
      InventoryTransactionsTableSqlite._internal();

  factory InventoryTransactionsTableSqlite() => _instance;

  InventoryTransactionsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable =>
      '''
CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        $createdAt TEXT NOT NULL,
        $createdBy INTEGER NOT NULL,
        $note TEXT,
        $warehouseId INTEGER NOT NULL,
        $personId INTEGER,
        $billNumber INTEGER NOT NULL,
        $transactionType TEXT NOT NULL CHECK($transactionType IN (${InventoryTransactionType.values.map((e) => "'${e.name}'").join(', ')})),
        $transactionNature TEXT NOT NULL CHECK($transactionNature IN (${InventoryTransactionNature.values.map((e) => "'${e.name}'").join(', ')})),
        FOREIGN KEY ($personId) REFERENCES ${PersonsTable().tableName} (${PersonsTable().id}) ON DELETE SET NULL,
        FOREIGN KEY ($warehouseId) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY ($createdBy) REFERENCES ${ProgramUsersTable().tableName} (${ProgramUsersTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
  ''';
}
