import 'app_enum.dart';

sealed class CounterType extends AppEnum {
  final String typeName;

  const CounterType({required this.typeName});

  static const salesBills = SalesBillsCounterType._();
  static const buysBills = BuysBillsCounterType._();
  static const proceeds = ProceedsCounterType._();
  static const paids = PaidsCounterType._();
  static const openingEntries = OpeningEntriesCounterType._();
  static const closingEntries = ClosingEntriesCounterType._();
  static const deposits = DepositsCounterType._();
  static const withdraws = WithdrawsCounterType._();
  static const revenues = RevenuesCounterType._();
  static const expenses = ExpensesCounterType._();
  static const assetsBuys = AssetsBuysCounterType._();
  static const assetsSales = AssetsSalesCounterType._();
  static const goodsReceipt = GoodsReceiptCounterType._();
  static const goodsDelivery = GoodsDeliveryCounterType._();

  static const List<CounterType> values = [
    salesBills,
    buysBills,
    proceeds,
    paids,
    openingEntries,
    closingEntries,
    deposits,
    withdraws,
    revenues,
    expenses,
    assetsBuys,
    assetsSales,
    goodsReceipt,
    goodsDelivery,
  ];

  static CounterType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown CounterType: $name'),
    );
  }

  @override
  String get name;

  @override
  int get index;

  @override
  String displayName() => typeName;
}

final class SalesBillsCounterType extends CounterType {
  const SalesBillsCounterType._() : super(typeName: 'فواتير مبيعات');

  @override
  String get name => 'salesBills';

  @override
  int get index => 0;
}

final class BuysBillsCounterType extends CounterType {
  const BuysBillsCounterType._() : super(typeName: 'فواتير مشتريات');

  @override
  String get name => 'buysBills';

  @override
  int get index => 1;
}

final class ProceedsCounterType extends CounterType {
  const ProceedsCounterType._() : super(typeName: 'اسناد قبض');

  @override
  String get name => 'proceeds';

  @override
  int get index => 2;
}

final class PaidsCounterType extends CounterType {
  const PaidsCounterType._() : super(typeName: 'اسناد دفع');

  @override
  String get name => 'paids';

  @override
  int get index => 3;
}

final class OpeningEntriesCounterType extends CounterType {
  const OpeningEntriesCounterType._() : super(typeName: 'ارصدة افتتاحية');

  @override
  String get name => 'openingEntries';

  @override
  int get index => 4;
}

final class ClosingEntriesCounterType extends CounterType {
  const ClosingEntriesCounterType._() : super(typeName: 'ارصدة اقفال');

  @override
  String get name => 'closingEntries';

  @override
  int get index => 5;
}

final class DepositsCounterType extends CounterType {
  const DepositsCounterType._() : super(typeName: 'ايداع');

  @override
  String get name => 'deposits';

  @override
  int get index => 6;
}

final class WithdrawsCounterType extends CounterType {
  const WithdrawsCounterType._() : super(typeName: 'سحبية');

  @override
  String get name => 'withdraws';

  @override
  int get index => 7;
}

final class RevenuesCounterType extends CounterType {
  const RevenuesCounterType._() : super(typeName: 'اسناد الايرادات');

  @override
  String get name => 'revenues';

  @override
  int get index => 8;
}

final class ExpensesCounterType extends CounterType {
  const ExpensesCounterType._() : super(typeName: 'اسناد المصروفات');

  @override
  String get name => 'expenses';

  @override
  int get index => 9;
}

final class AssetsBuysCounterType extends CounterType {
  const AssetsBuysCounterType._() : super(typeName: 'مشتريات الاصول');

  @override
  String get name => 'assetsBuys';

  @override
  int get index => 10;
}

final class AssetsSalesCounterType extends CounterType {
  const AssetsSalesCounterType._() : super(typeName: 'مبيعات الاصول');

  @override
  String get name => 'assetsSales';

  @override
  int get index => 11;
}

final class GoodsReceiptCounterType extends CounterType {
  const GoodsReceiptCounterType._() : super(typeName: 'اسناد استلام البضائع');

  @override
  String get name => 'goodsReceipt';

  @override
  int get index => 12;
}

final class GoodsDeliveryCounterType extends CounterType {
  const GoodsDeliveryCounterType._() : super(typeName: 'اسناد تسليم البضائع');

  @override
  String get name => 'goodsDelivery';

  @override
  int get index => 13;
}
