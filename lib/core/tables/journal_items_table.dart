import 'package:flowcash/core/services/sqlite/table_by_id.dart';

/// ثوابت جدول بنود قيود اليومية.
class JournalItemsTable extends TableById {
  static final JournalItemsTable _instance = JournalItemsTable.internal();

  factory JournalItemsTable() => _instance;

  JournalItemsTable.internal();

  @override
  final String tableName = 'journal_items';

  @override
  final String id = 'item_id';
  final String entryId = 'entry_id';
  final String accountId = 'account_id';
  final String amount = 'amount';
  final String lineDescription = 'line_description';
  final String currencyId = 'currency_id';
  final String exPrice = 'ex_price';
  final String exPriceMain = 'exprice_main';
  final String journalStatus = 'journal_status';

  @override
  List<String> get columns => [
    id,
    entryId,
    accountId,
    amount,
    lineDescription,
    currencyId,
    exPrice,
    exPriceMain,
    journalStatus,
  ];
}
