import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول الكميات الإفتتاحية.
class OpeningQuantitiesTable extends TableById {
  static final OpeningQuantitiesTable _instance = OpeningQuantitiesTable.internal();

  factory OpeningQuantitiesTable() => _instance;

  OpeningQuantitiesTable.internal();

  @override
  final String tableName = 'opening_quantities';

  final String id = 'opening_id';
  final String inventoryId = 'inventory_id';
  final String countUnits = 'count_units';
  final String createdAt = 'create_at';
  final String costTotal = 'cost_total';
  final String periodId = 'period_id';
  final String currencyId = 'currency_id';
  final String journalEntryId = 'journal_entry_id';

  @override
  List<String> get columns => [id,
    inventoryId,
    countUnits,
    createdAt,
    costTotal,
    periodId,
    currencyId,
    journalEntryId,];
}
