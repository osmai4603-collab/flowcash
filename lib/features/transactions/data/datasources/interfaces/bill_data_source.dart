import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';

abstract interface class BillDataSource
    implements AppDataSource<int, BillEntity, Map<String, dynamic>> {
  Future<List<BillEntity>> whereHasNotGoneInStore({
    bool trigger = false,
    bool printQuery = true,
  });

  Future<List<Map<String, dynamic>>> getBillsWithCustomer();

  Future<bool> updateJournalEntry({required int id, required int journalEntryId});

  Future<bool> updateInventoryTransaction({required int id, required int inventoryTransactionId});

  Future<bool> updateBillCosting({required int id, required int costId});
}
