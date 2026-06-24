import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/core/tables/bills_table.dart';

final class BillModel extends BillEntity {
  const BillModel({
    required super.id,
    required super.createdAt,
    required super.createdBy,
    super.note,
    required super.offerAmount,
    required super.currencyId,
    required super.billNumber,
    required super.warehouseId,
    super.journalEntryId,
    super.personId,
    super.inventoryTransactionId,
    required super.isCash,
    required super.billType,
    super.costGoodId,
    super.treasuryId,
    super.orders = const [],
  });

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map[BillsTable.id] as int,
      createdAt: DateTime.parse(map[BillsTable.createdAt] as String),
      createdBy: map[BillsTable.createdBy] as int,
      note: map[BillsTable.note] as String?,
      offerAmount: (map[BillsTable.offerAmount] ?? 0.0).toDouble(),
      currencyId: map[BillsTable.currencyId] as String? ?? '',
      billNumber: map[BillsTable.billNumber] as int,
      warehouseId: map[BillsTable.warehouseId] as int,
      journalEntryId: map[BillsTable.journalEntryId] as int?,
      personId: map[BillsTable.personId] as int?,
      inventoryTransactionId: map[BillsTable.inventoryTransactionId] as int?,
      isCash: map[BillsTable.isCash] == 1 || map[BillsTable.isCash] == true,
      billType: InvoiceType.of(map[BillsTable.billType] as String? ?? 'sales'),
      costGoodId: map[BillsTable.costGoodId] as int?,
      treasuryId: map[BillsTable.treasuryId] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      BillsTable.id: id,
      BillsTable.createdAt: createdAt.toIso8601String(),
      BillsTable.createdBy: createdBy,
      BillsTable.note: note,
      BillsTable.offerAmount: offerAmount,
      BillsTable.currencyId: currencyId,
      BillsTable.billNumber: billNumber,
      BillsTable.warehouseId: warehouseId,
      BillsTable.journalEntryId: journalEntryId,
      BillsTable.personId: personId,
      BillsTable.inventoryTransactionId: inventoryTransactionId,
      BillsTable.isCash: isCash ? 1 : 0,
      BillsTable.billType: billType.name,
      BillsTable.costGoodId: costGoodId,
      BillsTable.treasuryId: treasuryId,
    };
  }

  @override
  BillModel copyWith({
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
    int? costGoodId,
    int? treasuryId,
    List<BillOrderEntity>? orders,
  }) {
    return BillModel(
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
      costGoodId: costGoodId ?? this.costGoodId,
      treasuryId: treasuryId ?? this.treasuryId,
      orders: orders ?? this.orders,
    );
  }
}
