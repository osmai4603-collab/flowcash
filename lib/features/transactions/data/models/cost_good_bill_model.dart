import 'package:flowcash/core/tables/cost_good_bills_table.dart';
import 'package:flowcash/features/transactions/data/models/cost_good_bill_order_model.dart';
import 'package:flowcash/features/transactions/domain/entities/cost_good_bill_entity.dart';

import '../../domain/entities/cost_good_bill_order_entity.dart';

final class CostGoodBillModel extends CostGoodBillEntity {
  const CostGoodBillModel({
    required super.id,
    required super.createdAt,
    required super.createdBy,
    super.note,
    required super.offerAmount,
    required super.currencyId,
    required super.billNumber,
    required super.warehouseId,
    super.journalEntryId,
    required super.personId,
    required super.billId,
    super.orders = const [],
  });

  factory CostGoodBillModel.fromMap(Map<String, dynamic> map, {List<CostGoodBillOrderModel> orders = const []}) {
    return CostGoodBillModel(
      id: map[CostGoodBillsTable().id] as int,
      createdAt: DateTime.parse(map[CostGoodBillsTable().createdAt] as String),
      createdBy: map[CostGoodBillsTable().createdBy] as int,
      note: map[CostGoodBillsTable().note] as String?,
      offerAmount: (map[CostGoodBillsTable().offerAmount] as num).toDouble(),
      currencyId: map[CostGoodBillsTable().currencyId] as String,
      billNumber: map[CostGoodBillsTable().billNumber] as int,
      warehouseId: map[CostGoodBillsTable().warehouseId] as int,
      journalEntryId: map[CostGoodBillsTable().journalEntryId] as int?,
      personId: map[CostGoodBillsTable().personId] as int,
      billId: map[CostGoodBillsTable().billId] as int,
      orders: orders,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) CostGoodBillsTable().id: id,
      CostGoodBillsTable().createdAt: createdAt.toIso8601String(),
      CostGoodBillsTable().createdBy: createdBy,
      CostGoodBillsTable().note: note,
      CostGoodBillsTable().offerAmount: offerAmount,
      CostGoodBillsTable().currencyId: currencyId,
      CostGoodBillsTable().billNumber: billNumber,
      CostGoodBillsTable().warehouseId: warehouseId,
      CostGoodBillsTable().journalEntryId: journalEntryId,
      CostGoodBillsTable().personId: personId,
      CostGoodBillsTable().billId: billId,
    };
  }

  @override
  CostGoodBillModel copyWith({
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
    return CostGoodBillModel(
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
