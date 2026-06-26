import 'package:flowcash/core/entities/entity.dart';

class InventoryTransactionOrderEntity extends Entity {
  final int id;
  final int? inventoryId;
  final double countUnits;
  final int tranId;

  const InventoryTransactionOrderEntity({
    required this.id,
    this.inventoryId,
    this.countUnits = 0.0,
    this.tranId = 0,
  });

  @override
  List<Object?> get props => [
    id,
    inventoryId,
    countUnits,
    tranId,
  ];

  @override
  InventoryTransactionOrderEntity copyWith({
    int? id,
    int? inventoryId,
    double? countUnits,
    int? tranId,
  }) {
    return InventoryTransactionOrderEntity(
      id: id ?? this.id,
      inventoryId: inventoryId ?? this.inventoryId,
      countUnits: countUnits ?? this.countUnits,
      tranId: tranId ?? this.tranId,
    );
  }
}
