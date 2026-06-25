/// ثوابت جدول قيود اليومية.
class JournalEntriesTable {
  const JournalEntriesTable._();

  static const String tableName = 'journal_entries';

  static const String id = 'entry_id';
  static const String referenceNumber = 'reference_number';
  static const String description = 'description';
  static const String createdAt = 'created_at';
  static const String userId = 'user_id';
  static const String currencyId = 'currency_id';
  static const String amount = 'amount';
  static const String warehouseId = 'warehouse_id';

  static const List<String> fields = [
    id,
    referenceNumber,
    description,
    createdAt,
    userId,
    currencyId,
    amount,
    warehouseId,
  ];
}
