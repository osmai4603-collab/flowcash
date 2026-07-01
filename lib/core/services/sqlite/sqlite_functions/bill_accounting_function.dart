import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/features/currencies/data/datasources/exchange_price_data_source.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_repository.dart';
import 'package:sqlite3/sqlite3.dart';

/// Class responsible for registering and handling the accounting post trigger.
final class BillAccountingFunction {
  const BillAccountingFunction._();

  /// Registers the custom Dart function and the SQLite trigger.
  static void setup(
    Database db,
    BillRepository repository,
    ExchangePriceDataSource exPriceDataSource,
  ) {
    // 1. Register the custom Dart function
    db.createFunction(
      name: 'dart_post_bill_to_accounting',
      argumentCount: const AllowedArgumentCount(2),
      function: (args) {
        final billId = args[0] as int;
        final userId = args[1] as int;

        // Execute the accounting post asynchronously in the background
        _executeAccountingPost(billId, userId, repository, exPriceDataSource);

        return null;
      },
    );

    // 2. Create the SQLite Trigger
    db.execute('DROP TRIGGER IF EXISTS trg_bills_accounting_sync');
    db.execute('''
      CREATE TRIGGER trg_bills_accounting_sync
      AFTER INSERT ON ${BillsTable().tableName}
      FOR EACH ROW
      WHEN NEW.${BillsTable().journalEntryId} IS NULL OR NEW.${BillsTable().journalEntryId} = 0
      BEGIN
        SELECT dart_post_bill_to_accounting(NEW.${BillsTable().id}, NEW.${BillsTable().createdBy});
      END;
    ''');
  }

  /// Handles the actual accounting post logic.
  static Future<void> _executeAccountingPost(
    int billId,
    int userId,
    BillRepository repository,
    ExchangePriceDataSource exPriceDataSource,
  ) async {
    try {
      // Fetch the bill by ID
      final billResult = await repository.getById(billId);
      final bill = billResult.getOrElse((_) => null);

      // Check if bill exists and is not already posted
      if (bill == null ||
          (bill.journalEntryId != null && bill.journalEntryId! > 0)) {
        return;
      }

      // Fetch exchange rates
      final exPrices = await exPriceDataSource.get();

      // Perform the accounting post
      final postResult = await repository.postToAccounting(
        bill: bill,
        userId: userId,
        currencyId: bill.currencyId,
        exPrices: exPrices,
      );

      postResult.fold(
        (failure) => print('Accounting Post Failed: ${failure.message}'),
        (updatedBill) => print(
          'Accounting Post Successful for Bill ID: ${updatedBill.id}',
        ),
      );
    } catch (e) {
      print('Critical Error in Bill Accounting Trigger: $e');
    }
  }
}
