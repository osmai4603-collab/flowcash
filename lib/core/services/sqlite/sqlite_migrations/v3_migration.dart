import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/services/sqlite/sqlite_schema_manager.dart';

class V3Migration extends SqliteMigration {
  @override
  int get version => 3;

  @override
  void execute(Database db) {
    db.execute(
      'ALTER TABLE ${InventoriesTable().tableName} ADD COLUMN ${InventoriesTable().userId} INTEGER NOT NULL DEFAULT 1',
    );
    SqliteSchemaManager.createTriggers(db);
  }
}
