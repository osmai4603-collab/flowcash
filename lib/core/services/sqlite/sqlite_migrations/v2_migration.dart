import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';
import 'package:flowcash/core/tables/inventories_table.dart';

class V2Migration extends SqliteMigration {
  @override
  int get version => 2;

  @override
  void execute(Database db) {
    db.execute(
      'ALTER TABLE ${InventoriesTable().tableName} ADD COLUMN ${InventoriesTable().propertyAccountId} INTEGER NOT NULL DEFAULT 0',
    );
  }
}
