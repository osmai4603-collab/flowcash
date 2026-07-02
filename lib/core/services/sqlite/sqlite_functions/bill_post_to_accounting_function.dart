import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/core/models/person_model.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service_sync.dart';
import 'package:flowcash/core/tables/bill_orders_table.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/core/tables/persons_table.dart';
import 'package:flowcash/core/tables/inventories_table.dart';
import 'package:flowcash/core/tables/categories_table.dart';
import 'package:flowcash/core/tables/units_table.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/tables/exchange_prices_table.dart';
import 'package:flowcash/features/accounts/data/models/journal_item_model.dart';
import 'package:flowcash/features/accounts/data/models/sub_account_model.dart';
import 'package:flowcash/features/categories/data/models/category_model.dart';
import 'package:flowcash/features/categories/data/models/unit_model.dart';
import 'package:flowcash/features/currencies/data/models/exchange_price_model.dart';
import 'package:flowcash/features/inventory/data/models/inventory_model.dart';
import 'package:flowcash/features/transactions/data/models/bill_model.dart';
import 'package:flowcash/features/transactions/data/models/bill_order_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

/// Registers a user-defined SQLite function that can be called from triggers.
///
/// The function is intended to encapsulate the accounting workflow for a bill
/// after the bill has been linked to a journal entry.
final class BillPostToAccountingFunction {
  static const String functionName = 'post_bill_to_accounting';

  BillPostToAccountingFunction(this._sqlite);

  final SqliteDatabaseSync _sqlite;

  void call() {
    _sqlite.createFunction(
      functionName: functionName,
      function: _handleFunctionCall,
      argumentCount: const AllowedArgumentCount(1),
      deterministic: true,
      directOnly: false,
    );
  }

  Object? _handleFunctionCall(SqliteArguments arguments) {
    debugPrint('BillPostToAccountingFunction called with arguments: $arguments');
    if (arguments.length != 1) {
      return null;
    }

    final billId = int.tryParse(arguments[0].toString());
    if (billId == null) {
      return null;
    }

    final billmodel = _sqlite.getByIdToModel(
      table: BillsTable(),
      id: billId,
      toModel: BillModel.fromMap,
    );

    if (billmodel == null) {
      return null;
    }

    final journalEntryId = billmodel.journalEntryId;
    if (journalEntryId == null) {
      return 0;
    }

    final orders = _sqlite.queryToModels(
      table: BillOrdersTable().tableName,
      where: '${BillOrdersTable().billId} = ?',
      whereArgs: [billmodel.id],
      toModel: BillOrderModel.fromMap,
    );

    final billWithOrders = billmodel.copyWith(orders: orders);

    return _postToAccountingForBill(billWithOrders, journalEntryId);
  }

  List<JournalItemModel> _postToAccountingForBill(
    BillModel bill,
    int journalEntryId,
  ) {
    final billId = bill.id;
    final billTypeName = bill.billType.name;
    final billCurrencyId = bill.currencyId;
    final isCash = bill.isCash;
    final personId = bill.personId;
    final treasuryId = bill.treasuryId;
    final billAmount = bill.offerAmount;

    final personAccountId = _resolvePersonAccountId(
      isCash: isCash,
      personId: personId,
      treasuryId: treasuryId,
      shouldDebit:
          bill.billType == InvoiceType.sales ||
          bill.billType == InvoiceType.buysReturn,
    );

    if (personAccountId == null) {
      return [];
    }

    final personAccount = _sqlite.getByIdToModel(
      table: SubAccountsTable(),
      id: personAccountId,
      toModel: SubAccountModel.fromMap,
    );
    if (personAccount == null) {
      return [];
    }

    final orders = _sqlite.queryToModels(
      table: BillOrdersTable().tableName,
      where: '${BillOrdersTable().billId} = ?',
      whereArgs: [billId],
      toModel: BillOrderModel.fromMap,
    );

    final exchangeRates = _sqlite.queryToModels(
      table: ExchangePricesTable().tableName,
      toModel: ExchangePriceModel.fromMap,
    );

    final items = <JournalItemModel>[];

    final personStatus = _resolvePersonJournalStatus(
      billType: bill.billType,
      subAccountType: personAccount.subAccountType.name,
    );

    final (personExPrice, personExPriceMain) = _resolveExchangeRates(
      accountCurrencyId: personAccount.currencyId,
      billCurrencyId: billCurrencyId,
      exchangeRates: exchangeRates,
    );

    items.add(
      JournalItemModel(
        id: 0,
        entryId: journalEntryId,
        accountId: personAccountId,
        amount: billAmount,
        lineDescription: bill.note ?? '',
        currencyId: billCurrencyId,
        exPrice: personExPrice,
        exPriceMain: personExPriceMain,
        journalStatus: personStatus,
      ),
    );

    for (final order in orders) {
      final categoryId = order.categoryId;
      final orderAmount = order.totalPrice;

      final inventory = _sqlite.fetchFirstToModel(
        tableName: InventoriesTable().tableName,
        where:
            '${InventoriesTable().categoryId} = ? AND ${InventoriesTable().storeId} = ?',
        whereArgs: [categoryId, bill.warehouseId],
        toModel: InventoryModel.fromMap,
      );
      if (inventory == null) {
        continue;
      }

      final category = _sqlite.getByIdToModel(
        table: CategoriesTable(),
        id: categoryId,
        toModel: CategoryModel.fromMap,
      );
      if (category == null) {
        continue;
      }

      final categoryUnit = _sqlite.getByIdToModel(
        table: UnitsTable(),
        id: category.categoryUnitId,
        toModel: UnitModel.fromMap,
      );
      if (categoryUnit == null) {
        continue;
      }

      final accountId = _resolveInventoryAccountId(
        billType: bill.billType,
        inventory: inventory,
      );
      if (accountId == null) {
        continue;
      }

      final status = _resolveJournalStatus(bill.billType);
      final account = _sqlite.getByIdToModel(
        table: SubAccountsTable(),
        id: accountId,
        toModel: SubAccountModel.fromMap,
      );
      if (account == null) {
        continue;
      }

      final (exPrice, exPriceMain) = _resolveExchangeRates(
        accountCurrencyId: account.currencyId,
        billCurrencyId: billCurrencyId,
        exchangeRates: exchangeRates,
      );

      items.add(
        JournalItemModel(
          id: 0,
          entryId: journalEntryId,
          accountId: accountId,
          amount: orderAmount,
          lineDescription:
              '${billTypeName.toUpperCase()} ${order.countUnits} ${categoryUnit.unitName} ${category.categoryName}',
          currencyId: billCurrencyId,
          exPrice: exPrice,
          exPriceMain: exPriceMain,
          journalStatus: status,
        ),
      );
    }

    if (items.length <= 1) {
      return [];
    }
    return _sqlite.transaction(
      () => _startTransaction(items, billAmount, journalEntryId),
      onError: (error) {
        _sqlite.deleteById(
          table: JournalEntriesTable(),
          id: journalEntryId,
        );
      },
    );
  }

  List<JournalItemModel> _startTransaction(
    List<JournalItemModel> items,
    double billAmount,
    int journalEntryId,
  ) {
    final List<JournalItemModel> newItems = [];
    for (final item in items) {
      final id = _sqlite.insert(
        table: JournalItemsTable().tableName,
        data: item.toMap(),
      );
      newItems.add(item.copyWith(id: id, entryId: journalEntryId));
    }

    _sqlite.execute(
      'UPDATE ${JournalEntriesTable().tableName} SET ${JournalEntriesTable().amount} = ? WHERE ${JournalEntriesTable().id} = ?',
      [billAmount, journalEntryId],
    );

    return newItems;
  }

  int? _resolvePersonAccountId({
    required bool isCash,
    required int? personId,
    required int? treasuryId,
    required bool shouldDebit,
  }) {
    if (isCash) {
      if (treasuryId == null) {
        return null;
      }
      final treasury = _sqlite.getByIdToModel(
        table: PersonsTable(),
        id: treasuryId,
        toModel: PersonModel.fromMap,
      );
      if (treasury == null) {
        return null;
      }
      return treasury.receivableAccountId;
    }

    if (personId == null) {
      return null;
    }

    final person = _sqlite.getByIdToModel(
      table: PersonsTable(),
      id: personId,
      toModel: PersonModel.fromMap,
    );
    if (person == null) {
      return null;
    }

    return shouldDebit ? person.receivableAccountId : person.payableAccountId;
  }

  int? _resolveInventoryAccountId({
    required InvoiceType billType,
    required InventoryModel inventory,
  }) {
    switch (billType) {
      case InvoiceType.sales:
      case InvoiceType.buysReturn:
        return inventory.revenueAccountId;
      case InvoiceType.buys:
      case InvoiceType.salesReturn:
        return inventory.expenseAccountId;
      default:
        return null;
    }
  }

  JournalStatus _resolveJournalStatus(InvoiceType billType) {
    // Order items always use increment status for bill accounting.
    return JournalStatus.increment;
  }

  JournalStatus _resolvePersonJournalStatus({
    required InvoiceType billType,
    required String? subAccountType,
  }) {
    final isCreditor = subAccountType != null
        ? SubAccountType.of(
            subAccountType,
          ).mainAccountType.accountStatus.isCreditor
        : false;
    final isDebtor = subAccountType != null
        ? SubAccountType.of(
            subAccountType,
          ).mainAccountType.accountStatus.isDebtor
        : false;

    final isDebitBill =
        billType == InvoiceType.sales || billType == InvoiceType.buysReturn;
    if (isDebitBill) {
      return isCreditor ? JournalStatus.decrement : JournalStatus.increment;
    }
    return isDebtor ? JournalStatus.decrement : JournalStatus.increment;
  }

  (double exPrice, double exPriceMain) _resolveExchangeRates({
    required String accountCurrencyId,
    required String billCurrencyId,
    required List<ExchangePriceModel> exchangeRates,
  }) {
    if (accountCurrencyId == billCurrencyId) {
      return (1.0, 1.0);
    }

    for (final rate in exchangeRates) {
      if (rate.fromCurrencyId == billCurrencyId &&
          rate.toCurrencyId == accountCurrencyId) {
        return (rate.price, 1 / rate.price);
      }
      if (rate.fromCurrencyId == accountCurrencyId &&
          rate.toCurrencyId == billCurrencyId) {
        return (1 / rate.price, rate.price);
      }
    }

    return (1.0, 1.0);
  }
}
