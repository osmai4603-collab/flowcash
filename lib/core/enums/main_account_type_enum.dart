import 'package:flowcash/core/enums/account_status_enum.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';

import 'accounting_period_type_enum.dart';
import 'app_enum.dart';

sealed class MainAccountType extends AppEnum
    implements NumberBasicAccountModel {
  @override
  final String accountNumber;
  final MainAccountGroup accountType;
  final String incrementName;
  final String decrementName;
  final bool isAccountReal;
  final bool isPeriodPermanent;
  final bool isDefault;

  const MainAccountType({
    required this.accountNumber,
    required this.accountType,
    required this.incrementName,
    required this.decrementName,
    required this.isAccountReal,
    required this.isPeriodPermanent,

    this.isDefault = false,
  });

  bool get isSettlementAccount => isAccountReal && !isPeriodPermanent;

  String getNewAccountNumber(int number) {
    return int.parse(
      '${accountType.accountNumber}$accountNumber$number',
    ).toString();
  }

  static const servicesRevenues = ServicesRevenuesType._();
  static const sales = SalesType._();
  static const buysReturn = BuysReturnType._();
  static const operationalExpenses = OperationalExpensesType._();
  static const expenses = ExpensesType._();
  static const buys = BuysType._();
  static const salesReturn = SalesReturnType._();
  static const debtors = DebtorsType._();
  static const cashes = CashesType._();
  static const inventory = InventoryType._();
  static const tangibleAssets = TangibleAssetsType._();
  static const inTangibleAssets = IntangibleAssetsType._();
  static const creditors = CreditorsType._();
  static const moneyHead = MoneyHeadType._();
  static const profitsAndLoss = ProfitsAndLossType._();
  static const futureRevenues = FutureRevenuesType._();
  static const offerRevenues = OfferRevenuesType._();
  static const futureExpenses = FutureExpensesType._();
  static const offerExpenses = OfferExpensesType._();
  static const costOfSales = CostOfSalesType._();

  static const List<MainAccountType> values = [
    servicesRevenues,
    sales,
    buysReturn,
    operationalExpenses,
    expenses,
    buys,
    salesReturn,
    debtors,
    cashes,
    inventory,
    tangibleAssets,
    inTangibleAssets,
    creditors,
    moneyHead,
    profitsAndLoss,
    futureRevenues,
    offerRevenues,
    futureExpenses,
    offerExpenses,
    costOfSales,
  ];

  @override
  String get accountName => displayName();

  @override
  String get groupName => accountType.displayName();

  @override
  AccountingsPeriodType get periodType;

  @override
  AccountStatus get accountStatus => accountType.accountStatus;

  static MainAccountType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown MainAccountType: $name'),
    );
  }

  static List<MainAccountType> whereMainAccount(MainAccountGroup accountType) {
    return values.where((e) => e.accountType == accountType).toList();
  }

  static List<MainAccountType> whereMainAccounts(
    Iterable<MainAccountGroup> accountTypes,
  ) {
    return values.where((e) => accountTypes.contains(e.accountType)).toList();
  }
}

final class ServicesRevenuesType extends MainAccountType {
  const ServicesRevenuesType._()
    : super(
        accountNumber: '1',
        accountType: MainAccountGroup.revenues,
        incrementName: 'له',
        decrementName: 'عليه',
        isAccountReal: false,
        isPeriodPermanent: false,
        isDefault: true,
      );

  @override
  String get name => 'services_revenues';

  @override
  int get index => 0;

  @override
  String displayName() => 'ايرادات خدمات';

  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.temporary;
}

final class SalesType extends MainAccountType {
  const SalesType._()
    : super(
        accountNumber: '2',
        accountType: MainAccountGroup.revenues,
        incrementName: 'له',
        decrementName: 'عليه',
        isAccountReal: false,
        isPeriodPermanent: false,
      );

  @override
  String get name => 'sales';

  @override
  int get index => 1;

  @override
  String displayName() => 'مبيعات';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.temporary;
}

final class BuysReturnType extends MainAccountType {
  const BuysReturnType._()
    : super(
        accountNumber: '3',
        accountType: MainAccountGroup.revenues,
        incrementName: 'له',
        decrementName: 'عليه',
        isAccountReal: false,
        isPeriodPermanent: false,
      );

  @override
  String get name => 'buys_return';

  @override
  int get index => 2;

  @override
  String displayName() => 'مرتحع مشتريات';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.temporary;
}

final class OperationalExpensesType extends MainAccountType {
  const OperationalExpensesType._()
    : super(
        accountNumber: '4',
        accountType: MainAccountGroup.expenses,
        incrementName: 'عليه',
        decrementName: 'له',
        isAccountReal: false,
        isPeriodPermanent: false,
      );

  @override
  String get name => 'operational_expenses';

  @override
  int get index => 3;

  @override
  String displayName() => 'مصروفات تشغيلية';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.temporary;
}

final class ExpensesType extends MainAccountType {
  const ExpensesType._()
    : super(
        accountNumber: '5',
        accountType: MainAccountGroup.expenses,
        incrementName: 'عليه',
        decrementName: 'له',
        isAccountReal: false,
        isPeriodPermanent: false,
        isDefault: true,
      );

  @override
  String get name => 'expenses';

  @override
  int get index => 4;

  @override
  String displayName() => 'مصروفات آخرى';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.temporary;
}

final class BuysType extends MainAccountType {
  const BuysType._()
    : super(
        accountNumber: '6',
        accountType: MainAccountGroup.expenses,
        incrementName: 'عليه',
        decrementName: 'له',
        isAccountReal: false,
        isPeriodPermanent: false,
      );

  @override
  String get name => 'buys';

  @override
  int get index => 5;

  @override
  String displayName() => 'مشتريات';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.temporary;
}

final class SalesReturnType extends MainAccountType {
  const SalesReturnType._()
    : super(
        accountNumber: '7',
        accountType: MainAccountGroup.expenses,
        incrementName: 'عليه',
        decrementName: 'له',
        isAccountReal: false,
        isPeriodPermanent: false,
      );

  @override
  String get name => 'sales_return';

  @override
  int get index => 6;

  @override
  String displayName() => 'مرتجع مبيعات';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.temporary;
}

final class DebtorsType extends MainAccountType {
  const DebtorsType._()
    : super(
        accountNumber: '8',
        accountType: MainAccountGroup.assets,
        incrementName: 'عليه',
        decrementName: 'له',
        isAccountReal: true,
        isPeriodPermanent: true,
        isDefault: true,
      );

  @override
  String get name => 'debtors';

  @override
  int get index => 7;

  @override
  String displayName() => 'حسابات مدينة';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class CashesType extends MainAccountType {
  const CashesType._()
    : super(
        accountNumber: '9',
        accountType: MainAccountGroup.assets,
        incrementName: 'وارد',
        decrementName: 'صادر',
        isAccountReal: true,
        isPeriodPermanent: true,
      );

  @override
  String get name => 'cashes';

  @override
  int get index => 8;

  @override
  String displayName() => 'نقدية';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class InventoryType extends MainAccountType {
  const InventoryType._()
    : super(
        accountNumber: '10',
        accountType: MainAccountGroup.assets,
        incrementName: 'عليه',
        decrementName: 'له',
        isAccountReal: true,
        isPeriodPermanent: true,
      );

  @override
  String get name => 'inventory';

  @override
  int get index => 9;

  @override
  String displayName() => 'مخزون';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class TangibleAssetsType extends MainAccountType {
  const TangibleAssetsType._()
    : super(
        accountNumber: '11',
        accountType: MainAccountGroup.assets,
        incrementName: 'عليه',
        decrementName: 'له',
        isAccountReal: true,
        isPeriodPermanent: true,
      );

  @override
  String get name => 'tangible_assets';

  @override
  int get index => 10;

  @override
  String displayName() => 'أصول ملموسة';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class IntangibleAssetsType extends MainAccountType {
  const IntangibleAssetsType._()
    : super(
        accountNumber: '12',
        accountType: MainAccountGroup.assets,
        incrementName: 'عليه',
        decrementName: 'له',
        isAccountReal: true,
        isPeriodPermanent: true,
      );

  @override
  String get name => 'in_tangible_assets';

  @override
  int get index => 11;

  @override
  String displayName() => 'أصول غير ملموسة';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class CreditorsType extends MainAccountType {
  const CreditorsType._()
    : super(
        accountNumber: '13',
        accountType: MainAccountGroup.liabilities,
        incrementName: 'له',
        decrementName: 'عليه',
        isAccountReal: true,
        isPeriodPermanent: true,
        isDefault: true,
      );

  @override
  String get name => 'creditors';

  @override
  int get index => 12;

  @override
  String displayName() => 'حسابات دائنة';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class MoneyHeadType extends MainAccountType {
  const MoneyHeadType._()
    : super(
        accountNumber: '14',
        accountType: MainAccountGroup.propertyRights,
        incrementName: 'له',
        decrementName: 'عليه',
        isAccountReal: true,
        isPeriodPermanent: true,
        isDefault: true,
      );

  @override
  String get name => 'money_head';

  @override
  int get index => 13;

  @override
  String displayName() => 'رأس مال';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class ProfitsAndLossType extends MainAccountType {
  const ProfitsAndLossType._()
    : super(
        accountNumber: '27',
        accountType: MainAccountGroup.propertyRights,
        incrementName: 'له',
        decrementName: 'عليه',
        isAccountReal: true,
        isPeriodPermanent: true,
        isDefault: true,
      );

  @override
  String get name => 'profits_and_loss';

  @override
  int get index => 14;

  @override
  String displayName() => 'الأرباح والخسائر';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class FutureRevenuesType extends MainAccountType {
  const FutureRevenuesType._()
    : super(
        accountNumber: '23',
        accountType: MainAccountGroup.assets,
        incrementName: 'عليه',
        decrementName: 'له',
        isAccountReal: true,
        isPeriodPermanent: false,
      );

  @override
  String get name => 'future_revenues';

  @override
  int get index => 15;

  @override
  String displayName() => 'ايرادات مستحقة';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class OfferRevenuesType extends MainAccountType {
  const OfferRevenuesType._()
    : super(
        accountNumber: '24',
        accountType: MainAccountGroup.liabilities,
        incrementName: 'له',
        decrementName: 'عليه',
        isAccountReal: true,
        isPeriodPermanent: false,
      );

  @override
  String get name => 'offer_revenues';

  @override
  int get index => 16;

  @override
  String displayName() => 'ايرادات مقدمة';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class FutureExpensesType extends MainAccountType {
  const FutureExpensesType._()
    : super(
        accountNumber: '26',
        accountType: MainAccountGroup.liabilities,
        incrementName: 'له',
        decrementName: 'عليه',
        isAccountReal: true,
        isPeriodPermanent: false,
      );

  @override
  String get name => 'future_expenses';

  @override
  int get index => 17;

  @override
  String displayName() => 'مصروفات مستحقة';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class OfferExpensesType extends MainAccountType {
  const OfferExpensesType._()
    : super(
        accountNumber: '25',
        accountType: MainAccountGroup.assets,
        incrementName: 'عليه',
        decrementName: 'له',
        isAccountReal: true,
        isPeriodPermanent: false,
      );

  @override
  String get name => 'offer_expenses';

  @override
  int get index => 18;

  @override
  String displayName() => 'مصروفات مقدمة';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}

final class CostOfSalesType extends MainAccountType {
  const CostOfSalesType._()
    : super(
        accountNumber: '27',
        accountType: MainAccountGroup.expenses,
        incrementName: 'له',
        decrementName: 'عليه',
        isAccountReal: false,
        isPeriodPermanent: false,
      );

  @override
  String get name => 'cost_of_sales';

  @override
  int get index => 19;

  @override
  String displayName() => 'تكلفة المبيعات';
  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;
}
