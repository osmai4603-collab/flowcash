import 'app_enum.dart';

sealed class WarehouseType extends AppEnum {
  final String typeName;
  const WarehouseType({required this.typeName});

  static const branch = BranchWarehouseType._();
  static const warehouse = WarehouseWarehouseType._();

  static const List<WarehouseType> values = [branch, warehouse];

  static WarehouseType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown WarehouseType: $name'),
    );
  }

  @override
  String displayName() => typeName;
}

final class BranchWarehouseType extends WarehouseType { const BranchWarehouseType._() : super(typeName: 'فرع'); @override String get name => 'branch'; @override int get index => 0; }
final class WarehouseWarehouseType extends WarehouseType { const WarehouseWarehouseType._() : super(typeName: 'مستودع'); @override String get name => 'warehouse'; @override int get index => 1; }
