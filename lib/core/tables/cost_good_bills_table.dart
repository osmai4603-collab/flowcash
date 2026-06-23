/// ثوابت جدول تكلفة الفواتير المباعة.
class CostGoodBillsTable {
  const CostGoodBillsTable._();

  static const String tableName = 'cost_good_bills';

  static const String id = 'cost_good_bill_id';
  static const String createdAt = 'create_at';
  static const String createdBy = 'create_by';
  static const String note = 'note';
  static const String offerAmount = 'amount';
  static const String currencyId = 'currency_id';
  static const String billNumber = 'bill_number';
  static const String warehouseId = 'warehouse_id';
  static const String journalEntryId = 'journal_entry_id';
  static const String personId = 'person_id';
  static const String billId = 'bill_id';

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
    billId,
  ];
}
