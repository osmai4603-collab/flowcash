import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';

class V12Migration extends SqliteMigration {
  @override
  int get version => 12;

  @override
  void execute(Database db) {
    // 1. Add the column with a default value of 'sales' to satisfy NOT NULL
    db.execute("ALTER TABLE inventory_transactions ADD COLUMN tran_nature TEXT NOT NULL DEFAULT 'sales'");

    // 2. Update existing inward transactions to have a 'purchases' nature
    db.execute("UPDATE inventory_transactions SET tran_nature = 'purchases' WHERE tran_type = 'import_inventory'");
  }
}
