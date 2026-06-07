import 'package:flowcash/features/currencies/data/datasources/exchange_price_data_source.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/exchange_prices_table.dart';

final class ExchangePriceLocalDataSourceImpl
    implements ExchangePriceDataSource {
  final SqliteService _db;
  const ExchangePriceLocalDataSourceImpl(this._db);

  @override
  Future<List<ExchangePriceEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: ExchangePricesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${ExchangePricesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: ExchangePricesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<ExchangePriceEntity?> getById(int id) async {
    final rows = await _db.query(
      table: ExchangePricesTable.tableName,
      where: '${ExchangePricesTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<ExchangePriceEntity> insert(ExchangePriceEntity entity) async {
    final entityId = await _db.insert(
      table: ExchangePricesTable.tableName,
      data: _sanitizeInsertData(toMap(entity), ExchangePricesTable.id),
    );
    if(entityId < 0) {
      throw Exception('Failed to insert exchange price');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<ExchangePriceEntity> update(ExchangePriceEntity entity) async {
    await _db.transaction(() async {
      await _db.update(
        table: ExchangePricesTable.tableName,
        data: toMap(entity),
        where: {ExchangePricesTable.id: entity.id},
      );

      await _db.update(
        table: ExchangePricesTable.tableName,
        data: {
          ExchangePricesTable.exchangePrice: 1 / entity.price,
        },
        where: {
          ExchangePricesTable.fromCurrencyId: entity.toCurrencyId,
          ExchangePricesTable.toCurrencyId: entity.fromCurrencyId,
        },
      );
    });
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: ExchangePricesTable.tableName,
      where: {ExchangePricesTable.id: id},
    );
    return true;
  }

  @override
  ExchangePriceEntity fromMap(Map<String, dynamic> map) {
    return ExchangePriceEntity(
      id: map[ExchangePricesTable.id] as int,
      fromCurrencyId:
          (map[ExchangePricesTable.fromCurrencyId] as String?) ?? '',
      toCurrencyId: (map[ExchangePricesTable.toCurrencyId] as String?) ?? '',
      price: ((map[ExchangePricesTable.exchangePrice]) as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap(ExchangePriceEntity entity) {
    return {
      if (entity.id > 0) ExchangePricesTable.id: entity.id,
      ExchangePricesTable.fromCurrencyId: entity.fromCurrencyId,
      ExchangePricesTable.toCurrencyId: entity.toCurrencyId,
      ExchangePricesTable.exchangePrice: entity.price,
    };
  }

  @override
  Future<double> getExPrice(String fromCurrencyId, String toCurrencyId) async {
    if (fromCurrencyId == toCurrencyId) {
      return 1.0;
    }

    final rows = await _db.query(
      table: ExchangePricesTable.tableName,
      where:
          '${ExchangePricesTable.fromCurrencyId} = ? AND ${ExchangePricesTable.toCurrencyId} = ?',
      whereArgs: [fromCurrencyId, toCurrencyId],
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return (rows.first[ExchangePricesTable.exchangePrice] as num).toDouble();
    }

    final reverseRows = await _db.query(
      table: ExchangePricesTable.tableName,
      where:
          '${ExchangePricesTable.fromCurrencyId} = ? AND ${ExchangePricesTable.toCurrencyId} = ?',
      whereArgs: [toCurrencyId, fromCurrencyId],
      limit: 1,
    );

    if (reverseRows.isNotEmpty) {
      final reversePrice = (reverseRows.first[ExchangePricesTable.exchangePrice] as num).toDouble();
      if (reversePrice == 0) {
        throw Exception('Reverse exchange price is zero for $toCurrencyId -> $fromCurrencyId');
      }
      return 1 / reversePrice;
    }

    throw Exception(
      'Exchange price not found for $fromCurrencyId -> $toCurrencyId',
    );
  }

  @override
  Future<List<ExchangePriceEntity>> getWhereFromCurrencyId(
    Iterable<String> ids,
  ) async {
    if (ids.isEmpty) return [];

    final where =
        '${ExchangePricesTable.fromCurrencyId} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: ExchangePricesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );

    return rows.map(fromMap).toList();
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
