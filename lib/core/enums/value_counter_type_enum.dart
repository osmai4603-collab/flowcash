import 'app_enum.dart';

sealed class ValueCounterType extends AppEnum {
  const ValueCounterType();

  static const billNumber = BillNumberValueCounterType._();
  static const invoiceNumber = InvoiceNumberValueCounterType._();
  static const receiptNumber = ReceiptNumberValueCounterType._();
  static const categoryNumber = CategoryNumberValueCounterType._();
  static const salesInvoiceNumber = SalesInvoiceNumberValueCounterType._();
  static const purchaseInvoiceNumber = PurchaseInvoiceNumberValueCounterType._();
  static const salesReturnInvoiceNumber = SalesReturnInvoiceNumberValueCounterType._();
  static const purchaseReturnInvoiceNumber = PurchaseReturnInvoiceNumberValueCounterType._();
  static const stockMovementOutInvoiceNumber = StockMovementOutInvoiceNumberValueCounterType._();
  static const stockMovementInInvoiceNumber = StockMovementInInvoiceNumberValueCounterType._();

  static const List<ValueCounterType> values = [
    billNumber,
    invoiceNumber,
    receiptNumber,
    categoryNumber,
    salesInvoiceNumber,
    purchaseInvoiceNumber,
    salesReturnInvoiceNumber,
    purchaseReturnInvoiceNumber,
    stockMovementOutInvoiceNumber,
    stockMovementInInvoiceNumber,
  ];

  static ValueCounterType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown ValueCounterType: $name'),
    );
  }
}

final class BillNumberValueCounterType extends ValueCounterType {
  const BillNumberValueCounterType._();

  @override
  String get name => 'bill_number';

  @override
  int get index => 0;

  @override
  String displayName() => 'رقم الفاتورة';
}

final class InvoiceNumberValueCounterType extends ValueCounterType {
  const InvoiceNumberValueCounterType._();

  @override
  String get name => 'invoice_number';

  @override
  int get index => 1;

  @override
  String displayName() => 'رقم الفاتورة الضريبية';
}

final class ReceiptNumberValueCounterType extends ValueCounterType {
  const ReceiptNumberValueCounterType._();

  @override
  String get name => 'receipt_number';

  @override
  int get index => 2;

  @override
  String displayName() => 'رقم الإيصال';
}

final class CategoryNumberValueCounterType extends ValueCounterType {
  const CategoryNumberValueCounterType._();

  @override
  String get name => 'category_number';

  @override
  int get index => 3;

  @override
  String displayName() => 'رقم الصنف';
}

final class SalesInvoiceNumberValueCounterType extends ValueCounterType {
  const SalesInvoiceNumberValueCounterType._();

  @override
  String get name => 'sales_invoice_number';

  @override
  int get index => 4;

  @override
  String displayName() => 'فاتورة المبيعات';
}

final class PurchaseInvoiceNumberValueCounterType extends ValueCounterType {
  const PurchaseInvoiceNumberValueCounterType._();

  @override
  String get name => 'purchase_invoice_number';

  @override
  int get index => 5;

  @override
  String displayName() => 'فاتورة المشتريات';
}

final class SalesReturnInvoiceNumberValueCounterType extends ValueCounterType {
  const SalesReturnInvoiceNumberValueCounterType._();

  @override
  String get name => 'sales_return_invoice_number';

  @override
  int get index => 6;

  @override
  String displayName() => 'فاتورة المبيعات المرتجع';
}

final class PurchaseReturnInvoiceNumberValueCounterType extends ValueCounterType {
  const PurchaseReturnInvoiceNumberValueCounterType._();

  @override
  String get name => 'purchase_return_invoice_number';

  @override
  int get index => 7;

  @override
  String displayName() => 'فاتورة المشتريات المرتجع';
}

final class StockMovementOutInvoiceNumberValueCounterType extends ValueCounterType {
  const StockMovementOutInvoiceNumberValueCounterType._();

  @override
  String get name => 'stock_movement_out_invoice_number';

  @override
  int get index => 8;

  @override
  String displayName() => 'فاتورة حركة مخزنية صادرة';
}

final class StockMovementInInvoiceNumberValueCounterType extends ValueCounterType {
  const StockMovementInInvoiceNumberValueCounterType._();

  @override
  String get name => 'stock_movement_in_invoice_number';

  @override
  int get index => 9;

  @override
  String displayName() => 'فاتورة حركة مخزنية واردة';
}
