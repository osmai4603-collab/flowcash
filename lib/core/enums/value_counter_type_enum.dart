import 'app_enum.dart';

sealed class ValueCounterType extends AppEnum {
  const ValueCounterType();

  static const billNumber = BillNumberValueCounterType._();
  static const invoiceNumber = InvoiceNumberValueCounterType._();
  static const receiptNumber = ReceiptNumberValueCounterType._();

  static const List<ValueCounterType> values = [
    billNumber,
    invoiceNumber,
    receiptNumber,
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
