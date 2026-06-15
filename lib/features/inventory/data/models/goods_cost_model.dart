import 'package:flowcash/core/tables/goods_costs_table.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/features/inventory/domain/entities/goods_cost_entity.dart';

final class GoodsCostModel extends GoodsCostEntity {
  const GoodsCostModel({
    required super.id,
    required super.createdAt,
    required super.createdBy,
    super.note,
    required super.offerAmount,
    required super.currencyId,
    required super.billNumber,
    required super.warehouseId,
    super.journalEntryId,
    required super.hintId,
    super.orderId,
    required super.historyGroup,
  });

  factory GoodsCostModel.fromMap(Map<String, dynamic> map) {
    return GoodsCostModel(
      id: map[GoodsCostsTable.id] as int,
      createdAt: DateTime.parse(map[GoodsCostsTable.createdAt] as String? ?? ""),
      createdBy: map[GoodsCostsTable.createdBy] as int,
      note: map[GoodsCostsTable.note] as String?,
      offerAmount: ((map[GoodsCostsTable.offerAmount]) as num).toDouble(),
      currencyId: (map[GoodsCostsTable.currencyId] ?? '').toString(),
      billNumber: map[GoodsCostsTable.billNumber] as int,
      warehouseId: map[GoodsCostsTable.warehouseId] as int,
      journalEntryId: map[GoodsCostsTable.journalEntryId] as int?,
      hintId: map[GoodsCostsTable.hintId] as int,
      orderId: map[GoodsCostsTable.orderId] as int?,
      historyGroup: HistoriesGroup.values.firstWhere(
        (e) => e.name == map[GoodsCostsTable.historyGroup] as String,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) GoodsCostsTable.id: id,
      GoodsCostsTable.createdAt: createdAt.toIso8601String(),
      GoodsCostsTable.createdBy: createdBy,
      GoodsCostsTable.note: note,
      GoodsCostsTable.offerAmount: offerAmount,
      GoodsCostsTable.currencyId: currencyId,
      GoodsCostsTable.billNumber: billNumber,
      GoodsCostsTable.warehouseId: warehouseId,
      GoodsCostsTable.journalEntryId: journalEntryId,
      GoodsCostsTable.hintId: hintId,
      GoodsCostsTable.orderId: orderId,
      GoodsCostsTable.historyGroup: historyGroup.name,
    };
  }

  @override
  GoodsCostModel copyWith({
    int? id,
    DateTime? createdAt,
    int? createdBy,
    String? note,
    double? offerAmount,
    String? currencyId,
    int? billNumber,
    int? warehouseId,
    int? journalEntryId,
    int? hintId,
    int? orderId,
    HistoriesGroup? historyGroup,
  }) {
    return GoodsCostModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      note: note ?? this.note,
      offerAmount: offerAmount ?? this.offerAmount,
      currencyId: currencyId ?? this.currencyId,
      billNumber: billNumber ?? this.billNumber,
      warehouseId: warehouseId ?? this.warehouseId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      hintId: hintId ?? this.hintId,
      orderId: orderId ?? this.orderId,
      historyGroup: historyGroup ?? this.historyGroup,
    );
  }
}
