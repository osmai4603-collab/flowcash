import 'package:flowcash/core/services/sqlite/table_info.dart';

/// ثوابت جدول بنود قيود اليومية.
class JournalItemsTable extends TableInfo {
  static final JournalItemsTable _instance = JournalItemsTable.internal();

  factory JournalItemsTable() => _instance;

  JournalItemsTable.internal();

  @override
  final String tableName = 'journal_items';

  final String itemId = 'item_id';
  final String entryId = 'entry_id';
  final String accountId = 'account_id';
  final String amount = 'amount';
  final String lineDescription = 'line_description';
  final String currencyId = 'currency_id';
  final String exPrice = 'ex_price';
  final String exPriceMain = 'exprice_main';
  final String journalStatus = 'journal_status';

  @override
  List<String> get columns => [itemId,
    entryId,
    accountId,
    amount,
    lineDescription,
    currencyId,
    exPrice,
    exPriceMain,
    journalStatus,];
}
