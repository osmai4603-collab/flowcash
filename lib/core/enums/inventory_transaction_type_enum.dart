import 'package:flowcash/core/enums/histories_group_enum.dart';

sealed class InventoryTransactionType extends HistoriesGroup {
  const InventoryTransactionType({
    required super.singleName,
    required super.totalName,
    required super.counterTypeName,
    required super.priority,
  });

  static const importInventory = InventoryReceiptTransactionType._();
  static const exportInventory = InventoryDeliveryTransactionType._();

  static const List<InventoryTransactionType> values = [
    importInventory,
    exportInventory,
  ];

  static InventoryTransactionType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () =>
          throw ArgumentError('Unknown InventoryTransactionType: $name'),
    );
  }
}

final class InventoryReceiptTransactionType extends InventoryTransactionType {
  const InventoryReceiptTransactionType._()
    : super(
        singleName: 'إذن إدخال',
        totalName: 'أذون إدخال',
        counterTypeName: 'أذون إخراج',
        priority: 0,
      );

  @override
  String get name => 'import_inventory';

  @override
  int get index => 0;

  @override
  String displayName() => 'استلام مخزني';
}

final class InventoryDeliveryTransactionType extends InventoryTransactionType {
  const InventoryDeliveryTransactionType._()
    : super(
        singleName: 'إذن إخراج',
        totalName: 'أذون إخراج',
        counterTypeName: 'أذون إدخال',
        priority: 1,
      );

  @override
  String get name => 'export_inventory';

  @override
  int get index => 1;

  @override
  String displayName() => 'صرف مخزني';
}

