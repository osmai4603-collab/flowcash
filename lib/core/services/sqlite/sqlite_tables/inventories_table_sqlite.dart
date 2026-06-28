import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';

class InventoriesTableSqlite extends InventoriesTable implements SqliteTable {
  static final InventoriesTableSqlite _instance = InventoriesTableSqlite._internal();

  factory InventoriesTableSqlite() => _instance;

  InventoriesTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${categoryId} INTEGER NOT NULL,
        ${storeId} INTEGER NOT NULL,
        ${propertyAccountId} INTEGER NOT NULL DEFAULT 0,
        ${revenueAccountId} INTEGER NOT NULL,
        ${expenseAccountId} INTEGER NOT NULL,
        ${incomeStockId} INTEGER NOT NULL,
        ${outcomeStockId} INTEGER NOT NULL,
        ${costTotal} REAL NOT NULL DEFAULT 0.0,
        ${countUnits} REAL NOT NULL DEFAULT 0.0,
        ${userId} INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (${storeId}) REFERENCES ${WarehousesTable().tableName} (${WarehousesTable().id}) ON DELETE RESTRICT,
        FOREIGN KEY (${propertyAccountId}) REFERENCES ${SubAccountsTable().tableName} (${SubAccountsTable().id}) ON DELETE RESTRICT,
        FOREIGN KEY (${revenueAccountId}) REFERENCES ${SubAccountsTable().tableName} (${SubAccountsTable().id}) ON DELETE RESTRICT,
        FOREIGN KEY (${expenseAccountId}) REFERENCES ${SubAccountsTable().tableName} (${SubAccountsTable().id}) ON DELETE RESTRICT,
        FOREIGN KEY (${incomeStockId}) REFERENCES ${SubAccountsTable().tableName} (${SubAccountsTable().id}) ON DELETE RESTRICT,
        FOREIGN KEY (${outcomeStockId}) REFERENCES ${SubAccountsTable().tableName} (${SubAccountsTable().id}) ON DELETE RESTRICT,
        FOREIGN KEY (${categoryId}) REFERENCES ${CategoriesTable().tableName} (${CategoriesTable().id}) ON DELETE RESTRICT,
        FOREIGN KEY (${userId}) REFERENCES ${ProgramUsersTable().tableName} (${ProgramUsersTable().id}) ON DELETE RESTRICT
      )
  ''';
}
