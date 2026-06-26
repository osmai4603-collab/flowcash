import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/features/transactions/domain/entities/cost_good_bill_order_entity.dart';

class CostGoodBillEntity extends Entity {
  final int id;
  final DateTime createdAt;
  final int createdBy;
  final String? note;
  final double offerAmount;
  final String currencyId;
  final int billNumber;
  final int warehouseId;
  final int? journalEntryId;
  final int personId;
  final int billId;
  final List<CostGoodBillOrderEntity> orders;

  const CostGoodBillEntity({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    this.note,
    required this.offerAmount,
    required this.currencyId,
    required this.billNumber,
    required this.warehouseId,
    this.journalEntryId,
    required this.personId,
    required this.billId,
    this.orders = const [],
  });

  @override
  List<Object?> get props => [
    id,
    createdAt,
    createdBy,
    note,
    offerAmount,
    currencyId,
    billNumber,
    warehouseId,
    journalEntryId,
    personId,
    billId,
    orders,
  ];

  @override
  CostGoodBillEntity copyWith({
    int? id,
    DateTime? createdAt,
    int? createdBy,
    String? note,
    double? offerAmount,
    String? currencyId,
    int? billNumber,
    int? warehouseId,
    int? journalEntryId,
    int? personId,
    int? billId,
    List<CostGoodBillOrderEntity>? orders,
  }) {
    return CostGoodBillEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      note: note ?? this.note,
      offerAmount: offerAmount ?? this.offerAmount,
      currencyId: currencyId ?? this.currencyId,
      billNumber: billNumber ?? this.billNumber,
      warehouseId: warehouseId ?? this.warehouseId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      personId: personId ?? this.personId,
      billId: billId ?? this.billId,
      orders: orders ?? this.orders,
    );
  }
}
