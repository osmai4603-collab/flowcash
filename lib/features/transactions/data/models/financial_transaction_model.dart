import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_transaction_entity.dart';
import 'package:flowcash/core/tables/financial_transactions_table.dart';
import 'package:flowcash/core/models/model.dart';

final class FinancialTransactionModel extends FinancialTransactionEntity implements Model {
  const FinancialTransactionModel({
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
    required super.historyGroup,
  });

  factory FinancialTransactionModel.fromMap(Map<String, dynamic> map) {
    return FinancialTransactionModel(
      id: map[FinancialTransactionsTable().id] as int,
      createdAt: DateTime.parse(
        map[FinancialTransactionsTable().createdAt] as String,
      ),
      createdBy: map[FinancialTransactionsTable().createdBy] as int,
      note: map[FinancialTransactionsTable().note] as String?,
      offerAmount: (map[FinancialTransactionsTable().offerAmount] ?? 0.0)
          .toDouble(),
      currencyId: map[FinancialTransactionsTable().currencyId] as String? ?? '',
      billNumber: map[FinancialTransactionsTable().billNumber] as int,
      warehouseId: map[FinancialTransactionsTable().warehouseId] as int,
      journalEntryId: map[FinancialTransactionsTable().journalEntryId] as int?,
      hintId: map[FinancialTransactionsTable().hintId] as int,
      historyGroup: HistoriesGroup.of(
        map[FinancialTransactionsTable().transactionType] as String? ??
            'financial_transaction',
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      FinancialTransactionsTable().id: id,
      FinancialTransactionsTable().createdAt: createdAt.toIso8601String(),
      FinancialTransactionsTable().createdBy: createdBy,
      FinancialTransactionsTable().note: note,
      FinancialTransactionsTable().offerAmount: offerAmount,
      FinancialTransactionsTable().currencyId: currencyId,
      FinancialTransactionsTable().billNumber: billNumber,
      FinancialTransactionsTable().warehouseId: warehouseId,
      FinancialTransactionsTable().journalEntryId: journalEntryId,
      FinancialTransactionsTable().hintId: hintId,
      FinancialTransactionsTable().transactionType: historyGroup.name,
    };
  }

  @override
  FinancialTransactionModel copyWith({
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
    HistoriesGroup? historyGroup,
  }) {
    return FinancialTransactionModel(
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
      historyGroup: historyGroup ?? this.historyGroup,
    );
  }
}
