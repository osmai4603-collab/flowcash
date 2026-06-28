import 'app_enum.dart';
import 'inventory_transaction_type_enum.dart';

sealed class InventoryTransactionNature extends AppEnum {
  final String arabicName;
  final InventoryTransactionType transactionType;

  const InventoryTransactionNature({
    required this.arabicName,
    required this.transactionType,
  });

  static const sales = SalesNature._();
  static const salesReturn = SalesReturnNature._();
  static const purchases = PurchasesNature._();
  static const purchasesReturn = PurchasesReturnNature._();
  static const openingQuantities = OpeningQuantitiesNature._();
  static const importWarehouseTransfer = ImportWarehouseTransferNature._();
  static const exportWarehouseTransfer = ExportWarehouseTransferNature._();

  static const List<InventoryTransactionNature> values = [
    sales,
    salesReturn,
    purchases,
    purchasesReturn,
    openingQuantities,
    importWarehouseTransfer,
    exportWarehouseTransfer,
  ];

  static InventoryTransactionNature of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown InventoryTransactionNature: $name'),
    );
  }

  @override
  String displayName() => arabicName;
}

final class SalesNature extends InventoryTransactionNature {
  const SalesNature._()
      : super(
          arabicName: 'مبيعات',
          transactionType: InventoryTransactionType.exportInventory,
        );

  @override
  String get name => 'sales';

  @override
  int get index => 0;
}

final class SalesReturnNature extends InventoryTransactionNature {
  const SalesReturnNature._()
      : super(
          arabicName: 'مرتجع مبيعات',
          transactionType: InventoryTransactionType.importInventory,
        );

  @override
  String get name => 'sales_return';

  @override
  int get index => 1;
}

final class PurchasesNature extends InventoryTransactionNature {
  const PurchasesNature._()
      : super(
          arabicName: 'مشتريات',
          transactionType: InventoryTransactionType.importInventory,
        );

  @override
  String get name => 'purchases';

  @override
  int get index => 2;
}

final class PurchasesReturnNature extends InventoryTransactionNature {
  const PurchasesReturnNature._()
      : super(
          arabicName: 'مرتجع مشتريات',
          transactionType: InventoryTransactionType.exportInventory,
        );

  @override
  String get name => 'purchases_return';

  @override
  int get index => 3;
}

final class OpeningQuantitiesNature extends InventoryTransactionNature {
  const OpeningQuantitiesNature._()
      : super(
          arabicName: 'كميات افتتاحية',
          transactionType: InventoryTransactionType.importInventory,
        );

  @override
  String get name => 'opening_quantities';

  @override
  int get index => 4;
}

final class ImportWarehouseTransferNature extends InventoryTransactionNature {
  const ImportWarehouseTransferNature._()
      : super(
          arabicName: 'نقل مخزني وارد',
          transactionType: InventoryTransactionType.importInventory,
        );

  @override
  String get name => 'import_warehouse_transfer';

  @override
  int get index => 5;
}

final class ExportWarehouseTransferNature extends InventoryTransactionNature {
  const ExportWarehouseTransferNature._()
      : super(
          arabicName: 'نقل مخزني صادر',
          transactionType: InventoryTransactionType.exportInventory,
        );

  @override
  String get name => 'export_warehouse_transfer';

  @override
  int get index => 6;
}
