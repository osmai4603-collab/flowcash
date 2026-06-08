import 'package:flowcash/core/datasources/interfaces/person_data_source.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/persons_table.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';

final class PersonLocalDataSourceImpl implements PersonDataSource {
  final SqliteService _db;
  const PersonLocalDataSourceImpl(this._db);

  @override
  Future<List<PersonEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: PersonsTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${PersonsTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: PersonsTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<PersonEntity?> getById(int id) async {
    final rows = await _db.query(
      table: PersonsTable.tableName,
      where: '${PersonsTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<PersonEntity> insert(PersonEntity entity) async {
    final entityId = await _db.insert(
      table: PersonsTable.tableName,
      data: _sanitizeInsertData(toMap(entity), PersonsTable.id),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert person');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<PersonEntity> update(PersonEntity entity) async {
    await _db.update(
      table: PersonsTable.tableName,
      data: toMap(entity),
      where: {PersonsTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: PersonsTable.tableName,
      where: {PersonsTable.id: id},
    );
    return true;
  }

  @override
  PersonEntity fromMap(Map<String, dynamic> map) {
    return PersonEntity(
      id: map[PersonsTable.id] as int,
      personName: (map[PersonsTable.personName] as String?) ?? "",
      phoneNumber: map[PersonsTable.phoneNumber] as String?,
      address: map[PersonsTable.address] as String?,
      email: map[PersonsTable.email] as String?,
      receivableAccountId: map[PersonsTable.receivableAccountId] as int?,
      payableAccountId: map[PersonsTable.payableAccountId] as int?,
      personType: PersonType.values.firstWhere(
        (e) => e.name == map[PersonsTable.personType] as String,
      ),
      createdAt: map[PersonsTable.createdAt] == null
          ? null
          : DateTime.parse(map[PersonsTable.createdAt] as String),
    );
  }

  @override
  Map<String, dynamic> toMap(PersonEntity entity) {
    return {
      if (entity.id > 0) PersonsTable.id: entity.id,
      PersonsTable.personName: entity.personName,
      PersonsTable.phoneNumber: entity.phoneNumber,
      PersonsTable.address: entity.address,
      PersonsTable.email: entity.email,
      PersonsTable.personType: entity.personType.name,
      PersonsTable.receivableAccountId: entity.receivableAccountId,
      PersonsTable.payableAccountId: entity.payableAccountId,
      PersonsTable.createdAt: entity.createdAt?.toIso8601String(),
    };
  }

  @override
  Future<PersonEntity?> firstWherePersonName({
    required String personName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<PersonEntity>> wherePersonTypes(
    Iterable<PersonType> personTypes,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<PersonEntity>> whereIsPerson() async {
    throw UnimplementedError();
  }

  @override
  Future<List<PersonEntity>> wherePersonNameContains(
    String personName, {
    List<PersonType> personsTypes = const [],
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
