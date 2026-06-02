import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';

class InventoryTransactionEntity extends Entity {
  final int id;
  final DateTime createdAt;
  final int createdBy;
  final String? note;
  final int warehouseId;
  final int personId;
  final int billNumber;
  final InventoryTransactionType transactionType;
  final List<InventoryTransactionOrderEntity> orders;

  const InventoryTransactionEntity({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    this.note,
    this.warehouseId = 0,
    this.personId = 0,
    this.billNumber = 0,
    this.transactionType = InventoryTransactionType.inventoryReceipt,
    this.orders = const [],
  });

  @override
  List<Object?> get props => [id, createdAt, createdBy, note, warehouseId, personId, billNumber, transactionType];

  @override
  InventoryTransactionEntity copyWith({
    int? id,
    DateTime? createdAt,
    int? createdBy,
    String? note,
    int? warehouseId,
    int? personId,
    int? billNumber,
    InventoryTransactionType? transactionType,
    List<InventoryTransactionOrderEntity>? orders,
  }) {
    return InventoryTransactionEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      note: note ?? this.note,
      warehouseId: warehouseId ?? this.warehouseId,
      personId: personId ?? this.personId,
      billNumber: billNumber ?? this.billNumber,
      transactionType: transactionType ?? this.transactionType,
      orders: orders ?? this.orders,
    );
  }
}