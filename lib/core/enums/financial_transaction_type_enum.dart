import 'package:flowcash/core/enums/histories_group_enum.dart';

sealed class FinancialTransactionType extends HistoriesGroup {
  const FinancialTransactionType({
    required super.singleName,
    required super.totalName,
    required super.counterTypeName,
    required super.priority,
  });

 static const expenses = ExpensesFinancialTransactionType._();
  static const revenues = RevenuesFinancialTransactionType._();

  static const List<FinancialTransactionType> values = [
    
    expenses,
    revenues,
  ];

  static FinancialTransactionType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () =>
          throw ArgumentError('Unknown FinancialTransactionType: $name'),
    );
  }
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
