import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/values_counter_table.dart';
import '../../models/value_counter_model.dart';
import '../interfaces/value_counter_data_source.dart';

class ValueCounterLocalDataSourceImpl implements ValueCounterDataSource {
  final SqliteService _db;

  const ValueCounterLocalDataSourceImpl(this._db);

  @override
  Future<ValueCounterModel> getCounter(ValueCounterType type) async {
    final rows = await _db.query(
      table: ValuesCounterTable.tableName,
      where: '${ValuesCounterTable.counterType} = ?',
      whereArgs: [type.name],
    );
    if (rows.isEmpty) {
      final initialCount = type == ValueCounterType.categoryNumber ? 1001 : 1;
      final increment = 1;
      final formatValue = '0000';
      await _db.insert(
        table: ValuesCounterTable.tableName,
        data: {
          ValuesCounterTable.counterType: type.name,
          ValuesCounterTable.count: initialCount,
          ValuesCounterTable.counterMax: 99999,
          ValuesCounterTable.incrementValue: increment,
          ValuesCounterTable.formatValue: formatValue,
        },
      );
      final insertedRows = await _db.query(
        table: ValuesCounterTable.tableName,
        where: '${ValuesCounterTable.counterType} = ?',
        whereArgs: [type.name],
        limit: 1,
      );
      return ValueCounterModel.fromMap(insertedRows.first);
    }
    return ValueCounterModel.fromMap(rows.first);
  }

  @override
  Future<int> incrementCounter(ValueCounterType type) async {
    final rows = await _db.query(
      table: ValuesCounterTable.tableName,
      where: '${ValuesCounterTable.counterType} = ?',
      whereArgs: [type.name],
    );

    if (rows.isEmpty) {
      final initialCount = type == ValueCounterType.categoryNumber ? 1001 : 1;
      final increment = 1;
      final formatValue = '0000';
      await _db.insert(
        table: ValuesCounterTable.tableName,
        data: {
          ValuesCounterTable.counterType: type.name,
          ValuesCounterTable.count: initialCount,
          ValuesCounterTable.counterMax: 99999,
          ValuesCounterTable.incrementValue: increment,
          ValuesCounterTable.formatValue: formatValue,
        },
      );
      return initialCount;
    }

    final row = rows.first;
    final currentCount = row[ValuesCounterTable.count] as int? ?? 0;
    final increment = row[ValuesCounterTable.incrementValue] as int? ?? 1;
    final maxValue = row[ValuesCounterTable.counterMax] as int? ?? 99999;
    final initialCount = type == ValueCounterType.categoryNumber ? 1001 : 1;
    var nextCount = currentCount + increment;
    if (nextCount > maxValue) {
      nextCount = initialCount;
    }

    await _db.update(
      table: ValuesCounterTable.tableName,
      data: {ValuesCounterTable.count: nextCount},
      where: {ValuesCounterTable.id: row[ValuesCounterTable.id]},
    );
    return currentCount;
  }

  @override
  Future<ValueCounterModel> setCounter(ValueCounterModel counter) async {
    final rows = await _db.query(
      table: ValuesCounterTable.tableName,
      where: '${ValuesCounterTable.counterType} = ?',
      whereArgs: [counter.counterType.name],
    );

    if (rows.isEmpty) {
      await _db.insert(
        table: ValuesCounterTable.tableName,
        data: counter.toMap(),
      );
      final insertedRows = await _db.query(
        table: ValuesCounterTable.tableName,
        where: '${ValuesCounterTable.counterType} = ?',
        whereArgs: [counter.counterType.name],
        limit: 1,
      );
      return ValueCounterModel.fromMap(insertedRows.first);
    }

    final row = rows.first;
    await _db.update(
      table: ValuesCounterTable.tableName,
      data: counter.toMap(),
      where: {ValuesCounterTable.id: row[ValuesCounterTable.id]},
    );

    final updatedRows = await _db.query(
      table: ValuesCounterTable.tableName,
      where: '${ValuesCounterTable.counterType} = ?',
      whereArgs: [counter.counterType.name],
      limit: 1,
    );
    return ValueCounterModel.fromMap(updatedRows.first);
  }
}
