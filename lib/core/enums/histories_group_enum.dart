import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';

import 'app_enum.dart';
import 'counter_type_enum.dart';
import 'asset_type_enum.dart';
import 'entry_type_enum.dart';
import 'financial_bond_type_enum.dart';
import 'financial_transaction_type_enum.dart';
import 'inventory_transaction_type_enum.dart';

abstract class HistoriesGroup extends AppEnum {
  final String singleName;
  final String totalName;
  final String counterTypeName;
  final int priority;

  const HistoriesGroup({
    required this.singleName,
    required this.totalName,
    required this.counterTypeName,
    required this.priority,
  });

  bool get isProceeds => name == 'proceeds';
  bool get isPaids => name == 'paids';
  bool get isExpenses => name == 'expenses';
  bool get isRevenues => name == 'revenues';

  CounterType get counterType {
    switch (this) {
      case HistoriesGroup.sales:
      case HistoriesGroup.salesReturn:
        return CounterType.salesBills;
      case HistoriesGroup.buys:
      case HistoriesGroup.buysReturn:
        return CounterType.buysBills;
      case HistoriesGroup.expenses:
        return CounterType.expenses;
      case HistoriesGroup.revenues:
        return CounterType.revenues;
      case HistoriesGroup.proceeds:
        return CounterType.proceeds;
      case HistoriesGroup.paids:
        return CounterType.paids;
      case HistoriesGroup.deposits:
        return CounterType.deposits;
      case HistoriesGroup.withdraws:
        return CounterType.withdraws;
      case HistoriesGroup.assetsBuys:
        return CounterType.assetsBuys;
      case HistoriesGroup.assetsSales:
        return CounterType.assetsSales;
      case HistoriesGroup.openingEntries:
        return CounterType.openingEntries;
      case HistoriesGroup.closingEntries:
        return CounterType.closingEntries;
      case HistoriesGroup.inventoryReceive:
        return CounterType.goodsReceipt;
      case HistoriesGroup.inventoryDelivery:
        return CounterType.goodsDelivery;
      case HistoriesGroup.goodsCost:
        return CounterType.goodsCost;
      default:
        return CounterType.openingEntries;
    }
  }

  bool get isBill =>
      name == 'sales' ||
      name == 'buys' ||
      name == 'buys_return' ||
      name == 'sales_return';
  bool get isBuy => name == 'buys';
  bool get isSalesReturn => name == 'sales_return';
  bool get isSales => name == 'sales';
  bool get isBuysReturn => name == 'buys_return';

  static const sales = InvoiceType.sales;
  static const buys = InvoiceType.buys;
  static const buysReturn = InvoiceType.buysReturn;
  static const salesReturn = InvoiceType.salesReturn;
  static const expenses = FinancialTransactionType.expenses;
  static const revenues = FinancialTransactionType.revenues;
  static const proceeds = FinancialBondType.proceeds;
  static const paids = FinancialBondType.paids;
  static const deposits = FinancialBondType.deposits;
  static const withdraws = FinancialBondType.withdraws;
  static const assetsBuys = AssetType.assetsBuys;
  static const assetsSales = AssetType.assetsSales;
  static const openingEntries = EntryType.openingEntries;
  static const closingEntries = EntryType.closingEntries;
  static const inventoryReceive = InventoryTransactionType.importInventory;
  static const inventoryDelivery = InventoryTransactionType.exportInventory;
  static const goodsCost = CostOfGoodsEnum._(
    singleName: 'تكلفة البضاعة',
    totalName: 'تكاليف البضائع',
    counterTypeName: 'رقم الفاتورة',
    priority: 16,
  );

  static const List<HistoriesGroup> values = [
    sales,
    buys,
    buysReturn,
    salesReturn,
    expenses,
    revenues,
    proceeds,
    paids,
    deposits,
    withdraws,
    assetsBuys,
    assetsSales,
    openingEntries,
    closingEntries,
    inventoryReceive,
    inventoryDelivery,
    goodsCost,
  ];

  static HistoriesGroup of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown HistoriesGroup: $name'),
    );
  }
}


final class CostOfGoodsEnum extends HistoriesGroup {
  const CostOfGoodsEnum._({required super.singleName, required super.totalName, required super.counterTypeName, required super.priority});

  @override
  String displayName() {
    return 'تكلفة بضاعة';
  }

  @override
  int get index => 16 ;

  @override
  String get name => 'cost_of_goods';

}
