import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/values_counter_table.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';
import '../../models/value_counter_model.dart';
import '../interfaces/value_counter_data_source.dart';

class ValueCounterLocalDataSourceImpl implements ValueCounterDataSource {
  final SqliteDatabase _db;

  const ValueCounterLocalDataSourceImpl(this._db);

  @override
  Future<ValueCounterModel> getCounter(ValueCounterType type) async {
    var counter = await _db.fetchFirstModel(
      tableName: ValuesCounterTable().tableName,
      where: '${ValuesCounterTable().counterType} = ?',
      whereArgs: [type.name],
      toModel: ValueCounterModel.fromMap
    );
    if(counter == null) {
      final initialCount = type == ValueCounterType.categoryNumber ? 1001 : 1;
      final increment = 1;
      final formatValue = '0000';
      final newCounter = ValueCounterModel(
        id: 0,
        counterType: type,
        count: initialCount,
        counterMax: 99999,
        incrementValue: increment,
        formatValue: formatValue,
      );
      return await setCounter(newCounter);
    }
    return counter;
  }

  @override
  Future<int> incrementCounter(ValueCounterType type) async {
    final counter = await getCounter(type);
    
    final currentCount = counter.count;
    final increment = counter.incrementValue;
    final maxValue = counter.counterMax;
    final initialCount = type == ValueCounterType.categoryNumber ? 1001 : 1;
    var nextCount = currentCount + increment;
    if (nextCount > maxValue) {
      nextCount = initialCount;
    }

    

    await _db.update(
      table: ValuesCounterTable().tableName,
      data: {ValuesCounterTable().count: nextCount},
      where: {ValuesCounterTable().id: counter.id},
    );
    return currentCount;
  }

  @override
  Future<ValueCounterModel> setCounter(ValueCounterModel counter) async {
    final rows = await _db.query(
      table: ValuesCounterTable().tableName,
      where: '${ValuesCounterTable().counterType} = ?',
      whereArgs: [counter.counterType.name],
      limit: 1,
    );

    if (rows.isEmpty) {
      await _db.insert(
        table: ValuesCounterTable().tableName,
        data: counter.toMap(),
      );
      final insertedRows = await _db.query(
        table: ValuesCounterTable().tableName,
        where: '${ValuesCounterTable().counterType} = ?',
        whereArgs: [counter.counterType.name],
        limit: 1,
      );
      return ValueCounterModel.fromMap(insertedRows.first);
    }

    final row = rows.first;
    await _db.update(
      table: ValuesCounterTable().tableName,
      data: counter.toMap(),
      where: {ValuesCounterTable().id: row[ValuesCounterTable().id]},
    );

    final updatedRows = await _db.query(
      table: ValuesCounterTable().tableName,
      where: '${ValuesCounterTable().counterType} = ?',
      whereArgs: [counter.counterType.name],
      limit: 1,
    );
    return ValueCounterModel.fromMap(updatedRows.first);
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
        (element) => element.name == map[ValuesCounterTable().counterType],
      ),
      count: map[ValuesCounterTable().count] as int,
      counterMax: map[ValuesCounterTable().counterMax] as int,
      incrementValue: map[ValuesCounterTable().incrementValue] as int,
      formatValue: map[ValuesCounterTable().formatValue] as String,
    );
  }

  @override
  Future<List<ValueCounterEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: ValuesCounterTable().tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${ValuesCounterTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: ValuesCounterTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<ValueCounterEntity?> getById(int id) async {
    return await _db.getByIdToModel(
      table: ValuesCounterTable(),
      id: id,
      toModel: ValueCounterModel.fromMap,
    );
  }

  @override
  Future<ValueCounterEntity> getValueCounterByCounterType(ValueCounterType counterType) async {
    final rows = await _db.query(
      table: ValuesCounterTable().tableName,
      where: '${ValuesCounterTable().counterType} = ?',
      whereArgs: [counterType.name],
      limit: 1,
    );
    if (rows.isEmpty) {
      final initialCount = counterType == ValueCounterType.categoryNumber ? 1001 : 1;
      return await insert(ValueCounterEntity(
        id: 0,
        counterType: counterType,
        count: initialCount,
      ));
    }
    return fromMap(rows.first);
  }

  @override
  Future<ValueCounterEntity> insert(ValueCounterEntity entity) async {
    final entityId = await _db.insert(
      table: ValuesCounterTable().tableName,
      data: toMap(entity),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert Value Counter');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Map<String, dynamic> toMap(ValueCounterEntity entity) {
    return {
      if(entity.id > 0) ValuesCounterTable().id: entity.id,
      ValuesCounterTable().counterType: entity.counterType.name,
      ValuesCounterTable().count: entity.count,
      ValuesCounterTable().counterMax: entity.counterMax,
      ValuesCounterTable().incrementValue: entity.incrementValue,
      ValuesCounterTable().formatValue: entity.formatValue,
    };
  }

  @override
  Future<ValueCounterEntity> update(ValueCounterEntity entity) async {
    await _db.update(
      table: ValuesCounterTable().tableName,
      data: toMap(entity),
      where: {ValuesCounterTable().id: entity.id},
    );
    return entity;
  }
}
