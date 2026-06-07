import 'package:sqlite3/sqlite3.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';

/// Creates SQLite triggers that keep sub-account and main-account balances
/// in sync with journal item inserts, updates, and deletes.
final class JournalItemsBalanceTrigger {
  const JournalItemsBalanceTrigger._();

  static void call(Database db) {
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS journal_items_after_insert_balance
      AFTER INSERT ON ${JournalItemsTable.tableName}
      BEGIN
        UPDATE ${SubAccountsTable.tableName}
        SET ${SubAccountsTable.debitBalance} = ${SubAccountsTable.debitBalance} + NEW.${JournalItemsTable.debit} * NEW.${JournalItemsTable.exPrice},
            ${SubAccountsTable.creditBalance} = ${SubAccountsTable.creditBalance} + NEW.${JournalItemsTable.credit} * NEW.${JournalItemsTable.exPrice}
        WHERE ${SubAccountsTable.id} = NEW.${JournalItemsTable.accountId};

        UPDATE ${MainAccountsTable.tableName}
        SET ${MainAccountsTable.debitBalance} = ${MainAccountsTable.debitBalance} + NEW.${JournalItemsTable.debit} * NEW.${JournalItemsTable.expriceMain},
            ${MainAccountsTable.creditBalance} = ${MainAccountsTable.creditBalance} + NEW.${JournalItemsTable.credit} * NEW.${JournalItemsTable.expriceMain}
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
        SET ${SubAccountsTable.debitBalance} = ${SubAccountsTable.debitBalance} - (OLD.${JournalItemsTable.debit} * OLD.${JournalItemsTable.exPrice}),
            ${SubAccountsTable.creditBalance} = ${SubAccountsTable.creditBalance} - (OLD.${JournalItemsTable.credit} * OLD.${JournalItemsTable.exPrice})
        WHERE ${SubAccountsTable.id} = OLD.${JournalItemsTable.accountId};

        UPDATE ${MainAccountsTable.tableName}
        SET ${MainAccountsTable.debitBalance} = ${MainAccountsTable.debitBalance} - (OLD.${JournalItemsTable.debit} * OLD.${JournalItemsTable.expriceMain}),
            ${MainAccountsTable.creditBalance} = ${MainAccountsTable.creditBalance} - (OLD.${JournalItemsTable.credit} * OLD.${JournalItemsTable.expriceMain})
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
        SET ${SubAccountsTable.debitBalance} = ${SubAccountsTable.debitBalance} - (OLD.${JournalItemsTable.debit} * OLD.${JournalItemsTable.exPrice}),
            ${SubAccountsTable.creditBalance} = ${SubAccountsTable.creditBalance} - (OLD.${JournalItemsTable.credit} * OLD.${JournalItemsTable.exPrice})
        WHERE ${SubAccountsTable.id} = OLD.${JournalItemsTable.accountId};

        UPDATE ${MainAccountsTable.tableName}
        SET ${MainAccountsTable.debitBalance} = ${MainAccountsTable.debitBalance} - (OLD.${JournalItemsTable.debit} * OLD.${JournalItemsTable.expriceMain}),
            ${MainAccountsTable.creditBalance} = ${MainAccountsTable.creditBalance} - (OLD.${JournalItemsTable.credit} * OLD.${JournalItemsTable.expriceMain})
        WHERE ${MainAccountsTable.id} = (
          SELECT ${SubAccountsTable.mainAccountId}
          FROM ${SubAccountsTable.tableName}
          WHERE ${SubAccountsTable.id} = OLD.${JournalItemsTable.accountId}
          LIMIT 1
        );

        UPDATE ${SubAccountsTable.tableName}
        SET ${SubAccountsTable.debitBalance} = ${SubAccountsTable.debitBalance} + (NEW.${JournalItemsTable.debit} * NEW.${JournalItemsTable.exPrice}),
            ${SubAccountsTable.creditBalance} = ${SubAccountsTable.creditBalance} + (NEW.${JournalItemsTable.credit} * NEW.${JournalItemsTable.exPrice})
        WHERE ${SubAccountsTable.id} = NEW.${JournalItemsTable.accountId};

        UPDATE ${MainAccountsTable.tableName}
        SET ${MainAccountsTable.debitBalance} = ${MainAccountsTable.debitBalance} + (NEW.${JournalItemsTable.debit} * NEW.${JournalItemsTable.expriceMain}),
            ${MainAccountsTable.creditBalance} = ${MainAccountsTable.creditBalance} + (NEW.${JournalItemsTable.credit} * NEW.${JournalItemsTable.expriceMain})
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
