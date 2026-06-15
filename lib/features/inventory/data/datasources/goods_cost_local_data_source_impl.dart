import 'package:flowcash/features/inventory/data/datasources/goods_cost_data_source.dart';
import 'package:flowcash/features/inventory/domain/entities/goods_cost_entity.dart';
import 'package:flowcash/features/inventory/data/models/goods_cost_model.dart';
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
    if (entityId < 0) {
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
    return GoodsCostModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(GoodsCostEntity entity) {
    if (entity is GoodsCostModel) {
      return entity.toMap();
    }
    return GoodsCostModel(
      id: entity.id,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
      note: entity.note,
      offerAmount: entity.offerAmount,
      currencyId: entity.currencyId,
      billNumber: entity.billNumber,
      warehouseId: entity.warehouseId,
      journalEntryId: entity.journalEntryId,
      hintId: entity.hintId,
      orderId: entity.orderId,
      historyGroup: entity.historyGroup,
    ).toMap();
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
