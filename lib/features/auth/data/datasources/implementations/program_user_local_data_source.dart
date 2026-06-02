import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/program_users_table.dart';
import 'package:flowcash/core/enums/user_permission_enum.dart';
import 'package:flowcash/core/enums/user_status_enum.dart';
import 'package:flowcash/core/enums/user_type_enum.dart';
import 'package:flowcash/features/auth/domain/entities/program_user_entity.dart';
import '../../models/program_user_model.dart';
import '../interfaces/program_user_data_source.dart';

class ProgramUserLocalDataSourceImpl implements ProgramUserDataSource {
  final SqliteService _db;

  const ProgramUserLocalDataSourceImpl(this._db);

  @override
  Future<List<ProgramUserEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: ProgramUsersTable.tableName);
      return rows.map(ProgramUserModel.fromMap).toList();
    }

    final placeholders = List.filled(ids.length, '?').join(', ');
    final where = '${ProgramUsersTable.id} IN ($placeholders)';
    final rows = await _db.query(
      table: ProgramUsersTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(ProgramUserModel.fromMap).toList();
  }

  @override
  Future<ProgramUserEntity?> getById(int id) async {
    final rows = await _db.query(
      table: ProgramUsersTable.tableName,
      where: '${ProgramUsersTable.id} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return ProgramUserModel.fromMap(rows.first);
  }

  @override
  Future<ProgramUserEntity> insert(ProgramUserEntity entity) async {
    await _db.insert(
      table: ProgramUsersTable.tableName,
      data: toMap(entity),
    );
    return entity;
  }

  @override
  Future<ProgramUserEntity> update(ProgramUserEntity entity) async {
    final data = toMap(entity);
    await _db.update(
      table: ProgramUsersTable.tableName,
      data: data,
      where: {ProgramUsersTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: ProgramUsersTable.tableName,
      where: {ProgramUsersTable.id: id},
    );
    return true;
  }

  @override
  ProgramUserEntity fromMap(Map<String, dynamic> map) {
    return ProgramUserModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(ProgramUserEntity entity) {
    return {
      ProgramUsersTable.id: entity.id,
      ProgramUsersTable.userName: entity.userName,
      ProgramUsersTable.password: entity.password,
      ProgramUsersTable.userType: entity.userType.name,
      ProgramUsersTable.warehouseId: entity.warehouseId,
    };
  }

  @override
  Future<ProgramUserEntity?> getUserWhereArgs({
    required String userName,
    required String password,
    required UserStatus status,
    required UserPermission permission,
  }) async {
    final rows = await _db.query(
      table: ProgramUsersTable.tableName,
      where: '${ProgramUsersTable.userName} = ? AND ${ProgramUsersTable.password} = ?',
      whereArgs: [userName, password],
    );
    if (rows.isEmpty) return null;
    return ProgramUserModel.fromMap(rows.first);
  }

  @override
  Future<List<ProgramUserEntity>> whereIsNotAdmin() async {
    final rows = await _db.query(
      table: ProgramUsersTable.tableName,
      where: '${ProgramUsersTable.userType} != ?',
      whereArgs: [UserType.admin.name],
    );
    return rows.map(ProgramUserModel.fromMap).toList();
  }

  @override
  Future<ProgramUserEntity?> firstWhereUserNameAndPassword(
    String userName,
    String password,
  ) async {
    final rows = await _db.query(
      table: ProgramUsersTable.tableName,
      where: '${ProgramUsersTable.userName} = ? AND ${ProgramUsersTable.password} = ?',
      whereArgs: [userName, password],
    );
    if (rows.isEmpty) return null;
    return ProgramUserModel.fromMap(rows.first);
  }
}
