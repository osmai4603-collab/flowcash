import 'app_enum.dart';

sealed class PersonType extends AppEnum {
  final String typeName;
  const PersonType({required this.typeName});

  static const supplier = SupplierPersonType._();
  static const client = ClientPersonType._();
  static const employee = EmployeePersonType._();
  static const revenues = RevenuesPersonType._();
  static const expenses = ExpensesPersonType._();
  static const cash = CashPersonType._();
  static const bank = BankPersonType._();
  static const inventory = InventoryPersonType._();
  static const debtor = DebtorPersonType._();
  static const creditor = CreditorPersonType._();
  static const propertyRights = PropertyRightsPersonType._();
  static const other = OtherPersonType._();
  static const sales = SalesPersonType._();
  static const buys = BuysPersonType._();
  static const salesReturn = SalesReturnPersonType._();
  static const buysReturn = BuysReturnPersonType._();
  static const costOfSales = CostOfSalesPersonType._();
  static const assets = AssetsPersonType._();
  static const moneyHead = MoneyHeadPersonType._();
  static const cashTreasury = CashTreasuryPersonType._();

  static const List<PersonType> values = [
    supplier,
    client,
    employee,
    revenues,
    expenses,
    cash,
    bank,
    inventory,
    debtor,
    creditor,
    propertyRights,
    other,
    sales,
    buys,
    salesReturn,
    buysReturn,
    costOfSales,
    assets,
    moneyHead,
    cashTreasury,
  ];

  static PersonType of(String name) {
    return values.firstWhere((e) => e.name == name, orElse: () => other);
  }

  @override
  String displayName() => typeName;

  bool get isPerson {
    return this == supplier || this == client || this == employee;
  }
}

final class SupplierPersonType extends PersonType {
  const SupplierPersonType._() : super(typeName: 'مورد');
  @override
  String get name => 'supplier';
  @override
  int get index => 0;
}

final class ClientPersonType extends PersonType {
  const ClientPersonType._() : super(typeName: 'عميل');
  @override
  String get name => 'client';
  @override
  int get index => 1;
}

final class EmployeePersonType extends PersonType {
  const EmployeePersonType._() : super(typeName: 'موظف');
  @override
  String get name => 'employee';
  @override
  int get index => 2;
}

final class RevenuesPersonType extends PersonType {
  const RevenuesPersonType._() : super(typeName: 'إيراد');
  @override
  String get name => 'revenues';
  @override
  int get index => 3;
}

final class ExpensesPersonType extends PersonType {
  const ExpensesPersonType._() : super(typeName: 'مصروف');
  @override
  String get name => 'expenses';
  @override
  int get index => 4;
}

final class CashPersonType extends PersonType {
  const CashPersonType._() : super(typeName: 'نقدي');
  @override
  String get name => 'cash';
  @override
  int get index => 5;
}

final class BankPersonType extends PersonType {
  const BankPersonType._() : super(typeName: 'بنكي');
  @override
  String get name => 'bank';
  @override
  int get index => 6;
}

final class InventoryPersonType extends PersonType {
  const InventoryPersonType._() : super(typeName: 'مخزون');
  @override
  String get name => 'inventory';
  @override
  int get index => 7;
}

final class DebtorPersonType extends PersonType {
  const DebtorPersonType._() : super(typeName: 'مدين');
  @override
  String get name => 'debtor';
  @override
  int get index => 8;
}

final class CreditorPersonType extends PersonType {
  const CreditorPersonType._() : super(typeName: 'دائن');
  @override
  String get name => 'creditor';
  @override
  int get index => 9;
}

final class PropertyRightsPersonType extends PersonType {
  const PropertyRightsPersonType._() : super(typeName: 'حقوق ملكية');
  @override
  String get name => 'property_rights';
  @override
  int get index => 10;
}

final class OtherPersonType extends PersonType {
  const OtherPersonType._() : super(typeName: 'اخرى');
  @override
  String get name => 'other';
  @override
  int get index => 11;
}

final class SalesPersonType extends PersonType {
  const SalesPersonType._() : super(typeName: 'مبيعات');
  @override
  String get name => 'sales';
  @override
  int get index => 12;
}

final class BuysPersonType extends PersonType {
  const BuysPersonType._() : super(typeName: 'مشتريات');
  @override
  String get name => 'buys';
  @override
  int get index => 13;
}

final class SalesReturnPersonType extends PersonType {
  const SalesReturnPersonType._() : super(typeName: 'مرتجع مبيعات');
  @override
  String get name => 'sales_return';
  @override
  int get index => 14;
}

final class BuysReturnPersonType extends PersonType {
  const BuysReturnPersonType._() : super(typeName: 'مرتجع مشتريات');
  @override
  String get name => 'buys_return';
  @override
  int get index => 15;
}

final class CostOfSalesPersonType extends PersonType {
  const CostOfSalesPersonType._() : super(typeName: 'تكلفة مبيعات');
  @override
  String get name => 'cost_of_sales';
  @override
  int get index => 16;
}

final class AssetsPersonType extends PersonType {
  const AssetsPersonType._() : super(typeName: 'اصول');
  @override
  String get name => 'assets';
  @override
  int get index => 17;
}

final class MoneyHeadPersonType extends PersonType {
  const MoneyHeadPersonType._() : super(typeName: 'رأس مال');
  @override
  String get name => 'money_head';
  @override
  int get index => 18;
}

final class CashTreasuryPersonType extends PersonType {
  const CashTreasuryPersonType._() : super(typeName: 'الخزينة النقدية');
  @override
  String get name => 'cash_treasury';
  @override
  int get index => 19;
}
