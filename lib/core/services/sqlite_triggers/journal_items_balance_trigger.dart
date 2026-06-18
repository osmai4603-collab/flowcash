import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';

/// Creates SQLite triggers that keep sub-account and main-account balances
/// in sync with journal item inserts, updates, and deletes.
final class JournalItemsBalanceTrigger {
  const JournalItemsBalanceTrigger._();

  static void call(Database db) {
    db.execute('DROP TRIGGER IF EXISTS journal_items_after_insert_balance');
    db.execute('DROP TRIGGER IF EXISTS journal_items_after_delete_balance');
    db.execute('DROP TRIGGER IF EXISTS journal_items_after_update_balance');

    db.execute('''
      CREATE TRIGGER IF NOT EXISTS journal_items_after_insert_balance
      AFTER INSERT ON ${JournalItemsTable.tableName}
      BEGIN
        UPDATE ${SubAccountsTable.tableName}
        SET ${SubAccountsTable.incrementBalance} = ${SubAccountsTable.incrementBalance} + CASE WHEN NEW.${JournalItemsTable.journalStatus} = 'increment' THEN NEW.${JournalItemsTable.amount} * NEW.${JournalItemsTable.exPrice} ELSE 0 END,
            ${SubAccountsTable.decrementBalance} = ${SubAccountsTable.decrementBalance} + CASE WHEN NEW.${JournalItemsTable.journalStatus} = 'decrement' THEN NEW.${JournalItemsTable.amount} * NEW.${JournalItemsTable.exPrice} ELSE 0 END
        WHERE ${SubAccountsTable.id} = NEW.${JournalItemsTable.accountId};

        UPDATE ${MainAccountsTable.tableName}
        SET ${MainAccountsTable.debitBalance} = ${MainAccountsTable.debitBalance} + CASE WHEN NEW.${JournalItemsTable.journalStatus} = 'increment' THEN NEW.${JournalItemsTable.amount} * NEW.${JournalItemsTable.exPriceMain} ELSE 0 END,
            ${MainAccountsTable.creditBalance} = ${MainAccountsTable.creditBalance} + CASE WHEN NEW.${JournalItemsTable.journalStatus} = 'decrement' THEN NEW.${JournalItemsTable.amount} * NEW.${JournalItemsTable.exPriceMain} ELSE 0 END
        WHERE ${MainAccountsTable.id} = (
          SELECT ${SubAccountsTable.mainAccountId}
          FROM ${SubAccountsTable.tableName}
          WHERE ${SubAccountsTable.id} = NEW.${JournalItemsTable.accountId}
          LIMIT 1
        );
      END;
    ''');

    db.execute('''
      CREATE TRIGGER IF NOT EXISTS journal_items_after_delete_balance
      AFTER DELETE ON ${JournalItemsTable.tableName}
      BEGIN
        UPDATE ${SubAccountsTable.tableName}
        SET ${SubAccountsTable.incrementBalance} = ${SubAccountsTable.incrementBalance} - CASE WHEN OLD.${JournalItemsTable.journalStatus} = 'increment' THEN OLD.${JournalItemsTable.amount} * OLD.${JournalItemsTable.exPrice} ELSE 0 END,
            ${SubAccountsTable.decrementBalance} = ${SubAccountsTable.decrementBalance} - CASE WHEN OLD.${JournalItemsTable.journalStatus} = 'decrement' THEN OLD.${JournalItemsTable.amount} * OLD.${JournalItemsTable.exPrice} ELSE 0 END
        WHERE ${SubAccountsTable.id} = OLD.${JournalItemsTable.accountId};

        UPDATE ${MainAccountsTable.tableName}
        SET ${MainAccountsTable.debitBalance} = ${MainAccountsTable.debitBalance} - CASE WHEN OLD.${JournalItemsTable.journalStatus} = 'increment' THEN OLD.${JournalItemsTable.amount} * OLD.${JournalItemsTable.exPriceMain} ELSE 0 END,
            ${MainAccountsTable.creditBalance} = ${MainAccountsTable.creditBalance} - CASE WHEN OLD.${JournalItemsTable.journalStatus} = 'decrement' THEN OLD.${JournalItemsTable.amount} * OLD.${JournalItemsTable.exPriceMain} ELSE 0 END
        WHERE ${MainAccountsTable.id} = (
          SELECT ${SubAccountsTable.mainAccountId}
          FROM ${SubAccountsTable.tableName}
          WHERE ${SubAccountsTable.id} = OLD.${JournalItemsTable.accountId}
          LIMIT 1
        );
      END;
    ''');

    db.execute('''
      CREATE TRIGGER IF NOT EXISTS journal_items_after_update_balance
      AFTER UPDATE ON ${JournalItemsTable.tableName}
      BEGIN
        UPDATE ${SubAccountsTable.tableName}
        SET ${SubAccountsTable.incrementBalance} = ${SubAccountsTable.incrementBalance} - CASE WHEN OLD.${JournalItemsTable.journalStatus} = 'increment' THEN OLD.${JournalItemsTable.amount} * OLD.${JournalItemsTable.exPrice} ELSE 0 END,
            ${SubAccountsTable.decrementBalance} = ${SubAccountsTable.decrementBalance} - CASE WHEN OLD.${JournalItemsTable.journalStatus} = 'decrement' THEN OLD.${JournalItemsTable.amount} * OLD.${JournalItemsTable.exPrice} ELSE 0 END
        WHERE ${SubAccountsTable.id} = OLD.${JournalItemsTable.accountId};

        UPDATE ${MainAccountsTable.tableName}
        SET ${MainAccountsTable.debitBalance} = ${MainAccountsTable.debitBalance} - CASE WHEN OLD.${JournalItemsTable.journalStatus} = 'increment' THEN OLD.${JournalItemsTable.amount} * OLD.${JournalItemsTable.exPriceMain} ELSE 0 END,
            ${MainAccountsTable.creditBalance} = ${MainAccountsTable.creditBalance} - CASE WHEN OLD.${JournalItemsTable.journalStatus} = 'decrement' THEN OLD.${JournalItemsTable.amount} * OLD.${JournalItemsTable.exPriceMain} ELSE 0 END
        WHERE ${MainAccountsTable.id} = (
          SELECT ${SubAccountsTable.mainAccountId}
          FROM ${SubAccountsTable.tableName}
          WHERE ${SubAccountsTable.id} = OLD.${JournalItemsTable.accountId}
          LIMIT 1
        );

        UPDATE ${SubAccountsTable.tableName}
        SET ${SubAccountsTable.incrementBalance} = ${SubAccountsTable.incrementBalance} + CASE WHEN NEW.${JournalItemsTable.journalStatus} = 'increment' THEN NEW.${JournalItemsTable.amount} * NEW.${JournalItemsTable.exPrice} ELSE 0 END,
            ${SubAccountsTable.decrementBalance} = ${SubAccountsTable.decrementBalance} + CASE WHEN NEW.${JournalItemsTable.journalStatus} = 'decrement' THEN NEW.${JournalItemsTable.amount} * NEW.${JournalItemsTable.exPrice} ELSE 0 END
        WHERE ${SubAccountsTable.id} = NEW.${JournalItemsTable.accountId};

        UPDATE ${MainAccountsTable.tableName}
        SET ${MainAccountsTable.debitBalance} = ${MainAccountsTable.debitBalance} + CASE WHEN NEW.${JournalItemsTable.journalStatus} = 'increment' THEN NEW.${JournalItemsTable.amount} * NEW.${JournalItemsTable.exPriceMain} ELSE 0 END,
            ${MainAccountsTable.creditBalance} = ${MainAccountsTable.creditBalance} + CASE WHEN NEW.${JournalItemsTable.journalStatus} = 'decrement' THEN NEW.${JournalItemsTable.amount} * NEW.${JournalItemsTable.exPriceMain} ELSE 0 END
        WHERE ${MainAccountsTable.id} = (
          SELECT ${SubAccountsTable.mainAccountId}
          FROM ${SubAccountsTable.tableName}
          WHERE ${SubAccountsTable.id} = NEW.${JournalItemsTable.accountId}
          LIMIT 1
        );
      END;
    ''');
  }
}
