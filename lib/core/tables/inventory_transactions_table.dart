/// ثوابت جدول الحركات المخزنية.
class InventoryTransactionsTable {
  const InventoryTransactionsTable._();

  static const String tableName = 'inventory_transactions';

  static const String id = 'tran_id';
  static const String createAt = 'create_at';
  static const String createdBy = 'created_by';
  static const String note = 'note';
  static const String warehouseId = 'store_id';
  static const String personId = 'person_id';
  static const String billNumber = 'bill_number';
  static const String transactionType = 'tran_type';

  static const List<String> fields = [
    id,
    createAt,
    createdBy,
    note,
    warehouseId,
    personId,
    billNumber,
    transactionType,
  ];
}
