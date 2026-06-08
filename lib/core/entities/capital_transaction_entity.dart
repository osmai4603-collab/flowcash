import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';

class CapitalTransactionEntity extends Entity {
  final int id;
  final DateTime createdAt;
  final int createdBy;
  final String? note;
  final double offerAmount;
  final String currencyId;
  final int billNumber;
  final int periodId;
  final int warehouseId;
  final int? journalEntryId;
  final int hintId;
  final HistoriesGroup historyGroup;

  const CapitalTransactionEntity({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    this.note,
    required this.offerAmount,
    required this.currencyId,
    required this.billNumber,
    required this.periodId,
    required this.warehouseId,
    this.journalEntryId,
    required this.hintId,
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
    periodId,
    warehouseId,
    journalEntryId,
    hintId,
    historyGroup,
  ];

  @override
  CapitalTransactionEntity copyWith({
    int? id,
    DateTime? createdAt,
    int? createdBy,
    String? note,
    double? offerAmount,
    String? currencyId,
    int? billNumber,
    int? periodId,
    int? warehouseId,
    int? journalEntryId,
    int? hintId,
    HistoriesGroup? historyGroup,
  }) {
    return CapitalTransactionEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      note: note ?? this.note,
      offerAmount: offerAmount ?? this.offerAmount,
      currencyId: currencyId ?? this.currencyId,
      billNumber: billNumber ?? this.billNumber,
      periodId: periodId ?? this.periodId,
      warehouseId: warehouseId ?? this.warehouseId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      hintId: hintId ?? this.hintId,
      historyGroup: historyGroup ?? this.historyGroup,
    );
  }
}
