import 'app_enum.dart';

sealed class AccountingInventoryType extends AppEnum {
  final String typeName;
  const AccountingInventoryType({required this.typeName});

  String get theTypeName => 'ال$typeName';
  String get fullTypeName => 'جرد $typeName';
  String get theFullTypeName => 'الجرد $theTypeName';

  static const periodic = PeriodicAccountingInventoryType._();
  static const perpetual = PerpetualAccountingInventoryType._();

  static const List<AccountingInventoryType> values = [
    periodic,
    perpetual,
  ];

  static AccountingInventoryType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown AccountingInventoryType: $name'),
    );
  }

  @override
  String displayName() => typeName;
}

final class PeriodicAccountingInventoryType extends AccountingInventoryType {
  const PeriodicAccountingInventoryType._() : super(typeName: 'دوري');

  @override
  String get name => 'periodic';

  @override
  int get index => 0;
}

final class PerpetualAccountingInventoryType extends AccountingInventoryType {
  const PerpetualAccountingInventoryType._() : super(typeName: 'مستمر');

  @override
  String get name => 'perpetual';

  @override
  int get index => 1;
}
