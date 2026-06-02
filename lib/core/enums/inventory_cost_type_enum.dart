import 'app_enum.dart';

sealed class InventoryCostType extends AppEnum {
  const InventoryCostType();

  static const fifo = FifoInventoryCostType._();
  static const lifo = LifoInventoryCostType._();
  static const costAVG = CostAvgInventoryCostType._();
  static const manually = ManuallyInventoryCostType._();

  static const List<InventoryCostType> values = [
    fifo,
    lifo,
    costAVG,
    manually,
  ];

  static InventoryCostType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown InventoryCostType: $name'),
    );
  }
}

final class FifoInventoryCostType extends InventoryCostType {
  const FifoInventoryCostType._();

  @override
  String get name => 'fifo';

  @override
  int get index => 0;

  @override
  String displayName() => 'الداخل اولا الخارج اولا';
}

final class LifoInventoryCostType extends InventoryCostType {
  const LifoInventoryCostType._();

  @override
  String get name => 'lifo';

  @override
  int get index => 1;

  @override
  String displayName() => 'الداخل اخرا الخارج اولا';
}

final class CostAvgInventoryCostType extends InventoryCostType {
  const CostAvgInventoryCostType._();

  @override
  String get name => 'cost_avg';

  @override
  int get index => 2;

  @override
  String displayName() => 'المتوسط الحسابي';
}

final class ManuallyInventoryCostType extends InventoryCostType {
  const ManuallyInventoryCostType._();

  @override
  String get name => 'manually';

  @override
  int get index => 3;

  @override
  String displayName() => 'يدوي';
}
