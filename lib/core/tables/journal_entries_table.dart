/// ثوابت جدول قيود اليومية.
class JournalEntriesTable {
  const JournalEntriesTable._();

  static const String tableName = 'journal_entries';

  static const String entryId = 'entry_id';
  static const String referenceNumber = 'reference_number';
  static const String description = 'description';
  static const String createdAt = 'created_at';
  static const String userId = 'user_id';
  static const String currencyId = 'currency_id';
  static const String exPrice = 'ex_price';
  static const String baseAmount = 'base_amount';
  static const String warehouseId = 'warehouse_id';

  static const List<String> fields = [
    entryId,
    referenceNumber,
    description,
    createdAt,
    userId,
    currencyId,
    exPrice,
    baseAmount,
    warehouseId,
  ];
}
