import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';

import 'accounting_period_type_enum.dart';
import 'app_enum.dart';

sealed class SubAccountType extends AppEnum {
  final String totalName;
  final String accountName;
  final MainAccountType mainAccountType;
  final String imagePath;
  final bool isDefault;
  final PersonType personType;

  const SubAccountType({
    required this.accountName,
    required this.totalName,
    required this.mainAccountType,
    required this.imagePath,
    required this.personType,
    this.isDefault = true,
  });

  bool get isPerson => this == clients || this == suppliers;
  bool get isCash => this == cashTreasury || this == cashBank;

  String get theSingleName => 'ال$accountName';
  String get theTotalName => 'ال$totalName';

  bool isBelong(MainAccountType type) => mainAccountType == type;

  static const cashTreasury = CashTreasurySubAccountType._();
  static const cashBank = CashBankSubAccountType._();
  static const clients = ClientsSubAccountType._();
  static const suppliers = SuppliersSubAccountType._();
  static const revenues = RevenuesSubAccountType._();
  static const operationExpenses = OperationExpensesSubAccountType._();
  static const expenses = ExpensesSubAccountType._();
  static const inventory = InventorySubAccountType._();
  static const sales = SalesSubAccountType._();
  static const buys = BuysSubAccountType._();
  static const salesReturn = SalesReturnSubAccountType._();
  static const buysReturn = BuysReturnSubAccountType._();
  static const moneyHead = MoneyHeadSubAccountType._();
  static const profitsAndLoss = ProfitsAndLossSubAccountType._();
  static const tangibleAssets = TangibleAssetsSubAccountType._();
  static const inTangibleAssets = IntangibleAssetsSubAccountType._();
  static const costOfGoodsSold = CostOfGoodsSoldSubAccountType._();

  static const List<SubAccountType> values = [
    cashTreasury,
    cashBank,
    inventory,
    clients,
    suppliers,
    revenues,
    expenses,
    operationExpenses,
    moneyHead,
    profitsAndLoss,
    sales,
    salesReturn,
    buys,
    buysReturn,
    tangibleAssets,
    inTangibleAssets,
    costOfGoodsSold,
  ];

  AccountingsPeriodType get periodType => mainAccountType.periodType;

  static SubAccountType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown SubAccountType: $name'),
    );
  }

  static List<SubAccountType> whereMainAccountType(
    MainAccountType mainAccountType,
  ) {
    return values.where((e) => e.mainAccountType == mainAccountType).toList();
  }

  static List<SubAccountType> whereMainAccountTypes(
    List<MainAccountType> mainAccountTypes,
  ) {
    return values.where((e) => mainAccountTypes.contains(e.mainAccountType)).toList();
  }

  static List<SubAccountType> whereMainAccountGroup(
    MainAccountGroup mainAccountGroup,
  ) {
    return values.where((e) => e.mainAccountType.accountType == mainAccountGroup).toList();
  }

  static List<SubAccountType> whereSubAccountsTypeIsPerson() {
    return values.where((e) => e.isPerson).toList();
  }
}

final class CashTreasurySubAccountType extends SubAccountType {
  const CashTreasurySubAccountType._()
    : super(
        accountName: 'خزينة نقدية',
        totalName: 'خزائن نقدية',
        mainAccountType: MainAccountType.cashes,
        imagePath: 'images/cash_balance.png',
        personType: PersonType.cash,
      );

  @override
  String get name => 'cash_treasury';

  @override
  int get index => 0;

  @override
  String displayName() => accountName;
}

final class CashBankSubAccountType extends SubAccountType {
  const CashBankSubAccountType._()
    : super(
        accountName: 'بنك',
        totalName: 'بنوك',
        mainAccountType: MainAccountType.cashes,
        imagePath: 'images/cash_balance.png',
        personType: PersonType.bank,
        isDefault: false,
      );

  @override
  String get name => 'cash_bank';

  @override
  int get index => 1;

  @override
  String displayName() => accountName;
}

final class ClientsSubAccountType extends SubAccountType {
  const ClientsSubAccountType._()
    : super(
        accountName: 'عميل',
        totalName: 'عملاء',
        mainAccountType: MainAccountType.debtors,
        imagePath: 'images/client.png',
        personType: PersonType.client,
      );

  @override
  String get name => 'clients';

  @override
  int get index => 2;

  @override
  String displayName() => accountName;
}

final class SuppliersSubAccountType extends SubAccountType {
  const SuppliersSubAccountType._()
    : super(
        accountName: 'مورد',
        totalName: 'موردين',
        mainAccountType: MainAccountType.creditors,
        imagePath: 'images/supplier.png',
        personType: PersonType.supplier,
      );

  @override
  String get name => 'suppliers';

  @override
  int get index => 3;

  @override
  String displayName() => accountName;
}

final class RevenuesSubAccountType extends SubAccountType {
  const RevenuesSubAccountType._()
    : super(
        accountName: 'ايراد',
        totalName: 'ايرادات',
        mainAccountType: MainAccountType.servicesRevenues,
        imagePath: 'images/revenues.png',
        personType: PersonType.revenues,
      );

  @override
  String get name => 'revenues';

  @override
  int get index => 4;

  @override
  String displayName() => accountName;
}

final class OperationExpensesSubAccountType extends SubAccountType {
  const OperationExpensesSubAccountType._()
    : super(
        accountName: 'مصروف تشغيلي',
        totalName: 'مصروفات تشغيلية',
        mainAccountType: MainAccountType.operationalExpenses,
        imagePath: 'images/expenses.png',
        personType: PersonType.expenses,
      );

  @override
  String get name => 'operational_expenses';

  @override
  int get index => 5;

  @override
  String displayName() => accountName;
}

final class ExpensesSubAccountType extends SubAccountType {
  const ExpensesSubAccountType._()
    : super(
        accountName: 'مصروف',
        totalName: 'مصروفات',
        mainAccountType: MainAccountType.expenses,
        imagePath: 'images/expenses.png',
        personType: PersonType.expenses,
      );

  @override
  String get name => 'expenses';

  @override
  int get index => 6;

  @override
  String displayName() => accountName;
}

final class InventorySubAccountType extends SubAccountType {
  const InventorySubAccountType._()
    : super(
        accountName: 'مخزون بضائع',
        totalName: 'مخزون',
        mainAccountType: MainAccountType.inventory,
        imagePath: 'images/stores.png',
        personType: PersonType.inventory,
      );

  @override
  String get name => 'inventory';

  @override
  int get index => 7;

  @override
  String displayName() => accountName;
}

final class SalesSubAccountType extends SubAccountType {
  const SalesSubAccountType._()
    : super(
        accountName: 'بيع',
        totalName: 'مبيعات',
        mainAccountType: MainAccountType.sales,
        imagePath: 'images/revenues.png',
        personType: PersonType.sales,
      );

  @override
  String get name => 'sales';

  @override
  int get index => 8;

  @override
  String displayName() => accountName;
}

final class BuysSubAccountType extends SubAccountType {
  const BuysSubAccountType._()
    : super(
        accountName: 'شراء',
        totalName: 'مشتريات',
        mainAccountType: MainAccountType.buys,
        imagePath: 'images/expenses.png',
        personType: PersonType.buys,
      );

  @override
  String get name => 'buys';

  @override
  int get index => 9;

  @override
  String displayName() => accountName;
}

final class SalesReturnSubAccountType extends SubAccountType {
  const SalesReturnSubAccountType._()
    : super(
        accountName: 'مرتجع بيع',
        totalName: 'مرتجع مبيعات',
        mainAccountType: MainAccountType.salesReturn,
        imagePath: 'images/expenses.png',
        personType: PersonType.salesReturn,
      );

  @override
  String get name => 'sales_return';

  @override
  int get index => 10;

  @override
  String displayName() => accountName;
}

final class BuysReturnSubAccountType extends SubAccountType {
  const BuysReturnSubAccountType._()
    : super(
        accountName: 'مرتجع شراء',
        totalName: 'مرتجع مشتريات',
        mainAccountType: MainAccountType.buysReturn,
        imagePath: 'images/revenues.png',
        personType: PersonType.buysReturn,
      );

  @override
  String get name => 'buys_return';

  @override
  int get index => 11;

  @override
  String displayName() => accountName;
}

final class MoneyHeadSubAccountType extends SubAccountType {
  const MoneyHeadSubAccountType._()
    : super(
        accountName: 'رأس مال',
        totalName: 'رأس مال',
        mainAccountType: MainAccountType.moneyHead,
        imagePath: 'images/revenues.png',
        personType: PersonType.moneyHead,
      );

  @override
  String get name => 'money_head';

  @override
  int get index => 12;

  @override
  String displayName() => accountName;
}

final class ProfitsAndLossSubAccountType extends SubAccountType {
  const ProfitsAndLossSubAccountType._()
    : super(
        accountName: 'الأرباح والخسائر المحتجزة',
        totalName: 'الأرباح والخسائر',
        mainAccountType: MainAccountType.profitsAndLoss,
        imagePath: 'images/revenues.png',
        personType: PersonType.propertyRights,
      );

  @override
  String get name => 'profits_and_loss';

  @override
  int get index => 13;

  @override
  String displayName() => accountName;
}

final class TangibleAssetsSubAccountType extends SubAccountType {
  const TangibleAssetsSubAccountType._()
    : super(
        accountName: 'أصل ملموس',
        totalName: 'أصول ملموسة',
        mainAccountType: MainAccountType.tangibleAssets,
        imagePath: 'images/asset.png',
        personType: PersonType.propertyRights,
      );

  @override
  String get name => 'tangible_assets';

  @override
  int get index => 14;

  @override
  String displayName() => accountName;
}

final class IntangibleAssetsSubAccountType extends SubAccountType {
  const IntangibleAssetsSubAccountType._()
    : super(
        accountName: 'أصل غير ملموس',
        totalName: 'أصول غير ملموسة',
        mainAccountType: MainAccountType.inTangibleAssets,
        imagePath: 'images/asset.png',
        personType: PersonType.propertyRights,
      );

  @override
  String get name => 'in_tangible_assets';

  @override
  int get index => 15;

  @override
  String displayName() => accountName;
}

final class CostOfGoodsSoldSubAccountType extends SubAccountType {
  const CostOfGoodsSoldSubAccountType._()
    : super(
        accountName: 'تكلفة البضاعة المباعة',
        totalName: 'تكلفة البضاعة المباعة',
        mainAccountType: MainAccountType.costOfSales,
        imagePath: 'images/cash_balance.png',
        personType: PersonType.costOfSales,
      );

  @override
  String get name => 'cost_of_goods_sold';

  @override
  int get index => 16;

  @override
  String displayName() => accountName;
}
