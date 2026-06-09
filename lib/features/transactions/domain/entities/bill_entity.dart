import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';

class BillEntity extends Entity {
  final int id;
  final DateTime createdAt;
  final int createdBy;
  final String? note;
  final double offerAmount;
  final String currencyId;
  final int billNumber;
  final int warehouseId;
  final int? journalEntryId;
  final int? personId;
  final int? inventoryTransactionId;
  final bool isCash;
  final InvoiceType billType;
  final List<BillOrderEntity> orders;

  const BillEntity({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    this.note,
    required this.offerAmount,
    required this.currencyId,
    required this.billNumber,
    required this.warehouseId,
    this.journalEntryId,
    this.personId,
    this.inventoryTransactionId,
    required this.isCash,
    required this.billType,
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
    inventoryTransactionId,
    isCash,
    billType,
    orders,
  ];

  @override
  BillEntity copyWith({
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
    int? inventoryTransactionId,
    bool? isCash,
    InvoiceType? billType,
    List<BillOrderEntity>? orders,
  }) {
    return BillEntity(
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
      inventoryTransactionId:
          inventoryTransactionId ?? this.inventoryTransactionId,
      isCash: isCash ?? this.isCash,
      billType: billType ?? this.billType,
      orders: orders ?? this.orders,
    );
  }
}
