import 'package:flowcash/features/currencies/data/datasources/currency_data_source.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/core/tables/exchange_prices_table.dart';

final class CurrencyLocalDataSourceImpl implements CurrencyDataSource {
  final SqliteService _db;
  const CurrencyLocalDataSourceImpl(this._db);

  @override
  Future<List<CurrencyEntity>> get({Iterable<String>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: CurrenciesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${CurrenciesTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: CurrenciesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<CurrencyEntity?> getById(String id) async {
    final rows = await _db.query(
      table: CurrenciesTable.tableName,
      where: '${CurrenciesTable.id} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<CurrencyEntity> insert(CurrencyEntity entity) async {
    return await _db.transaction(() async {
      final entityId = await _db.insert(
        table: CurrenciesTable.tableName,
        data: _sanitizeInsertData(toMap(entity), CurrenciesTable.id),
      );
      if (entityId < 0) {
        throw Exception('Failed to insert currency');
      }

      final currencyRows = await _db.query(table: CurrenciesTable.tableName);
      final currencyIds = currencyRows
          .map((row) => row[CurrenciesTable.id] as String)
          .toList();

      final exchangePrices = <Map<String, dynamic>>[];
      for (final currencyId in currencyIds) {
        if (currencyId == entity.id) {
          exchangePrices.add({
            ExchangePricesTable.fromCurrencyId: entity.id,
            ExchangePricesTable.toCurrencyId: entity.id,
            ExchangePricesTable.exchangePrice: 1.0,
          });
          continue;
        }

        exchangePrices.add({
          ExchangePricesTable.fromCurrencyId: entity.id,
          ExchangePricesTable.toCurrencyId: currencyId,
          ExchangePricesTable.exchangePrice: 1.0,
        });
        exchangePrices.add({
          ExchangePricesTable.fromCurrencyId: currencyId,
          ExchangePricesTable.toCurrencyId: entity.id,
          ExchangePricesTable.exchangePrice: 1.0,
        });
      }

      await _db.insertAll(
        table: ExchangePricesTable.tableName,
        dataList: exchangePrices,
      );

      return entity;
    });
  }

  @override
  Future<CurrencyEntity> update(CurrencyEntity entity) async {
    await _db.update(
      table: CurrenciesTable.tableName,
      data: toMap(entity),
      where: {CurrenciesTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(String id) async {
    await _db.transaction(() async {
      await _db.deleteWhere(
        table: ExchangePricesTable.tableName,
        where: {ExchangePricesTable.fromCurrencyId: id},
      );

      await _db.deleteWhere(
        table: ExchangePricesTable.tableName,
        where: {ExchangePricesTable.toCurrencyId: id},
      );

      await _db.deleteWhere(
        table: CurrenciesTable.tableName,
        where: {CurrenciesTable.id: id},
      );
    });
    return true;
  }

  @override
  CurrencyEntity fromMap(Map<String, dynamic> map) {
    return CurrencyEntity(
      id: map[CurrenciesTable.id],
      name: (map[CurrenciesTable.currencyName] as String?) ?? "",
      symbol: (map[CurrenciesTable.symbol] as String?) ?? "",
      fullSymbol: (map[CurrenciesTable.fullSymbol] as String?) ?? "",
      country: (map[CurrenciesTable.country] as String?) ?? "",
      selected:
          (map[CurrenciesTable.selected] == true ||
          map[CurrenciesTable.selected] == 1),
    );
  }

  @override
  Map<String, dynamic> toMap(CurrencyEntity entity) {
    return {
      CurrenciesTable.id: entity.id,
      CurrenciesTable.currencyName: entity.name,
      CurrenciesTable.symbol: entity.symbol,
      CurrenciesTable.fullSymbol: entity.fullSymbol,
      CurrenciesTable.country: entity.country,
      CurrenciesTable.selected: entity.selected ? 1 : 0,
    };
  }

  @override
  Future<List<CurrencyEntity>> whereSelected({
    bool trigger = false,
    bool printQuery = true,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<CurrencyEntity>> whereNotSelected({
    bool trigger = false,
    bool printQuery = true,
  }) async {
    throw UnimplementedError();
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
