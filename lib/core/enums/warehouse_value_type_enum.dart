import 'app_enum.dart';

sealed class WarehouseValueType extends AppEnum {
  final String typeName;
  final DataType dataType;
  const WarehouseValueType({required this.typeName, required this.dataType});

  static const defaultSalesAccount = DefaultSalesAccount._();
  static const defaultBuysAccount = DefaultBuysAccount._();
  static const defaultBackSalesAccount = DefaultBackSalesAccount._();
  static const defaultBackBuysAccount = DefaultBackBuysAccount._();

  static const List<WarehouseValueType> values = [
    defaultSalesAccount,
    defaultBuysAccount,
    defaultBackSalesAccount,
    defaultBackBuysAccount,
  ];

  static WarehouseValueType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown WarehouseValueType: $name'),
    );
  }

  @override
  String displayName() => typeName;
}

final class DefaultSalesAccount extends WarehouseValueType {
  const DefaultSalesAccount._()
    : super(typeName: 'حساب المبيعات الافتراضي', dataType: DataType.integer);

  @override
  String get name => 'defaultSalesAccount';

  @override
  int get index => 0;
}

final class DefaultBuysAccount extends WarehouseValueType {
  const DefaultBuysAccount._()
    : super(typeName: 'حساب المشتريات الافتراضي', dataType: DataType.integer);

  @override
  String get name => 'defaultBuysAccount';

  @override
  int get index => 1;
}

final class DefaultBackSalesAccount extends WarehouseValueType {
  const DefaultBackSalesAccount._()
    : super(
        typeName: 'حساب مرتجع المبيعات الافتراضي',
        dataType: DataType.integer,
      );

  @override
  String get name => 'defaultBackSalesAccount';

  @override
  int get index => 2;
}

final class DefaultBackBuysAccount extends WarehouseValueType {
  const DefaultBackBuysAccount._()
    : super(
        typeName: 'حساب مرتجع المشتريات الافتراضي',
        dataType: DataType.integer,
      );

  @override
  String get name => 'defaultBackBuysAccount';

  @override
  int get index => 3;
}

enum DataType { integer, real, text, boolean }
