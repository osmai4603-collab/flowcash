import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/persons_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';

class PersonsTableSqlite extends PersonsTable implements SqliteTable {
  static final PersonsTableSqlite _instance = PersonsTableSqlite._internal();

  factory PersonsTableSqlite() => _instance;

  PersonsTableSqlite._internal() : super.internal();

  @override
  String get queryCreateTable => '''
CREATE TABLE IF NOT EXISTS ${tableName} (
        ${id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${personName} TEXT NOT NULL,
        ${phoneNumber} TEXT,
        ${address} TEXT,
        ${email} TEXT,
        ${personType} INTEGER NOT NULL,
        ${receivableAccountId} INTEGER,
        ${payableAccountId} INTEGER,
        ${createdAt} TEXT,
        UNIQUE (${personName}, ${personType}),
        FOREIGN KEY (${receivableAccountId}) REFERENCES ${SubAccountsTable().tableName} (${SubAccountsTable().id}) ON UPDATE CASCADE ON DELETE SET NULL,
        FOREIGN KEY (${payableAccountId}) REFERENCES ${SubAccountsTable().tableName} (${SubAccountsTable().id}) ON UPDATE CASCADE ON DELETE SET NULL
      )
  ''';
}
