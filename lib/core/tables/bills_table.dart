/// ثوابت جدول الفواتير.
class BillsTable {
  const BillsTable._();

  static const String tableName = 'bills';

  static const String id = 'bill_id';
  static const String createdAt = 'create_at';
  static const String createdBy = 'create_by';
  static const String note = 'note';
  static const String offerAmount = 'amount';
  static const String currencyId = 'currency_id';
  static const String billNumber = 'bill_number';
  static const String warehouseId = 'warehouse_id';
  static const String journalEntryId = 'journal_entry_id';
  static const String personId = 'person_id';
  static const String inventoryTransactionId = 'inventory_transaction_id';
  static const String isCash = 'is_cash';
  static const String billType = 'bill_type';
  static const String costGoodId = 'cost_good_id';
  static const String treasuryId = 'treasury_id';

  static const List<String> fields = [
    id,
    createdAt,
    createdBy,
    note,
    offerAmount,
    currencyId,
    billNumber,
    warehouseId,
    journalEntryId,
    personId,
    inventoryTransactionId,
    isCash,
    billType,
    costGoodId,
    treasuryId,
  ];
}
