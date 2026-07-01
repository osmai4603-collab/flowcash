import 'package:flowcash/features/transactions/data/datasources/interfaces/financial_transaction_data_source.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_transaction_entity.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/financial_transactions_table.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';

final class FinancialTransactionLocalDataSourceImpl
    implements FinancialTransactionDataSource {
  final SqliteDatabase _db;
  const FinancialTransactionLocalDataSourceImpl(this._db);

  @override
  Future<List<FinancialTransactionEntity>> get({
    Iterable<int>? ids,
    HistoriesGroup? historyGroup,
  }) async {
    bool moreIf = false;
    var query = 'SELECT * FROM ${FinancialTransactionsTable().tableName}';
    List<Object?>? whereArgs;
    if (historyGroup != null) {
      query += ' WHERE ${FinancialTransactionsTable().transactionType} = ?';
      moreIf = true;
      whereArgs = [historyGroup.name];
    }
    if (ids != null) {
      query += moreIf ? ' AND ' : ' WHERE ';
      query +=
          '${FinancialTransactionsTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
      whereArgs ??= [];
      whereArgs.addAll(ids);
    }
    final rows = await _db.query(
      table: FinancialTransactionsTable().tableName,
      where: query,
      whereArgs: whereArgs,
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<FinancialTransactionEntity?> getById(int id) async {
    final rows = await _db.query(
      table: FinancialTransactionsTable().tableName,
      where: '${FinancialTransactionsTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<FinancialTransactionEntity> insert(
    FinancialTransactionEntity entity,
  ) async {
    final entityId = await _db.insert(
      table: FinancialTransactionsTable().tableName,
      data: _sanitizeInsertData(toMap(entity), FinancialTransactionsTable().id),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert financial transaction');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<FinancialTransactionEntity> update(
    FinancialTransactionEntity entity,
  ) async {
    await _db.update(
      table: FinancialTransactionsTable().tableName,
      data: toMap(entity),
      where: {FinancialTransactionsTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: FinancialTransactionsTable().tableName,
      where: {FinancialTransactionsTable().id: id},
    );
    return true;
  }

  @override
  FinancialTransactionEntity fromMap(Map<String, dynamic> map) {
    return FinancialTransactionEntity(
      id: map[FinancialTransactionsTable().id] as int,
      createdAt: DateTime.parse(map[FinancialTransactionsTable().createdAt]),
      createdBy: map[FinancialTransactionsTable().createdBy],
      note: map[FinancialTransactionsTable().note] as String?,
      offerAmount: ((map[FinancialTransactionsTable().offerAmount]) as num)
          .toDouble(),
      currencyId: map[FinancialTransactionsTable().currencyId],
      billNumber: map[FinancialTransactionsTable().billNumber] as int,
      warehouseId: map[FinancialTransactionsTable().warehouseId] as int,
      journalEntryId: map[FinancialTransactionsTable().journalEntryId] as int?,
      hintId: map[FinancialTransactionsTable().hintId] as int,
      historyGroup: HistoriesGroup.values.firstWhere(
        (e) =>
            e.name == map[FinancialTransactionsTable().transactionType] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(FinancialTransactionEntity entity) {
    return {
      if (entity.id > 0) FinancialTransactionsTable().id: entity.id,
      FinancialTransactionsTable().createdAt: entity.createdAt.toIso8601String(),
      FinancialTransactionsTable().createdBy: entity.createdBy,
      FinancialTransactionsTable().note: entity.note,
      FinancialTransactionsTable().offerAmount: entity.offerAmount,
      FinancialTransactionsTable().currencyId: entity.currencyId,
      FinancialTransactionsTable().billNumber: entity.billNumber,
      FinancialTransactionsTable().warehouseId: entity.warehouseId,
      FinancialTransactionsTable().journalEntryId: entity.journalEntryId,
      FinancialTransactionsTable().hintId: entity.hintId,
      FinancialTransactionsTable().transactionType: entity.historyGroup.name,
    };
  }

  Map<String, dynamic> _sanitizeInsertData(
    Map<String, dynamic> data,
    String idKey,
  ) {
    if (data[idKey] is int && (data[idKey] as int) <= 0) {
      final sanitized = Map<String, dynamic>.from(data);
      sanitized.remove(idKey);
      return sanitized;
    }
    return data;
  }
}
