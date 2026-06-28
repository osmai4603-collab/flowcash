import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/financial_bonds_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/tables/hints_table.dart';

class FinancialBondsTableSqlite extends FinancialBondsTable implements SqliteTable {
  static final FinancialBondsTableSqlite _instance = FinancialBondsTableSqlite._internal();

  factory FinancialBondsTableSqlite() => _instance;

  FinancialBondsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${createdAt} TEXT NOT NULL,
        ${createdBy} INTEGER NOT NULL,
        ${note} TEXT,
        ${offerAmount} REAL NOT NULL CHECK(${offerAmount} > 0),
        ${currencyId} TEXT NOT NULL,
        ${billNumber} INTEGER NOT NULL CHECK(${billNumber} > 0),
        ${warehouseId} INTEGER NOT NULL,
        ${journalEntryId} INTEGER,
        ${hintId} INTEGER NOT NULL,
        ${bondType} TEXT NOT NULL CHECK(${bondType} IN ('proceeds', 'paids')),
        FOREIGN KEY (${createdBy}) REFERENCES ${ProgramUsersTable().tableName} (${ProgramUsersTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${currencyId}) REFERENCES ${CurrenciesTable().tableName} (${CurrenciesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${warehouseId}) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (${hintId}) REFERENCES ${HintsTable().tableName} (${HintsTable().id}) ON UPDATE CASCADE ON DELETE RESTRICT
      )
  ''';
}
