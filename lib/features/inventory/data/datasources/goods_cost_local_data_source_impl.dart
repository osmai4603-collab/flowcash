import 'package:flowcash/features/inventory/data/datasources/goods_cost_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/goods_cost_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/goods_costs_table.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';

final class GoodsCostLocalDataSourceImpl implements GoodsCostDataSource {
  final SqliteService _db;
  const GoodsCostLocalDataSourceImpl(this._db);

  @override
  Future<List<GoodsCostEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: GoodsCostsTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${GoodsCostsTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: GoodsCostsTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<GoodsCostEntity?> getById(int id) async {
    final rows = await _db.query(
      table: GoodsCostsTable.tableName,
      where: '${GoodsCostsTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<GoodsCostEntity> insert(GoodsCostEntity entity) async {
    final entityId = await _db.insert(
      table: GoodsCostsTable.tableName,
      data: _sanitizeInsertData(toMap(entity), GoodsCostsTable.id),
    );
    if(entityId < 0) {
      throw Exception('Failed to insert goods cost');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<GoodsCostEntity> update(GoodsCostEntity entity) async {
    await _db.update(
      table: GoodsCostsTable.tableName,
      data: toMap(entity),
      where: {GoodsCostsTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: GoodsCostsTable.tableName,
      where: {GoodsCostsTable.id: id},
    );
    return true;
  }

  @override
  GoodsCostEntity fromMap(Map<String, dynamic> map) {
    return GoodsCostEntity(
      id: map[GoodsCostsTable.id] as int,
      createdAt: DateTime.parse(map[GoodsCostsTable.createdAt] as String? ?? ""),
      createdBy: map[GoodsCostsTable.createdBy],
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

  @override
  Map<String, dynamic> toMap(GoodsCostEntity entity) {
    return {
      if (entity.id > 0) GoodsCostsTable.id: entity.id,
      GoodsCostsTable.createdAt: entity.createdAt.toIso8601String(),
      GoodsCostsTable.createdBy: entity.createdBy,
      GoodsCostsTable.note: entity.note,
      GoodsCostsTable.offerAmount: entity.offerAmount,
      GoodsCostsTable.currencyId: entity.currencyId,
      GoodsCostsTable.billNumber: entity.billNumber,
      GoodsCostsTable.warehouseId: entity.warehouseId,
      GoodsCostsTable.journalEntryId: entity.journalEntryId,
      GoodsCostsTable.hintId: entity.hintId,
      GoodsCostsTable.orderId: entity.orderId,
      GoodsCostsTable.historyGroup: entity.historyGroup.name,
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
