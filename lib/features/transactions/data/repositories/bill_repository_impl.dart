import 'package:flowcash/core/datasources/interfaces/person_data_source.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/inventory_account_field_enum.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/core/enums/inventory_transaction_nature_enum.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/main_account_data_source.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/sub_account_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/categories/data/datasources/category_data_source.dart';
import 'package:flowcash/features/categories/data/datasources/unit_data_source.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/currencies/data/datasources/exchange_price_data_source.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_data_source.dart';
import 'package:flowcash/features/accounts/data/datasources/interfaces/journal_entry_data_source.dart';
import 'package:flowcash/features/inventory/data/datasources/inventory_transaction_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/bill_order_data_source.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/cost_good_bill_data_source.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_repository.dart';
import 'package:flowcash/features/transactions/data/datasources/interfaces/bill_data_source.dart';
import 'package:flowcash/features/transactions/data/models/cost_good_bill_model.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';

import '../../domain/entities/cost_good_bill_order_entity.dart';

class BillRepositoryImpl implements BillRepository {
  final BillDataSource _dataSource;
  final PersonDataSource _personDataSource;
  final InventoryDataSource _inventoryDataSource;
  final JournalEntryDataSource _journalEntryDataSource;
  final SubAccountDataSource _subAccountDataSource;
  final MainAccountDataSource _mainAccountDataSource;
  final CategoryLocalDataSource _categoryLocalDataSource;
  final InventoryTransactionDataSource _inventoryTransactionDataSource;
  final ExchangePriceDataSource _exPriceDataSource;
  final BillOrderDataSource _orderDataSource;
  final UnitLocalDataSource _unitLocalDataSource;
  final CostGoodBillDataSource _costGoodBillDataSource;

  const BillRepositoryImpl(
    this._dataSource,
    this._personDataSource,
    this._inventoryDataSource,
    this._journalEntryDataSource,
    this._subAccountDataSource,
    this._mainAccountDataSource,
    this._categoryLocalDataSource,
    this._inventoryTransactionDataSource,
    this._exPriceDataSource,
    this._orderDataSource,
    this._unitLocalDataSource,
    this._costGoodBillDataSource,
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
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getBillsWithCustomer() async {
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
        SalesInvoiceType() => _postSalesBill(
          bill,
          userId,
          currencyId,
          exPrices,
        ),
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
        PurchaseReturnInvoiceType() => InventoryTransactionType.exportInventory,
      });

      final transactionOrders = <InventoryTransactionOrderEntity>[];
      final billOrders = await _orderDataSource.whereBillId([bill.id]);
      final inventoryCache = <int, InventoryEntity>{};

      for (final order in billOrders) {
        final category = await _categoryLocalDataSource.getById(
          order.categoryId,
        );
        if (category == null ||
            category.categoryType == CategoryDefineType.services) {
          continue;
        }

        final inventory = inventoryCache[order.categoryId] ??=
            await _inventoryDataSource.getInventory(
              categoryId: order.categoryId,
              warehouseId: bill.warehouseId,
            );

        transactionOrders.add(
          InventoryTransactionOrderEntity(
            id: 0,
            inventoryId: inventory.id,
            countUnits: order.countUnits,
          ),
        );
      }

      if (transactionOrders.isEmpty) {
        return right(bill);
      }

      final transactionNature = (switch (bill.billType) {
        SalesInvoiceType() => InventoryTransactionNature.sales,
        PurchaseInvoiceType() => InventoryTransactionNature.purchases,
        SalesReturnInvoiceType() => InventoryTransactionNature.salesReturn,
        PurchaseReturnInvoiceType() =>
          InventoryTransactionNature.purchasesReturn,
      });

      final transaction = InventoryTransactionEntity(
        id: 0,
        createdAt: bill.createdAt,
        createdBy: userId,
        note: bill.billHistory,
        warehouseId: bill.warehouseId,
        personId: bill.personId ?? bill.treasuryId ?? 0,
        billNumber: bill.billNumber,
        transactionType: transactionType,
        transactionNature: transactionNature,
        orders: transactionOrders,
      );

      final insertedTransaction = await _inventoryTransactionDataSource.insert(
        transaction,
      );

      await _dataSource.updateInventoryTransaction(
        id: bill.id,
        inventoryTransactionId: insertedTransaction.id,
      );

      final updatedBill = bill.copyWith(
        inventoryTransactionId: insertedTransaction.id,
      );

      return right(updatedBill);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> postToCosting({
    required BillEntity bill,
    required int userId,
  }) async {
    try {
      if (bill.billType is! SalesInvoiceType &&
          bill.billType is! SalesReturnInvoiceType) {
        return right(bill);
      }

      final exPrices = await _exPriceDataSource.get();
      final costOrders = <CostGoodBillOrderEntity>[];
      final billOrders = await _orderDataSource.whereBillId([bill.id]);
      double totalCostAmount = 0.0;

      final categories = await _categoryLocalDataSource.get(
        ids: billOrders.map((order) => order.categoryId),
      );

      final inventoryCache = <int, InventoryEntity>{};

      for (final order in billOrders) {
        final category = categories.cast<CategoryEntity?>().firstWhere(
          (category) => category?.id == order.categoryId,
          orElse: () => null,
        );
        if (category == null ||
            category.categoryType == CategoryDefineType.services) {
          continue;
        }
        final inventory = inventoryCache[order.categoryId] ??=
            await _inventoryDataSource.getInventory(
              categoryId: order.categoryId,
              warehouseId: bill.warehouseId,
            );

        final unitCost = inventory.countUnits > 0
            ? inventory.costTotal / inventory.countUnits
            : 0.0;

        final orderCost = unitCost * order.countUnits;
        totalCostAmount += orderCost;

        costOrders.add(
          CostGoodBillOrderEntity(
            id: 0,
            costGoodBillId: 0,
            categoryId: order.categoryId,
            countUnits: order.countUnits,
            totalPrice: orderCost,
          ),
        );
      }

      if (costOrders.isEmpty || totalCostAmount <= 0) {
        return right(bill);
      }

      // 1. Create Journal Entry for COGS
      // For Sales: Debit: COGS (Expense - increment), Credit: Inventory (Stock Outcome - decrement)
      // For Sales Return: Debit: Inventory (Stock Outcome - increment), Credit: COGS (Expense - decrement)
      final journalItems = <JournalItemEntity>[];
      final isSales = bill.billType is SalesInvoiceType;
      final expenseStatus = isSales
          ? JournalStatus.increment
          : JournalStatus.decrement;
      final stockStatus = isSales
          ? JournalStatus.decrement
          : JournalStatus.increment;

      for (final order in costOrders) {
        final category = categories.firstWhere(
          (category) => category.id == order.categoryId,
        );
        final categoryUnit = await _unitLocalDataSource.getById(
          category.categoryUnitId,
        );

        final inventory = inventoryCache[order.categoryId]!;

        // Expense Account (COGS)
        final expenseAccount = await _subAccountDataSource.getById(
          inventory.expenseAccountId,
        );
        if (expenseAccount == null) {
          throw Exception('Expense Account is NULL');
        }
        final expenseMainAccount = await _mainAccountDataSource.getById(
          expenseAccount.mainAccountId,
        );
        if (expenseMainAccount == null) {
          throw Exception('Expense Main Account is NULL');
        }

        final (exPriceExpense, exPriceMainExpense) = _resolveExchangeRate(
          expenseAccount.currencyId,
          bill.currencyId,
          exPrices,
        );

        journalItems.add(
          JournalItemEntity(
            id: 0,
            entryId: 0,
            accountId: inventory.expenseAccountId,
            amount: order.totalPrice,
            lineDescription:
                'تكلفة ${AppMoneyFormatter.formatDouble(order.countUnits)} ${categoryUnit?.unitName} ${category.categoryName}',
            currencyId: expenseAccount.currencyId,
            exPrice: exPriceExpense,
            exPriceMain: exPriceMainExpense,
            journalStatus: expenseStatus,
          ),
        );

        // Inventory (Stock Outcome Account)
        final stockAccount = await _subAccountDataSource.getById(
          inventory.outcomeStockId,
        );
        if (stockAccount == null) {
          throw Exception('Outcome Stock Account is NULL');
        }
        final stockMainAccount = await _mainAccountDataSource.getById(
          stockAccount.mainAccountId,
        );
        if (stockMainAccount == null) {
          throw Exception('Outcome Stock Main Account is NULL');
        }

        final (exPriceStock, exPriceMainStock) = _resolveExchangeRate(
          stockAccount.currencyId,
          bill.currencyId,
          exPrices,
        );

        journalItems.add(
          JournalItemEntity(
            id: 0,
            entryId: 0,
            accountId: inventory.outcomeStockId,
            amount: order.totalPrice,
            lineDescription:
                'تكلفة ${bill.billType.invoiceTypeName} ${AppMoneyFormatter.formatDouble(order.countUnits)} ${categoryUnit?.unitName} ${category.categoryName}',
            currencyId: stockAccount.currencyId,
            exPrice: exPriceStock,
            exPriceMain: exPriceMainStock,
            journalStatus: stockStatus,
          ),
        );
      }

      final entry = JournalEntryEntity(
        id: 0,
        referenceNumber:
            'COST-${bill.billType.name.toUpperCase().replaceAll('_', '-')}-${bill.billnumberFormat}',
        description: 'تكلفة ${bill.billHistory}',
        createdAt: bill.createdAt,
        createdBy: userId,
        currencyId: bill.currencyId,
        baseAmount: totalCostAmount,
        warehouseId: bill.warehouseId,
        items: journalItems,
      );

      final savedEntry = await _journalEntryDataSource.insert(entry);

      // 2. Create CostGoodBill (Header and Orders) via CostGoodBillDataSource
      final costGoodBill = CostGoodBillModel(
        id: 0,
        createdAt: bill.createdAt,
        createdBy: userId,
        note: 'تكلفة ${bill.billHistory}',
        offerAmount: totalCostAmount,
        currencyId: bill.currencyId,
        billNumber: bill.billNumber,
        warehouseId: bill.warehouseId,
        journalEntryId: savedEntry.id,
        personId: bill.personId ?? 0,
        billId: bill.id,
        orders: costOrders,
      );

      final savedCostGoodBill = await _costGoodBillDataSource.insert(
        costGoodBill,
      );

      await _dataSource.updateBillCosting(
        id: bill.id,
        costId: savedCostGoodBill.id,
      );

      final updatedBill = bill.copyWith(costGoodId: savedCostGoodBill.id);

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
    final orders = await _orderDataSource.whereBillId([bill.id]);
    final orderItems = await _buildOrderItems(
      orders: orders,
      warehouseId: bill.warehouseId,
      inventoryField: InventoryAccountField.revenue,
      status: JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
      billType: bill.billType,
    );
    final debitItem = await _buildPersonItem(
      accountId: subaccount.id,
      amount: bill.offerAmount,
      status: subaccount.accountStatus.isCreditor
          ? JournalStatus.decrement
          : JournalStatus.increment,
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
    final orders = await _orderDataSource.whereBillId([bill.id]);
    final orderItems = await _buildOrderItems(
      orders: orders,
      warehouseId: bill.warehouseId,
      inventoryField: InventoryAccountField.expense,
      status: JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
      billType: bill.billType,
    );
    final creditItem = await _buildPersonItem(
      accountId: subaccount.id,
      amount: bill.offerAmount,
      status: subaccount.accountStatus.isDebtor
          ? JournalStatus.decrement
          : JournalStatus.increment,
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
    final orders = await _orderDataSource.whereBillId([bill.id]);
    final orderItems = await _buildOrderItems(
      orders: orders,
      warehouseId: bill.warehouseId,
      inventoryField: InventoryAccountField.expense,
      status: JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
      billType: bill.billType,
    );
    final creditItem = await _buildPersonItem(
      accountId: subaccount.id,
      amount: bill.offerAmount,
      status: subaccount.accountStatus.isDebtor
          ? JournalStatus.decrement
          : JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
      description: bill.billHistory,
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
    final orders = await _orderDataSource.whereBillId([bill.id]);
    final orderItems = await _buildOrderItems(
      orders: orders,
      warehouseId: bill.warehouseId,
      inventoryField: InventoryAccountField.revenue,
      status: JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
      billType: bill.billType,
    );

    final debitItem = await _buildPersonItem(
      accountId: subaccount.id,
      amount: bill.offerAmount,
      status: subaccount.accountStatus.isCreditor
          ? JournalStatus.decrement
          : JournalStatus.increment,
      billCurrencyId: currencyId,
      exPrices: exPrices,
      description: bill.billHistory,
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
      if (bill.treasuryId == null) {
        throw Exception('Treasury Can not be null and bill is cash.');
      }
      final treasury = await _personDataSource.getById(bill.treasuryId!);
      final subAccount = await _subAccountDataSource.getById(
        treasury!.receivableAccountId!,
      );
      return subAccount!;
    } else {
      final person = await _personDataSource.getById(bill.personId!);
      final subAccount = await _subAccountDataSource.getById(
        isDebit ? person!.receivableAccountId! : person!.payableAccountId!,
      );
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
    required InvoiceType billType,
  }) async {
    final items = <JournalItemEntity>[];
    if (orders.isEmpty) {
      throw Exception('Bill Orders Can Not Be EMPTY');
    }
    for (final order in orders) {
      final inventory = await _inventoryDataSource.getInventory(
        categoryId: order.categoryId,
        warehouseId: warehouseId,
      );
      final accountId = inventoryField == InventoryAccountField.revenue
          ? inventory.revenueAccountId
          : inventory.expenseAccountId;

      final subAccount = await _subAccountDataSource.getById(accountId);

      if (subAccount == null) {
        throw Exception('SubAccount Of Inventory Can Not Be NULL');
      }
      final (exPrice, exPriceMain) = _resolveExchangeRate(
        subAccount.currencyId,
        billCurrencyId,
        exPrices,
      );

      final category = await _categoryLocalDataSource.getById(order.categoryId);
      if (category == null) {
        throw Exception('Category Can Not Be NULL');
      }

      final categoryUnit = await _unitLocalDataSource.getById(
        category.categoryUnitId,
      );
      if (categoryUnit == null) {
        throw Exception('Category Unit Can Not Be NULL');
      }

      items.add(
        JournalItemEntity(
          id: 0,
          entryId: 0,
          accountId: subAccount.id,
          amount: order.totalPrice,
          lineDescription:
              '${billType.invoiceTypeName} ${AppMoneyFormatter.formatDouble(order.countUnits)} ${categoryUnit.unitName} ${category.categoryName}',
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
      referenceNumber:
          'BILL-${bill.billType.name.toUpperCase().replaceAll('_', '-')}-${bill.billnumberFormat}',
      description: bill.billHistory,
      createdAt: bill.createdAt,
      createdBy: userId,
      currencyId: currencyId,
      baseAmount: bill.offerAmount,
      warehouseId: bill.warehouseId,
      items: items,
    );

    final savedEntry = await _journalEntryDataSource.insert(entry);

    await _dataSource.updateJournalEntry(
      id: bill.id,
      journalEntryId: savedEntry.id,
    );
    final updatedBill = bill.copyWith(journalEntryId: savedEntry.id);
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
