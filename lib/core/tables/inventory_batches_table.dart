/// ثوابت جدول دفعات المخزون.
class InventoryBatchesTable {
  const InventoryBatchesTable._();

  static const String tableName = 'inventory_batches';

  static const String id = 'batch_id';
  static const String batchNumber = 'batch_number';
  static const String inventoryId = 'inventory_id';
  static const String personId = 'person_id';
  static const String batchSource = 'batch_source';
  static const String batchStatus = 'batch_status';
  static const String countUnits = 'count_units';
  static const String unitCost = 'unit_cost';
  static const String inputDate = 'input_date';
  static const String productionDate = 'production_date';
  static const String expirationDate = 'expiration_date';

  static const List<String> fields = [
    id,
    batchNumber,
    inventoryId,
    personId,
    batchSource,
    batchStatus,
    countUnits,
    unitCost,
    inputDate,
    productionDate,
    expirationDate,
  ];
}
