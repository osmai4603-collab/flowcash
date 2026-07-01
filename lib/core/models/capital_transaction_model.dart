import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/core/entities/capital_transaction_entity.dart';
import 'package:flowcash/core/models/model.dart';

// TODO: Replace with the actual table class (e.g. CapitalTransactionsTable) when it exists.
final class CapitalTransactionModel extends CapitalTransactionEntity implements Model {
  const CapitalTransactionModel({
    required super.id,
    required super.createdAt,
    required super.createdBy,
    super.note,
    required super.offerAmount,
    required super.currencyId,
    required super.billNumber,
    required super.periodId,
    required super.warehouseId,
    super.journalEntryId,
    required super.hintId,
    required super.historyGroup,
  });

  factory CapitalTransactionModel.fromMap(Map<String, dynamic> map) {
    return CapitalTransactionModel(
      id: map['id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      createdBy: map['created_by'] as int,
      note: map['note'] as String?,
      offerAmount: (map['offer_amount'] ?? 0.0).toDouble(),
      currencyId: map['currency_id'] as String? ?? '',
      billNumber: map['bill_number'] as int,
      periodId: map['period_id'] as int,
      warehouseId: map['warehouse_id'] as int,
      journalEntryId: map['journal_entry_id'] as int?,
      hintId: map['hint_id'] as int,
      historyGroup: HistoriesGroup.of(
        map['history_group'] as String? ?? 'capital',
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'note': note,
      'offer_amount': offerAmount,
      'currency_id': currencyId,
      'bill_number': billNumber,
      'period_id': periodId,
      'warehouse_id': warehouseId,
      'journal_entry_id': journalEntryId,
      'hint_id': hintId,
      'history_group': historyGroup.name,
    };
  }

  @override
  CapitalTransactionModel copyWith({
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
    return CapitalTransactionModel(
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
