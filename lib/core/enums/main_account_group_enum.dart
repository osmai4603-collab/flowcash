import 'package:flowcash/core/enums/account_status_enum.dart';
import 'package:flowcash/core/enums/accounting_period_type_enum.dart';

import 'app_enum.dart';

sealed class MainAccountGroup extends AppEnum
    implements NumberBasicAccountModel {
  const MainAccountGroup();

  int get priority;
  @override
  String get accountName => displayName();
  @override
  String get groupName => 'مجموعة حسابات $accountName';

  int getNewAccountNumber(int number) {
    return int.parse('$accountNumber$number');
  }

  static const assets = AssetsMainAccountGroup._();
  static const liabilities = LiabilitiesMainAccountGroup._();
  static const expenses = ExpensesMainAccountGroup._();
  static const revenues = RevenuesMainAccountGroup._();
  static const propertyRights = PropertyRightsMainAccountGroup._();

  static const List<MainAccountGroup> values = [
    assets,
    liabilities,
    expenses,
    revenues,
    propertyRights,
  ];

  static MainAccountGroup of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown MainAccountGroup: $name'),
    );
  }
}

mixin NumberBasicAccountModel {
  String get accountName;
  String get groupName;

  String get accountNumber;
  AccountStatus get accountStatus;
  AccountingsPeriodType get periodType;
}

final class AssetsMainAccountGroup extends MainAccountGroup {
  const AssetsMainAccountGroup._();

  @override
  String get accountNumber => '2';

  @override
  int get priority => 2;

  @override
  AccountStatus get accountStatus => AccountStatus.debtor;

  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;

  @override
  String get name => 'assets';

  @override
  int get index => 0;

  @override
  String displayName() => 'أصول';
}

final class LiabilitiesMainAccountGroup extends MainAccountGroup {
  const LiabilitiesMainAccountGroup._();

  @override
  String get accountNumber => '1';

  @override
  int get priority => 5;

  @override
  AccountStatus get accountStatus => AccountStatus.creditor;

  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;

  @override
  String get name => 'liabilities';

  @override
  int get index => 1;

  @override
  String displayName() => 'إلتزامات';
}

final class ExpensesMainAccountGroup extends MainAccountGroup {
  const ExpensesMainAccountGroup._();

  @override
  String get accountNumber => '4';

  @override
  int get priority => 3;

  @override
  AccountStatus get accountStatus => AccountStatus.debtor;

  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.temporary;

  @override
  String get name => 'expenses';

  @override
  int get index => 2;

  @override
  String displayName() => 'مصروفات';
}

final class RevenuesMainAccountGroup extends MainAccountGroup {
  const RevenuesMainAccountGroup._();

  @override
  String get accountNumber => '3';

  @override
  int get priority => 6;

  @override
  AccountStatus get accountStatus => AccountStatus.creditor;

  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.temporary;

  @override
  String get name => 'revenues';

  @override
  int get index => 3;

  @override
  String displayName() => 'ايرادات';
}

final class PropertyRightsMainAccountGroup extends MainAccountGroup {
  const PropertyRightsMainAccountGroup._();

  @override
  String get accountNumber => '5';

  @override
  int get priority => 7;

  @override
  AccountStatus get accountStatus => AccountStatus.creditor;

  @override
  AccountingsPeriodType get periodType => AccountingsPeriodType.permanent;

  @override
  String get name => 'property_rights';

  @override
  int get index => 4;

  @override
  String displayName() => 'حقوق ملكية';
}
