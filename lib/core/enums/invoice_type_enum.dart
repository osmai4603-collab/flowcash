import 'package:flowcash/core/enums/histories_group_enum.dart';

sealed class InvoiceType extends HistoriesGroup {
  const InvoiceType({
    required super.singleName,
    required super.totalName,
    required super.counterTypeName,
    required super.priority,
  });

  static const sales = SalesInvoiceType._();
  static const buys = PurchaseInvoiceType._();
  static const salesReturn = SalesReturnInvoiceType._();
  static const buysReturn = PurchaseReturnInvoiceType._();

  static const List<InvoiceType> values = [
    sales,
    buys,
    salesReturn,
    buysReturn,
  ];

  static InvoiceType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown InvoiceType: $name'),
    );
  }
}

final class SalesInvoiceType extends InvoiceType {
  const SalesInvoiceType._()
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
  String displayName() => 'فاتورة مبيعات';
}

final class PurchaseInvoiceType extends InvoiceType {
  const PurchaseInvoiceType._()
    : super(
        singleName: 'فاتورة شراء',
        totalName: 'فواتير مشتريات',
        counterTypeName: 'فواتير مشتريات',
        priority: 2,
      );

  @override
  String get name => 'purchase';

  @override
  int get index => 1;

  @override
  String displayName() => 'فاتورة مشتريات';
}

final class SalesReturnInvoiceType extends InvoiceType {
  const SalesReturnInvoiceType._()
    : super(
        singleName: 'فاتورة مرتجع بيع',
        totalName: 'فواتير مرتجع مبيعات',
        counterTypeName: 'فواتير مبيعات',
        priority: 3,
      );

  @override
  String get name => 'sales_return';

  @override
  int get index => 2;

  @override
  String displayName() => 'فاتورة مرتجع مبيعات';
}

final class PurchaseReturnInvoiceType extends InvoiceType {
  const PurchaseReturnInvoiceType._()
    : super(
        singleName: 'فاتورة مرتجع شراء',
        totalName: 'فواتير مرتجع مشتريات',
        counterTypeName: 'فواتير مشتريات',
        priority: 4,
      );

  @override
  String get name => 'purchase_return';

  @override
  int get index => 3;

  @override
  String displayName() => 'فاتورة مرتجع مشتريات';
}
