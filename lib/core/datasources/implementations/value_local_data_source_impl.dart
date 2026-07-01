import 'package:flowcash/core/datasources/interfaces/value_data_source.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/values_table.dart';
import 'dart:typed_data';

final class ValueLocalDataSourceImpl implements ValueDataSource {
  final SqliteDatabase _db;
  const ValueLocalDataSourceImpl(this._db);

  @override
  Future<List<ValueEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: ValuesTable().tableName);
      return rows.map(fromMap).toList();
    }
    final placeholders = List.filled(ids.length, '?').join(', ');
    final where = '${ValuesTable().id} IN ($placeholders)';
    final rows = await _db.query(
      table: ValuesTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<ValueEntity?> getById(int id) async {
    final rows = await _db.query(
      table: ValuesTable().tableName,
      where: '${ValuesTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<ValueEntity> insert(ValueEntity entity) async {
    final entityId = await _db.insert(
      table: ValuesTable().tableName,
      data: _sanitizeInsertData(toMap(entity), ValuesTable().id),
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
      table: ValuesTable().tableName,
      data: data,
      where: {ValuesTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: ValuesTable().tableName,
      where: {ValuesTable().id: id},
    );
    return true;
  }

  @override
  ValueEntity fromMap(Map<String, dynamic> map) {
    return ValueEntity(
      id: map[ValuesTable().id] as int,
      value: map[ValuesTable().value],
      valueType: ValueType.values.firstWhere(
        (e) => e.name == map[ValuesTable().valueType] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(ValueEntity entity) {
    return {
      if (entity.id > 0) ValuesTable().id: entity.id,
      ValuesTable().value: entity.value,
      ValuesTable().valueType: entity.valueType.name,
    };
  }

  @override
  Future<ValueEntity?> firstValue(ValueType valueType) async {
    final rows = await _db.query(
      table: ValuesTable().tableName,
      where: '${ValuesTable().valueType} = ?',
      whereArgs: [valueType.name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<ValueEntity> getValue(ValueType valueType) async {
    final value = await firstValue(valueType);
    if (value == null) {
      return ValueEntity(
        id: 0,
        valueType: valueType,
        value: valueType.defaultValue,
      );
    }
    return value;
  }

  @override
  Future<int> fetchLocalCurrency() async {
    final val = await getValue(ValueType.defaultCurrency);
    return int.tryParse(val.value?.toString() ?? '') ?? 1;
  }

  @override
  Future<String> fetchFirstDate() async {
    final val = await getValue(ValueType.firstDate);
    return val.value?.toString() ?? ValueType.firstDate.defaultValue;
  }

  @override
  Future<String> getLastDate() async {
    final val = await getValue(ValueType.lastDate);
    return val.value?.toString() ?? ValueType.lastDate.defaultValue;
  }

  @override
  Future<String> fetchCompanyNameArabic() async {
    final val = await getValue(ValueType.nameInArabic1);
    return val.value?.toString() ?? ValueType.nameInArabic1.defaultValue;
  }

  @override
  Future<String> fetchCompanyNameEnglish() async {
    final val = await getValue(ValueType.nameInEnglish1);
    return val.value?.toString() ?? ValueType.nameInEnglish1.defaultValue;
  }

  @override
  Future<String> fetchCompanyLocation() async {
    final val = await getValue(ValueType.addressInArabic);
    return val.value?.toString() ?? ValueType.addressInArabic.defaultValue;
  }

  @override
  Future<String> fetchCompanyDescription1Arabic() async {
    final val = await getValue(ValueType.description1Arabic);
    return val.value?.toString() ?? ValueType.description1Arabic.defaultValue;
  }

  @override
  Future<String> fetchCompanyDescription2Arabic() async {
    final val = await getValue(ValueType.description2Arabic);
    return val.value?.toString() ?? ValueType.description2Arabic.defaultValue;
  }

  @override
  Future<String> fetchCompanyDescription3Arabic() async {
    final val = await getValue(ValueType.description3Arabic);
    return val.value?.toString() ?? ValueType.description3Arabic.defaultValue;
  }

  @override
  Future<String> fetchCompanyDescription1English() async {
    final val = await getValue(ValueType.description1English);
    return val.value?.toString() ?? ValueType.description1English.defaultValue;
  }

  @override
  Future<String> fetchCompanyDescription2English() async {
    final val = await getValue(ValueType.description2English);
    return val.value?.toString() ?? ValueType.description2English.defaultValue;
  }

  @override
  Future<String> fetchCompanyDescription3English() async {
    final val = await getValue(ValueType.description3English);
    return val.value?.toString() ?? ValueType.description3English.defaultValue;
  }

  @override
  Future<int> fetchDatabaseVersion() async {
    final val = await getValue(ValueType.databaseVersion);
    return int.tryParse(val.value?.toString() ?? '') ?? 1;
  }

  @override
  Future<Uint8List> fetchCompanyLogo() async {
    final val = await getValue(ValueType.companyLogo);
    final data = val.value;
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    return Uint8List(0);
  }

  @override
  Future<Map<ValueType, ValueEntity>> fetchAsMap() async {
    final all = await get();
    return {for (final item in all) item.valueType: item};
  }

  @override
  Future<bool> updateValue({required String value, required int rowId}) async {
    await _db.update(
      table: ValuesTable().tableName,
      data: {ValuesTable().value: value},
      where: {ValuesTable().id: rowId},
    );
    return true;
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
