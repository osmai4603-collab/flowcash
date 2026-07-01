import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/features/system/domain/entities/asset_transaction_entity.dart';
import 'package:flowcash/core/tables/assets_transactions_table.dart';
import 'package:flowcash/core/models/model.dart';

final class AssetTransactionModel extends AssetTransactionEntity implements Model {
  const AssetTransactionModel({
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

  factory AssetTransactionModel.fromMap(Map<String, dynamic> map) {
    return AssetTransactionModel(
      id: map[AssetsTransactionsTable().id] as int,
      createdAt: DateTime.parse(
        map[AssetsTransactionsTable().createdAt] as String,
      ),
      createdBy: map[AssetsTransactionsTable().createdBy] as int,
      note: map[AssetsTransactionsTable().note] as String?,
      offerAmount: (map[AssetsTransactionsTable().offerAmount] ?? 0.0).toDouble(),
      currencyId: map[AssetsTransactionsTable().currencyId] as String? ?? '',
      billNumber: map[AssetsTransactionsTable().billNumber] as int,
      warehouseId: map[AssetsTransactionsTable().warehouseId] as int,
      journalEntryId: map[AssetsTransactionsTable().journalEntryId] as int?,
      hintId: map[AssetsTransactionsTable().hintId] as int,
      historyGroup: HistoriesGroup.of(
        map[AssetsTransactionsTable().historyGroup] as String? ?? 'asset',
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      AssetsTransactionsTable().id: id,
      AssetsTransactionsTable().createdAt: createdAt.toIso8601String(),
      AssetsTransactionsTable().createdBy: createdBy,
      AssetsTransactionsTable().note: note,
      AssetsTransactionsTable().offerAmount: offerAmount,
      AssetsTransactionsTable().currencyId: currencyId,
      AssetsTransactionsTable().billNumber: billNumber,
      AssetsTransactionsTable().warehouseId: warehouseId,
      AssetsTransactionsTable().journalEntryId: journalEntryId,
      AssetsTransactionsTable().hintId: hintId,
      AssetsTransactionsTable().historyGroup: historyGroup.name,
    };
  }

  @override
  AssetTransactionModel copyWith({
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
    return AssetTransactionModel(
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
