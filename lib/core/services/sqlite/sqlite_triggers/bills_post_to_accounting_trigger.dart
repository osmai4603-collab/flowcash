import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/tables/bills_table.dart';

/// Trigger that posts a bill to accounting when the bill gets linked to
/// a journal entry for the first time.
final class BillsPostToAccountingTrigger {
  const BillsPostToAccountingTrigger._();

  static void call(Database db) {
    final billsTable = BillsTable();
    db.execute('DROP TRIGGER IF EXISTS bills_after_insert_post_to_accounting');
    db.execute('DROP TRIGGER IF EXISTS bills_after_update_post_to_accounting');

    db.execute('''
      CREATE TRIGGER IF NOT EXISTS bills_after_update_post_to_accounting
      AFTER UPDATE OF ${billsTable.journalEntryId} ON ${billsTable.tableName}
      WHEN OLD.${billsTable.journalEntryId} IS NULL
        AND NEW.${billsTable.journalEntryId} IS NOT NULL
      BEGIN
        SELECT post_bill_to_accounting(NEW.${billsTable.id});
      END;
    ''');
  }
}
