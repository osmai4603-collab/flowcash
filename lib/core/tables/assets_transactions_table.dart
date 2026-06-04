/// ثوابت جدول حركات الأصول.
class AssetsTransactionsTable {
  const AssetsTransactionsTable._();

  static const String tableName = 'assets_transactions';

  static const String id = 'asset_id';
  static const String createdAt = 'create_at';
  static const String createdBy = 'created_by';
  static const String note = 'note';
  static const String offerAmount = 'amount';
  static const String currencyId = 'currency_id';
  static const String billNumber = 'bill_number';
  static const String warehouseId = 'warehouse_id';
  static const String journalEntryId = 'journal_entry_id';
  static const String hintId = 'hint_id';
  static const String historyGroup = 'history_group';

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
    hintId,
    historyGroup,
  ];
}
