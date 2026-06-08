import 'package:flowcash/core/datasources/interfaces/value_data_source.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/values_table.dart';
import 'dart:typed_data';

final class ValueLocalDataSourceImpl implements ValueDataSource {
  final SqliteService _db;
  const ValueLocalDataSourceImpl(this._db);

  @override
  Future<List<ValueEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: ValuesTable.tableName);
      return rows.map(fromMap).toList();
    }
    final placeholders = List.filled(ids.length, '?').join(', ');
    final where = '${ValuesTable.id} IN ($placeholders)';
    final rows = await _db.query(
      table: ValuesTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<ValueEntity?> getById(int id) async {
    final rows = await _db.query(
      table: ValuesTable.tableName,
      where: '${ValuesTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<ValueEntity> insert(ValueEntity entity) async {
    final entityId = await _db.insert(
      table: ValuesTable.tableName,
      data: _sanitizeInsertData(toMap(entity), ValuesTable.id),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert value');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<ValueEntity> update(ValueEntity entity) async {
    final data = toMap(entity);
    await _db.update(
      table: ValuesTable.tableName,
      data: data,
      where: {ValuesTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: ValuesTable.tableName,
      where: {ValuesTable.id: id},
    );
    return true;
  }

  @override
  ValueEntity fromMap(Map<String, dynamic> map) {
    return ValueEntity(
      id: map[ValuesTable.id] as int,
      value: map[ValuesTable.value],
      valueType: ValueType.values.firstWhere(
        (e) => e.name == map[ValuesTable.valueType] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(ValueEntity entity) {
    return {
      if (entity.id > 0) ValuesTable.id: entity.id,
      ValuesTable.value: entity.value,
      ValuesTable.valueType: entity.valueType.name,
    };
  }

  @override
  Future<ValueEntity?> firstValue(ValueType valueType) async {
    throw UnimplementedError();
  }

  @override
  Future<ValueEntity> getValue(ValueType valueType) async {
    throw UnimplementedError();
  }

  @override
  Future<int> fetchLocalCurrency() async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchFirstDate() async {
    throw UnimplementedError();
  }

  @override
  Future<String> getLastDate() async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchCompanyNameArabic() async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchCompanyNameEnglish() async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchCompanyLocation() async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchCompanyDescription1Arabic() async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchCompanyDescription2Arabic() async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchCompanyDescription3Arabic() async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchCompanyDescription1English() async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchCompanyDescription2English() async {
    throw UnimplementedError();
  }

  @override
  Future<String> fetchCompanyDescription3English() async {
    throw UnimplementedError();
  }

  @override
  Future<int> fetchDatabaseVersion() async {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> fetchCompanyLogo() async {
    throw UnimplementedError();
  }

  @override
  Future<Map<ValueType, ValueEntity>> fetchAsMap() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> updateValue({required String value, required int rowId}) async {
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
