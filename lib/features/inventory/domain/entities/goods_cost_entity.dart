import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';

class GoodsCostEntity extends Entity {
  final int id;
  final DateTime createdAt;
  final int createdBy;
  final String? note;
  final double offerAmount;
  final String currencyId;
  final int billNumber;
  final int warehouseId;
  final int? journalEntryId;
  final int hintId;
  final int? orderId;
  final HistoriesGroup historyGroup;

  const GoodsCostEntity({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    this.note,
    required this.offerAmount,
    required this.currencyId,
    required this.billNumber,
    required this.warehouseId,
    this.journalEntryId,
    required this.hintId,
    this.orderId,
    required this.historyGroup,
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
    hintId,
    orderId,
    historyGroup,
  ];

  @override
  GoodsCostEntity copyWith({
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
    return GoodsCostEntity(
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
