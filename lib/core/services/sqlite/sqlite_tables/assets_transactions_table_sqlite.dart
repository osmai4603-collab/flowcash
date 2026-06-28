import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/assets_transactions_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/tables/hints_table.dart';

class AssetsTransactionsTableSqlite extends AssetsTransactionsTable implements SqliteTable {
  static final AssetsTransactionsTableSqlite _instance = AssetsTransactionsTableSqlite._internal();

  factory AssetsTransactionsTableSqlite() => _instance;

  AssetsTransactionsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${createdAt} TEXT NOT NULL,
        ${createdBy} INTEGER NOT NULL,
        ${note} TEXT,
        ${offerAmount} REAL NOT NULL,
        ${currencyId} TEXT NOT NULL,
        ${billNumber} INTEGER NOT NULL,
        ${warehouseId} INTEGER NOT NULL,
        ${journalEntryId} INTEGER,
        ${hintId} INTEGER NOT NULL,
        ${historyGroup} TEXT,
        FOREIGN KEY (${createdBy}) REFERENCES ${ProgramUsersTable().tableName} (${ProgramUsersTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${currencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${warehouseId}) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${hintId}) REFERENCES ${HintsTable().tableName} (${HintsTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
  ''';
}
