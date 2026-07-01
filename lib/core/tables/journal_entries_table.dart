import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول قيود اليومية.
class JournalEntriesTable extends TableById {
  static final JournalEntriesTable _instance = JournalEntriesTable.internal();

  factory JournalEntriesTable() => _instance;

  JournalEntriesTable.internal();

  @override
  final String tableName = 'journal_entries';

  final String id = 'entry_id';
  final String referenceNumber = 'reference_number';
  final String description = 'description';
  final String createdAt = 'created_at';
  final String userId = 'user_id';
  final String currencyId = 'currency_id';
  final String amount = 'amount';
  final String warehouseId = 'warehouse_id';

  @override
  List<String> get columns => [id,
    referenceNumber,
    description,
    createdAt,
    userId,
    currencyId,
    amount,
    warehouseId,];
}
