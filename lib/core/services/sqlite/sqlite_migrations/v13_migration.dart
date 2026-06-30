import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';

class V13Migration extends SqliteMigration {
  @override
  int get version => 13;

  @override
  void execute(Database db) {
    // 1. Add the category_unit_id column to main_categories table.
    // We set a default of 1 (pointing to 'حبة' / piece) for existing rows.
    db.execute(
      'ALTER TABLE main_categories ADD COLUMN category_unit_id INTEGER NOT NULL DEFAULT 1',
    );

    // 2. Drop unit_type and unit_name columns
    db.execute('ALTER TABLE main_categories DROP COLUMN unit_type');
    db.execute('ALTER TABLE main_categories DROP COLUMN unit_name');
  }
}
