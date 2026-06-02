import 'package:flowcash/core/enums/histories_group_enum.dart';

sealed class FinancialBondType extends HistoriesGroup {
  const FinancialBondType({
    required super.singleName,
    required super.totalName,
    required super.counterTypeName,
    required super.priority,
  });

  static const proceeds = ProceedsFinancialBondType._();
  static const paids = PaidsFinancialBondType._();
  static const deposits = DepositsFinancialBondType._();
  static const withdraws = WithdrawsFinancialBondType._();

  static const List<FinancialBondType> values = [
    proceeds,
    paids,
    deposits,
    withdraws,
  ];

  static FinancialBondType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown FinancialBondType: $name'),
    );
  }
}

final class ProceedsFinancialBondType extends FinancialBondType {
  const ProceedsFinancialBondType._()
    : super(
        singleName: 'أقساط مستلمة',
        totalName: 'أقساط مستلمة',
        counterTypeName: 'أقساط',
        priority: 7,
      );

  @override
  String get name => 'proceeds';

  @override
  int get index => 6;

  @override
  String displayName() => 'أقساط مستلمة';
}

final class PaidsFinancialBondType extends FinancialBondType {
  const PaidsFinancialBondType._()
    : super(
        singleName: 'دفعات مدفوعة',
        totalName: 'دفعات مدفوعة',
        counterTypeName: 'دفعات',
        priority: 8,
      );

  @override
  String get name => 'paids';

  @override
  int get index => 7;

  @override
  String displayName() => 'دفعات مدفوعة';
}

final class DepositsFinancialBondType extends FinancialBondType {
  const DepositsFinancialBondType._()
    : super(
        singleName: 'ايداع',
        totalName: 'ايداعات',
        counterTypeName: 'ايداعات',
        priority: 9,
      );

  @override
  String get name => 'deposits';

  @override
  int get index => 8;

  @override
  String displayName() => 'ايداع';
}

final class WithdrawsFinancialBondType extends FinancialBondType {
  const WithdrawsFinancialBondType._()
    : super(
        singleName: 'سحب',
        totalName: 'سحوبات',
        counterTypeName: 'سحوبات',
        priority: 10,
      );

  @override
  String get name => 'withdraws';

  @override
  int get index => 9;

  @override
  String displayName() => 'سحب';
}
