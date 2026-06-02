import 'package:flowcash/core/enums/histories_group_enum.dart';

sealed class FinancialTransactionType extends HistoriesGroup {
  const FinancialTransactionType({
    required super.singleName,
    required super.totalName,
    required super.counterTypeName,
    required super.priority,
  });

  static const sales = SalesFinancialTransactionType._();
  static const buys = BuysFinancialTransactionType._();
  static const buysReturn = BuysReturnFinancialTransactionType._();
  static const salesReturn = SalesReturnFinancialTransactionType._();
  static const expenses = ExpensesFinancialTransactionType._();
  static const revenues = RevenuesFinancialTransactionType._();

  static const List<FinancialTransactionType> values = [
    sales,
    buys,
    buysReturn,
    salesReturn,
    expenses,
    revenues,
  ];

  static FinancialTransactionType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown FinancialTransactionType: $name'),
    );
  }
}

final class SalesFinancialTransactionType extends FinancialTransactionType {
  const SalesFinancialTransactionType._()
      : super(
          singleName: 'فاتورة بيع',
          totalName: 'فواتير مبيعات',
          counterTypeName: 'فواتير مبيعات',
          priority: 1,
        );

  @override
  String get name => 'sales';

  @override
  int get index => 0;

  @override
  String displayName() => 'فاتورة بيع';
}

final class BuysFinancialTransactionType extends FinancialTransactionType {
  const BuysFinancialTransactionType._()
      : super(
          singleName: 'فاتورة شراء',
          totalName: 'فواتير مشتريات',
          counterTypeName: 'فواتير مشتريات',
          priority: 2,
        );

  @override
  String get name => 'buys';

  @override
  int get index => 1;

  @override
  String displayName() => 'فاتورة شراء';
}

final class BuysReturnFinancialTransactionType extends FinancialTransactionType {
  const BuysReturnFinancialTransactionType._()
      : super(
          singleName: 'فاتورة مرتجع شراء',
          totalName: 'فواتير مرتجع مشتريات',
          counterTypeName: 'فواتير مشتريات',
          priority: 3,
        );

  @override
  String get name => 'buys_return';

  @override
  int get index => 2;

  @override
  String displayName() => 'فاتورة مرتجع شراء';
}

final class SalesReturnFinancialTransactionType extends FinancialTransactionType {
  const SalesReturnFinancialTransactionType._()
      : super(
          singleName: 'فاتورة مرتجع بيع',
          totalName: 'فواتير مرتجع مبيعات',
          counterTypeName: 'فواتير مبيعات',
          priority: 4,
        );

  @override
  String get name => 'sales_return';

  @override
  int get index => 3;

  @override
  String displayName() => 'فاتورة مرتجع بيع';
}

final class ExpensesFinancialTransactionType extends FinancialTransactionType {
  const ExpensesFinancialTransactionType._()
      : super(
          singleName: 'مصروف',
          totalName: 'مصروفات',
          counterTypeName: 'مصروفات',
          priority: 5,
        );

  @override
  String get name => 'expenses';

  @override
  int get index => 4;

  @override
  String displayName() => 'مصروف';
}

final class RevenuesFinancialTransactionType extends FinancialTransactionType {
  const RevenuesFinancialTransactionType._()
      : super(
          singleName: 'ايراد',
          totalName: 'ايرادات',
          counterTypeName: 'ايرادات',
          priority: 6,
        );

  @override
  String get name => 'revenues';

  @override
  int get index => 5;

  @override
  String displayName() => 'ايراد';
}
