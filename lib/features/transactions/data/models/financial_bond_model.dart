import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_bond_entity.dart';
import 'package:flowcash/core/tables/financial_bonds_table.dart';

final class FinancialBondModel extends FinancialBondEntity {
  const FinancialBondModel({
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

  factory FinancialBondModel.fromMap(Map<String, dynamic> map) {
    return FinancialBondModel(
      id: map[FinancialBondsTable().id] as int,
      createdAt: DateTime.parse(map[FinancialBondsTable().createdAt] as String),
      createdBy: map[FinancialBondsTable().createdBy] as int,
      note: map[FinancialBondsTable().note] as String?,
      offerAmount: (map[FinancialBondsTable().offerAmount] ?? 0.0).toDouble(),
      currencyId: map[FinancialBondsTable().currencyId] as String? ?? '',
      billNumber: map[FinancialBondsTable().billNumber] as int,
      warehouseId: map[FinancialBondsTable().warehouseId] as int,
      journalEntryId: map[FinancialBondsTable().journalEntryId] as int?,
      hintId: map[FinancialBondsTable().hintId] as int,
      historyGroup: HistoriesGroup.of(
        map[FinancialBondsTable().bondType] as String? ?? 'financial_bond',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FinancialBondsTable().id: id,
      FinancialBondsTable().createdAt: createdAt.toIso8601String(),
      FinancialBondsTable().createdBy: createdBy,
      FinancialBondsTable().note: note,
      FinancialBondsTable().offerAmount: offerAmount,
      FinancialBondsTable().currencyId: currencyId,
      FinancialBondsTable().billNumber: billNumber,
      FinancialBondsTable().warehouseId: warehouseId,
      FinancialBondsTable().journalEntryId: journalEntryId,
      FinancialBondsTable().hintId: hintId,
      FinancialBondsTable().bondType: historyGroup.name,
    };
  }

  @override
  FinancialBondModel copyWith({
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
    return FinancialBondModel(
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
