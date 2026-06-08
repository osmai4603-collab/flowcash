import 'package:flowcash/core/enums/histories_group_enum.dart';

sealed class InventoryTransactionType extends HistoriesGroup {
  const InventoryTransactionType({
    required super.singleName,
    required super.totalName,
    required super.counterTypeName,
    required super.priority,
  });

  static const inventoryReceipt = InventoryReceiptTransactionType._();
  static const inventoryReceive = inventoryReceipt;
  static const inventoryDelivery = InventoryDeliveryTransactionType._();
  static const goodsCost = GoodsCostTransactionType._();

  static const List<InventoryTransactionType> values = [
    inventoryReceipt,
    inventoryDelivery,
    goodsCost,
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
  String get name => 'inventory_receive';

  @override
  int get index => 0;

  @override
  String displayName() => 'إذن إدخال';
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
  String get name => 'inventory_delivery';

  @override
  int get index => 1;

  @override
  String displayName() => 'إذن إخراج';
}

final class GoodsCostTransactionType extends InventoryTransactionType {
  const GoodsCostTransactionType._()
    : super(
        singleName: 'تكلفة بضاعة',
        totalName: 'تكلفة البضاعة',
        counterTypeName: 'تكلفة البضاعة',
        priority: 2,
      );

  @override
  String get name => 'goods_cost';

  @override
  int get index => 2;

  @override
  String displayName() => 'تكلفة بضاعة';
}
