import 'package:flowcash/features/transactions/data/datasources/interfaces/financial_bond_data_source.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_bond_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/financial_bonds_table.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';

final class FinancialBondLocalDataSourceImpl
    implements FinancialBondDataSource {
  final SqliteService _db;
  const FinancialBondLocalDataSourceImpl(this._db);

  @override
  Future<List<FinancialBondEntity>> get({
    Iterable<int>? ids,
    HistoriesGroup? historyGroup,
  }) async {
    bool moreIf = false;
    var query = 'SELECT * FROM ${FinancialBondsTable.tableName}';
    List<Object?>? whereArgs;
    if (historyGroup != null) {
      query += ' WHERE ${FinancialBondsTable.bondType} = ?';
      moreIf = true;
      whereArgs = [historyGroup.name];
    }
    if (ids != null) {
      query += moreIf ? ' AND ' : ' WHERE ';
      query +=
          '${FinancialBondsTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
      whereArgs ??= [];
      whereArgs.addAll(ids);
    }
    final rows = await _db.query(
      table: FinancialBondsTable.tableName,
      where: query,
      whereArgs: whereArgs,
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<FinancialBondEntity?> getById(int id) async {
    final rows = await _db.query(
      table: FinancialBondsTable.tableName,
      where: '${FinancialBondsTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<FinancialBondEntity> insert(FinancialBondEntity entity) async {
    final entityId = await _db.insert(
      table: FinancialBondsTable.tableName,
      data: _sanitizeInsertData(toMap(entity), FinancialBondsTable.id),
    );
    if(entityId < 0) {
      throw Exception('Failed to insert financial bond');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<FinancialBondEntity> update(FinancialBondEntity entity) async {
    await _db.update(
      table: FinancialBondsTable.tableName,
      data: toMap(entity),
      where: {FinancialBondsTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: FinancialBondsTable.tableName,
      where: {FinancialBondsTable.id: id},
    );
    return true;
  }

  @override
  FinancialBondEntity fromMap(Map<String, dynamic> map) {
    return FinancialBondEntity(
      id: map[FinancialBondsTable.id] as int,
      createdAt: DateTime.parse(map[FinancialBondsTable.createdAt]),
      createdBy: map[FinancialBondsTable.createdBy],
      note: map[FinancialBondsTable.note] as String?,
      offerAmount: ((map[FinancialBondsTable.offerAmount]) as num).toDouble(),
      currencyId: map[FinancialBondsTable.currencyId],
      billNumber: map[FinancialBondsTable.billNumber] as int,
      warehouseId: map[FinancialBondsTable.warehouseId] as int,
      journalEntryId: map[FinancialBondsTable.journalEntryId] as int?,
      hintId: map[FinancialBondsTable.hintId] as int,
      historyGroup: HistoriesGroup.values.firstWhere(
        (e) => e.name == map[FinancialBondsTable.bondType] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(FinancialBondEntity entity) {
    return {
      if (entity.id > 0) FinancialBondsTable.id: entity.id,
      FinancialBondsTable.createdAt: entity.createdAt.toIso8601String(),
      FinancialBondsTable.createdBy: entity.createdBy,
      FinancialBondsTable.note: entity.note,
      FinancialBondsTable.offerAmount: entity.offerAmount,
      FinancialBondsTable.currencyId: entity.currencyId,
      FinancialBondsTable.billNumber: entity.billNumber,
      FinancialBondsTable.warehouseId: entity.warehouseId,
      FinancialBondsTable.journalEntryId: entity.journalEntryId,
      FinancialBondsTable.hintId: entity.hintId,
      FinancialBondsTable.bondType: entity.historyGroup.name,
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
