import 'package:flowcash/core/datasources/interfaces/person_data_source.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/inventory_account_field_enum.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/sub_account_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/categories/data/datasources/category_data_source.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_data_source.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_entry_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_transaction_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_repository.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/bill_data_source.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';

class BillRepositoryImpl implements BillRepository {
  final BillDataSource _dataSource;
  final PersonDataSource _personDataSource;
  final InventoryDataSource _inventoryDataSource;
  final JournalEntryDataSource _journalEntryDataSource;
  final SubAccountDataSource _subAccountDataSource;
  final CategoryLocalDataSource _categoryLocalDataSource;
  final InventoryTransactionDataSource _inventoryTransactionDataSource;

  const BillRepositoryImpl(
    this._dataSource,
    this._personDataSource,
    this._inventoryDataSource,
    this._journalEntryDataSource,
    this._subAccountDataSource,
    this._categoryLocalDataSource,
    this._inventoryTransactionDataSource,
  );

  @override
  Future<Either<Failure, List<BillEntity>>> get({Iterable<int>? ids}) async {
    try {
      final result = await _dataSource.get(ids: ids);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillEntity?>> getById(int id) async {
    try {
      final result = await _dataSource.getById(id);
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> insert(BillEntity entity) async {
    try {
      final entityInserted = await _dataSource.insert(entity);
      return right(entityInserted);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> update(BillEntity entity) async {
    try {
      await _dataSource.update(entity);
      return right(entity);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      await _dataSource.delete(id);
      return right(true);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BillEntity>>> whereHasNotGoneInStore({
    bool trigger = false,
    bool printQuery = true,
  }) async {
    try {
      final result = await _dataSource.whereHasNotGoneInStore(
        trigger: trigger,
        printQuery: printQuery,
      );
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getBillsWithCustomer() async {
    try {
      final result = await _dataSource.getBillsWithCustomer();
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> postToAccounting({
    required BillEntity bill,
    required int userId,
    required String currencyId,
    required List<ExchangePriceEntity> exPrices,
  }) async {
    try {
      final result = await (switch (bill.billType) {
        SalesInvoiceType() => _postSalesBill(bill, userId, currencyId, exPrices),
        PurchaseInvoiceType() => _postPurchaseBill(
          bill,
          userId,
          currencyId,
          exPrices,
        ),
        SalesReturnInvoiceType() => _postSalesReturnBill(
          bill,
          userId,
          currencyId,
          exPrices,
        ),
        PurchaseReturnInvoiceType() => _postPurchaseReturnBill(
          bill,
          userId,
          currencyId,
          exPrices,
        ),
      });
      return right(result);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> postToInventory({
    required BillEntity bill,
    required int userId,
  }) async {
    try {
      final transactionType = (switch (bill.billType) {
        SalesInvoiceType() => InventoryTransactionType.exportInventory,
        PurchaseInvoiceType() => InventoryTransactionType.importInventory,
        SalesReturnInvoiceType() => InventoryTransactionType.importInventory,
        PurchaseReturnInvoiceType() =>
          InventoryTransactionType.exportInventory,
      });

      final transactionOrders = <InventoryTransactionOrderEntity>[];

      for (final order in bill.orders) {
        final category = await _categoryLocalDataSource.getById(
          order.categoryId,
        );
        if (category == null ||
            category.categoryType == CategoryDefineType.services) {
          continue;
        }

        final inventory = await _inventoryDataSource.getInventory(
          categoryId: order.categoryId,
          warehouseId: bill.warehouseId,
        );

        transactionOrders.add(
          InventoryTransactionOrderEntity(
            id: 0,
            inventoryId: inventory.id,
            countUnits: order.countUnits,
            transactionType: transactionType,
          ),
        );
      }

      if (transactionOrders.isEmpty) {
        return right(bill);
      }

      final transaction = InventoryTransactionEntity(
        id: 0,
        createdAt: DateTime.now(),
        createdBy: userId,
        note: bill.billHistory,
        warehouseId: bill.warehouseId,
        personId: bill.personId ?? bill.treasuryId ?? 0,
        billNumber: bill.billNumber,
        transactionType: transactionType,
        orders: transactionOrders,
      );

      final insertedTransaction = await _inventoryTransactionDataSource.insert(
        transaction,
      );

      final updatedBill = bill.copyWith(
        inventoryTransactionId: insertedTransaction.id,
      );

      await _dataSource.update(updatedBill);

      return right(updatedBill);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  /// ترحيل فاتورة بيع:
  ///   مدين: خزينة (نقد) أو عميل (آجل) بإجمالي الفاتورة
  ///   دائن: حساب إيراد المخزون لكل طلبية (revenueAccountId)
  Future<BillEntity> _postSalesBill(
    BillEntity bill,
    int userId,
    String currencyId,
    List<ExchangePriceEntity> exPrices,
  ) async {
    final subaccount = await _resolvePersonAccount(bill, isDebit: true);
    final orderItems = await _buildOrderItems(
      orders: bill.orders,
      warehouseId: bill.warehouseId,
      inventoryField: InventoryAccountField.revenue,
      status: JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
    );
    final debitItem = await _buildPersonItem(
      accountId: subaccount.id,
      amount: bill.offerAmount,
      status: subaccount.accountStatus.isCreditor ? JournalStatus.decrement : JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
      description: bill.billHistory,
    );
    return await _saveAndLink(bill, userId, currencyId, [
      debitItem,
      ...orderItems,
    ]);
  }

  /// ترحيل فاتورة شراء:
  ///   مدين: حساب مصروف المخزون لكل طلبية (expenseAccountId)
  ///   دائن: خزينة (نقد) أو مورد (آجل) بإجمالي الفاتورة
  Future<BillEntity> _postPurchaseBill(
    BillEntity bill,
    int userId,
    String currencyId,
    List<ExchangePriceEntity> exPrices,
  ) async {
    final subaccount = await _resolvePersonAccount(bill, isDebit: false);
    final orderItems = await _buildOrderItems(
      orders: bill.orders,
      warehouseId: bill.warehouseId,
      inventoryField: InventoryAccountField.expense,
      status: JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
    );
    final creditItem = await _buildPersonItem(
      accountId: subaccount.id,
      amount: bill.offerAmount,
      status: subaccount.accountStatus.isDebtor ? JournalStatus.decrement : JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
      description: bill.billHistory,
    );
    return await _saveAndLink(bill, userId, currencyId, [
      ...orderItems,
      creditItem,
    ]);
  }

  /// ترحيل مرتجع بيع:
  ///   مدين: حساب مصروف المخزون لكل طلبية (expenseAccountId)
  ///   دائن: خزينة (نقد) أو عميل (آجل) بإجمالي الفاتورة
  Future<BillEntity> _postSalesReturnBill(
    BillEntity bill,
    int userId,
    String currencyId,
    List<ExchangePriceEntity> exPrices,
  ) async {
    final subaccount = await _resolvePersonAccount(bill, isDebit: false);
    final orderItems = await _buildOrderItems(
      orders: bill.orders,
      warehouseId: bill.warehouseId,
      inventoryField: InventoryAccountField.expense,
      status: JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
    );
    final creditItem = await _buildPersonItem(
      accountId: subaccount.id,
      amount: bill.offerAmount,
      status: subaccount.accountStatus.isDebtor ? JournalStatus.decrement : JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
      description:  bill.billHistory,
    );
    return await _saveAndLink(bill, userId, currencyId, [
      ...orderItems,
      creditItem,
    ]);
  }

  /// ترحيل مرتجع شراء:
  ///   مدين: خزينة (نقد) أو مورد (آجل) بإجمالي الفاتورة
  ///   دائن: حساب إيراد المخزون لكل طلبية (revenueAccountId)
  Future<BillEntity> _postPurchaseReturnBill(
    BillEntity bill,
    int userId,
    String currencyId,
    List<ExchangePriceEntity> exPrices,
  ) async {
    final subaccount = await _resolvePersonAccount(bill, isDebit: true);
    final orderItems = await _buildOrderItems(
      orders: bill.orders,
      warehouseId: bill.warehouseId,
      inventoryField: InventoryAccountField.revenue,
      status: JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
    );

    final debitItem = await _buildPersonItem(
      accountId: subaccount.id,
      amount: bill.offerAmount,
      status: subaccount.accountStatus.isCreditor ? JournalStatus.decrement : JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
      description: bill.billHistory
    );
    return await _saveAndLink(bill, userId, currencyId, [
      debitItem,
      ...orderItems,
    ]);
  }

  Future<SubAccountEntity> _resolvePersonAccount(
    BillEntity bill, {
    required bool isDebit,
  }) async {
    if (bill.isCash) {
      if(bill.treasuryId == null) {
        throw Exception('Treasury Can not be null and bill is cash.');
      }
      final treasury = await _personDataSource.getById(bill.treasuryId!);
      final subAccount = await _subAccountDataSource.getById(treasury!.receivableAccountId!);
      return subAccount!;
    } else {
      final person = await _personDataSource.getById(bill.personId!);
      final subAccount = await _subAccountDataSource.getById(isDebit ? person!.receivableAccountId! : person!.payableAccountId!);
      return subAccount!;
    }
  }

  Future<JournalItemEntity> _buildPersonItem({
    required int accountId,
    required double amount,
    required JournalStatus status,
    required String billCurrencyId,
    required List<ExchangePriceEntity> exPrices,
    required String description,
  }) async {
    final subAccount = await _subAccountDataSource.getById(accountId);
    final (exPrice, exPriceMain) = _resolveExchangeRate(
      subAccount!.currencyId,
      billCurrencyId,
      exPrices,
    );
    return JournalItemEntity(
      id: 0,
      entryId: 0,
      accountId: accountId,
      amount: amount,
      lineDescription: description,
      currencyId: billCurrencyId,
      exPrice: exPrice,
      exPriceMain: exPriceMain,
      journalStatus: status,
    );
  }

  Future<List<JournalItemEntity>> _buildOrderItems({
    required List<BillOrderEntity> orders,
    required int warehouseId,
    required InventoryAccountField inventoryField,
    required JournalStatus status,
    required String billCurrencyId,
    required List<ExchangePriceEntity> exPrices,
  }) async {
    final items = <JournalItemEntity>[];
    for (final order in orders) {
      final inventory = await _inventoryDataSource.getInventory(
        categoryId: order.categoryId,
        warehouseId: warehouseId,
      );
      final accountId =
          inventoryField == InventoryAccountField.revenue
              ? inventory.revenueAccountId
              : inventory.expenseAccountId;

      final subAccount = await _subAccountDataSource.getById(accountId);
      final (exPrice, exPriceMain) = _resolveExchangeRate(
        subAccount!.currencyId,
        billCurrencyId,
        exPrices,
      );
      final category = await _categoryLocalDataSource.getById(order.categoryId);

      items.add(
        JournalItemEntity(
          id: 0,
          entryId: 0,
          accountId: accountId,
          amount: order.totalPrice,
          lineDescription: '${AppMoneyFormatter.formatDouble(order.countUnits)}${category?.categoryUnit?.unitName} ${category?.categoryName}',
          currencyId: billCurrencyId,
          exPrice: exPrice,
          exPriceMain: exPriceMain,
          journalStatus: status,
        ),
      );
    }
    return items;
  }

  Future<BillEntity> _saveAndLink(
    BillEntity bill,
    int userId,
    String currencyId,
    List<JournalItemEntity> items,
  ) async {
    final entry = JournalEntryEntity(
      id: 0,
      referenceNumber: 'BILL-${bill.billType.name.toUpperCase().replaceAll('_', '-')}-${bill.billnumberFormat}',
      description: bill.billHistory,
      createdAt: bill.createdAt,
      createdBy: userId,
      currencyId: currencyId,
      baseAmount: bill.offerAmount,
      warehouseId: bill.warehouseId,
      items: items,
    );

    final savedEntry = await _journalEntryDataSource.insert(
      entry
    );

    final updatedBill = bill.copyWith(journalEntryId: savedEntry.id);
    await _dataSource.update(updatedBill);
    return updatedBill;
  }

  (double, double) _resolveExchangeRate(
    String accountCurrencyId,
    String billCurrencyId,
    List<ExchangePriceEntity> exPrices,
  ) {
    if (accountCurrencyId == billCurrencyId) return (1.0, 1.0);
    try {
      final price = exPrices.firstWhere(
        (p) =>
            (p.fromCurrencyId == billCurrencyId &&
                p.toCurrencyId == accountCurrencyId) ||
            (p.fromCurrencyId == accountCurrencyId &&
                p.toCurrencyId == billCurrencyId),
      );
      if (price.fromCurrencyId == billCurrencyId) {
        return (price.price, 1 / price.price);
      } else {
        return (1 / price.price, price.price);
      }
    } catch (e) {
      return (1.0, 1.0);
    }
  }
}
