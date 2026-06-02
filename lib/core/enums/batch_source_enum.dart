import 'app_enum.dart';

sealed class BatchSource extends AppEnum {
  const BatchSource();

  static const buys = BuysBatchSource._();
  static const salesReturn = SalesReturnBatchSource._();
  static const productionUnits = ProductionUnitsBatchSource._();

  static const List<BatchSource> values = [
    buys,
    salesReturn,
    productionUnits,
  ];

  static BatchSource of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown BatchSource: $name'),
    );
  }
}

final class BuysBatchSource extends BatchSource {
  const BuysBatchSource._();

  @override
  String get name => 'buys';

  @override
  int get index => 0;

  @override
  String displayName() => 'مشتريات';
}

final class SalesReturnBatchSource extends BatchSource {
  const SalesReturnBatchSource._();

  @override
  String get name => 'sales_return';

  @override
  int get index => 1;

  @override
  String displayName() => 'مرتجع مبيعات';
}

final class ProductionUnitsBatchSource extends BatchSource {
  const ProductionUnitsBatchSource._();

  @override
  String get name => 'production_units';

  @override
  int get index => 2;

  @override
  String displayName() => 'واحدات إنتاج';
}
