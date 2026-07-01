import 'package:flowcash/core/datasources/interfaces/value_counter_data_source.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';
import 'package:flowcash/core/enums/counter_type_enum.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/values_counter_table.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flowcash/core/errors/failure.dart';

final class ValueCounterLocalDataSourceImpl implements ValueCounterDataSource {
  final SqliteDatabase _db;
  const ValueCounterLocalDataSourceImpl(this._db);

  @override
  Future<List<ValueCounterEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: ValuesCounterTable().tableName);
      return rows.map(fromMap).toList();
    }

    final placeholders = List.filled(ids.length, '?').join(', ');
    final where = '${ValuesCounterTable().id} IN ($placeholders)';
    final rows = await _db.query(
      table: ValuesCounterTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<ValueCounterEntity?> getById(int id) async {
    final rows = await _db.query(
      table: ValuesCounterTable().tableName,
      where: '${ValuesCounterTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<ValueCounterEntity> getCounter(CounterType counterType) async {
    final rows = await _db.query(
      table: ValuesCounterTable().tableName,
      where: '${ValuesCounterTable().counterType} = ?',
      whereArgs: [counterType.name],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw DatabaseFailure(
        'Value counter not found for type: ${counterType.name}',
      );
    }
    return fromMap(rows.first);
  }

  @override
  Future<int> getNewCounter(
    CounterType counterType, {
    bool shouldUpdate = true,
  }) async {
    final counterEntity = await getCounter(counterType);
    final currentCounter = counterEntity.count;
    var nextCounter = currentCounter;

    if (nextCounter % counterEntity.counterMax == 0) {
      nextCounter = 0;
    }
    nextCounter += counterEntity.incrementValue;

    if (shouldUpdate) {
      await updateCounter(counter: nextCounter, id: counterEntity.id);
    }

    return currentCounter;
  }

  @override
  Future<int> getNewCounterOfWithdraws({bool shouldUpdate = true}) async {
    return getNewCounter(CounterType.withdraws, shouldUpdate: shouldUpdate);
  }

  @override
  Future<int> getNewCounterOfBuysBills({bool shouldUpdate = true}) async {
    return getNewCounter(CounterType.buysBills, shouldUpdate: shouldUpdate);
  }

  @override
  Future<int> getNewCounterOfSalesBills({bool shouldUpdate = true}) async {
    return getNewCounter(CounterType.salesBills, shouldUpdate: shouldUpdate);
  }

  @override
  Future<int> getNewCounterOfOpeningEntries({bool shouldUpdate = true}) async {
    return getNewCounter(
      CounterType.openingEntries,
      shouldUpdate: shouldUpdate,
    );
  }

  @override
  Future<int> getNewCounterOfClosingEntries({bool shouldUpdate = true}) async {
    return getNewCounter(
      CounterType.closingEntries,
      shouldUpdate: shouldUpdate,
    );
  }

  @override
  Future<int> getNewCounterOfPaids({bool shouldUpdate = true}) async {
    return getNewCounter(CounterType.paids, shouldUpdate: shouldUpdate);
  }

  @override
  Future<int> getNewCounterOfProceeds({bool shouldUpdate = true}) async {
    return getNewCounter(CounterType.proceeds, shouldUpdate: shouldUpdate);
  }

  @override
  Future<bool> updateCounter({required int counter, required int id}) async {
    await _db.update(
      table: ValuesCounterTable().tableName,
      data: {ValuesCounterTable().count: counter},
      where: {ValuesCounterTable().id: id},
    );
    return true;
  }

  @override
  Future<List<int>> getNewCountersOfExpenses({required int length}) async {
    final counterEntity = await getCounter(CounterType.expenses);
    final counters = <int>[];
    var currentCounter = counterEntity.count;

    for (var i = 0; i < length; i++) {
      var nextCounter = currentCounter;
      if (nextCounter % counterEntity.counterMax == 0) {
        nextCounter = 0;
      }
      nextCounter += counterEntity.incrementValue;
      counters.add(currentCounter);
      currentCounter = nextCounter;
    }

    await updateCounter(counter: currentCounter, id: counterEntity.id);
    return counters;
  }

  @override
  Future<List<int>> getNewCountersOfRevenues({required int length}) async {
    final counterEntity = await getCounter(CounterType.revenues);
    final counters = <int>[];
    var currentCounter = counterEntity.count;

    for (var i = 0; i < length; i++) {
      var nextCounter = currentCounter;
      if (nextCounter % counterEntity.counterMax == 0) {
        nextCounter = 0;
      }
      nextCounter += counterEntity.incrementValue;
      counters.add(currentCounter);
      currentCounter = nextCounter;
    }

    await updateCounter(counter: currentCounter, id: counterEntity.id);
    return counters;
  }

  @override
  Future<int> getNewCounterOfExpenses({bool shouldUpdate = true}) async {
    return getNewCounter(CounterType.expenses, shouldUpdate: shouldUpdate);
  }

  @override
  Future<int> getNewCounterOfRevenues({bool shouldUpdate = true}) async {
    return getNewCounter(CounterType.revenues, shouldUpdate: shouldUpdate);
  }

  @override
  Future<int> getNextCounter(int valueGroupId) async {
    final entity = await getById(valueGroupId);
    if (entity == null) {
      throw DatabaseFailure('Value counter group not found: $valueGroupId');
    }

    final currentCounter = entity.count;
    var nextCounter = currentCounter;
    if (nextCounter % entity.counterMax == 0) {
      nextCounter = 0;
    }
    nextCounter += entity.incrementValue;

    await updateCounter(counter: nextCounter, id: entity.id);
    return currentCounter;
  }

  @override
  Future<ValueCounterEntity> insert(ValueCounterEntity entity) async {
    final entityId = await _db.insert(
      table: ValuesCounterTable().tableName,
      data: _sanitizeInsertData(toMap(entity), ValuesCounterTable().id),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert value counter');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<ValueCounterEntity> update(ValueCounterEntity entity) async {
    final data = toMap(entity);
    await _db.update(
      table: ValuesCounterTable().tableName,
      data: data,
      where: {ValuesCounterTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: ValuesCounterTable().tableName,
      where: {ValuesCounterTable().id: id},
    );
    return true;
  }

  @override
  ValueCounterEntity fromMap(Map<String, dynamic> map) {
    return ValueCounterEntity(
      id: map[ValuesCounterTable().id] as int,
      counterType: ValueCounterType.values.firstWhere(
        (e) => e.name == map[ValuesCounterTable().counterType] as String,
      ),
      count: map[ValuesCounterTable().count] as int,
      counterMax: map[ValuesCounterTable().counterMax] as int,
      incrementValue: map[ValuesCounterTable().incrementValue] as int,
      formatValue: (map[ValuesCounterTable().formatValue] as String?) ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap(ValueCounterEntity entity) {
    return {
      if (entity.id > 0) ValuesCounterTable().id: entity.id,
      ValuesCounterTable().counterType: entity.counterType.name,
      ValuesCounterTable().count: entity.count,
      ValuesCounterTable().counterMax: entity.counterMax,
      ValuesCounterTable().incrementValue: entity.incrementValue,
      ValuesCounterTable().formatValue: entity.formatValue,
    };
  }

  @override
  Future<int> getNextCounterByGroup(HistoriesGroup historyGroup) async {
    final rows = await _db.query(
      table: ValuesCounterTable().tableName,
      where: '${ValuesCounterTable().counterType} = ?',
      whereArgs: [historyGroup.name],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw DatabaseFailure(
        'Value counter not found for history group: ${historyGroup.name}',
      );
    }
    final entity = fromMap(rows.first);
    final currentCounter = entity.count;
    var nextCounter = currentCounter;
    if (nextCounter % entity.counterMax == 0) {
      nextCounter = 0;
    }
    nextCounter += entity.incrementValue;

    await updateCounter(counter: nextCounter, id: entity.id);
    return currentCounter;
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
