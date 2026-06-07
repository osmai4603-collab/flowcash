/// ثوابت جدول بنود قيود اليومية.
class JournalItemsTable {
  const JournalItemsTable._();

  static const String tableName = 'journal_items';

  static const String itemId = 'item_id';
  static const String entryId = 'entry_id';
  static const String accountId = 'account_id';
  static const String debit = 'debit';
  static const String credit = 'credit';
  static const String lineDescription = 'line_description';
  static const String currencyId = 'currency_id';
  static const String exPrice = 'ex_price';
  static const String expriceMain = 'exprice_main';

  static const List<String> fields = [
    itemId,
    entryId,
    accountId,
    debit,
    credit,
    lineDescription,
    currencyId,
    exPrice,
    expriceMain,
  ];
}
