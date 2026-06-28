import 'package:flowcash/features/accounts/data/datasources/interfaces/main_account_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/accounts/data/models/main_account_model.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';

final class MainAccountLocalDataSourceImpl implements MainAccountDataSource {
  final SqliteService _db;
  const MainAccountLocalDataSourceImpl(this._db);

  @override
  Future<List<MainAccountEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: MainAccountsTable().tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${MainAccountsTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: MainAccountsTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<MainAccountEntity?> getById(int id) async {
    final rows = await _db.query(
      table: MainAccountsTable().tableName,
      where: '${MainAccountsTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<MainAccountEntity> insert(MainAccountEntity entity) async {
    final entityId = await _db.insert(
      table: MainAccountsTable().tableName,
      data: toMap(entity),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert main account');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<MainAccountEntity> update(MainAccountEntity entity) async {
    await _db.update(
      table: MainAccountsTable().tableName,
      data: toMap(entity),
      where: {MainAccountsTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: MainAccountsTable().tableName,
      where: {MainAccountsTable().id: id},
    );
    return true;
  }

  @override
  MainAccountEntity fromMap(Map<String, dynamic> map) {
    return MainAccountModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(MainAccountEntity entity) {
    if (entity is MainAccountModel) {
      return entity.toMap();
    }
    return MainAccountModel(
      id: entity.id,
      accountName: entity.accountName,
      accountNumber: entity.accountNumber,
      currencyId: entity.currencyId,
      debitBalance: entity.debitBalance,
      creditBalance: entity.creditBalance,
      mainAccountType: entity.mainAccountType,
      numbersCounter: entity.numbersCounter,
    ).toMap();
  }

  @override
  Future<List<MainAccountEntity>> whereAccountGroup(
    MainAccountGroup accountType,
    int periodId,
  ) async {
    final types = MainAccountType.whereMainAccount(
      accountType,
    ).map((e) => e.name).toList();
    if (types.isEmpty) return [];
    final typePlaceholders = List.filled(types.length, '?').join(', ');
    final rows = await _db.query(
      table: MainAccountsTable().tableName,
      where: '${MainAccountsTable().mainAccountType} IN ($typePlaceholders)',
      whereArgs: types,
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<MainAccountEntity>> whereMainAccountType(
    MainAccountType belongGroup,
    int warehouseId,
  ) async {
    final rows = await _db.query(
      table: MainAccountsTable().tableName,
      where: '${MainAccountsTable().mainAccountType} = ?',
      whereArgs: [belongGroup.name],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<MainAccountEntity>> whereAccountType(
    Iterable<MainAccountType> belongGroup,
    int warehouseId,
  ) async {
    if (belongGroup.isEmpty) return [];
    final names = belongGroup.map((e) => e.name).toList();
    final placeholders = List.filled(names.length, '?').join(', ');
    final rows = await _db.query(
      table: MainAccountsTable().tableName,
      where: '${MainAccountsTable().mainAccountType} IN ($placeholders)',
      whereArgs: names,
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<MainAccountEntity>> whereAccountsGroups(
    Iterable<MainAccountGroup> types,
    int warehouseId,
  ) async {
    if (types.isEmpty) return [];
    final mainTypes = MainAccountType.whereMainAccounts(
      types,
    ).map((e) => e.name).toList();
    if (mainTypes.isEmpty) return [];
    final placeholders = List.filled(mainTypes.length, '?').join(', ');
    final rows = await _db.query(
      table: MainAccountsTable().tableName,
      where: '${MainAccountsTable().mainAccountType} IN ($placeholders)',
      whereArgs: mainTypes,
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<int?> getMaxAccountNumber(MainAccountGroup accountType) async {
    final types = MainAccountType.whereMainAccount(
      accountType,
    ).map((e) => e.name).toList();
    if (types.isEmpty) return null;
    final placeholders = List.filled(types.length, '?').join(', ');
    final db = await _db.database;
    final sql =
        'SELECT MAX(CAST(${MainAccountsTable().accountNumber} AS INTEGER)) AS max_num FROM ${MainAccountsTable().tableName} WHERE ${MainAccountsTable().mainAccountType} IN ($placeholders)';
    final stmt = db.prepare(sql);
    final rs = stmt.select(types);
    final maxNum = rs.isNotEmpty ? rs.first['max_num'] as int? : null;
    stmt.dispose();
    return maxNum;
  }

  @override
  Future<List<MainAccountEntity>> whereWarehouse(int warehouseId) async {
    final rows = await _db.query(table: MainAccountsTable().tableName);
    return rows.map(fromMap).toList();
  }

  @override
  Future<bool> updateCounter({required int counter, required int id}) async {
    await _db.update(
      table: MainAccountsTable().tableName,
      data: {MainAccountsTable().numbersCounter: counter},
      where: {MainAccountsTable().id: id},
    );
    return true;
  }

  @override
  Future<bool> updateBalances({
    required double debitBalance,
    required double creditBalance,
    required int id,
  }) async {
    final mainAcc = await getById(id);
    if (mainAcc == null) return false;
    await _db.update(
      table: MainAccountsTable().tableName,
      data: {
        MainAccountsTable().debitBalance: mainAcc.debitBalance + debitBalance,
        MainAccountsTable().creditBalance: mainAcc.creditBalance + creditBalance,
      },
      where: {MainAccountsTable().id: id},
    );
    return true;
  }

  @override
  Future<bool> updateBalance({
    required bool isIncrement,
    required double amount,
    required int subAccountId,
  }) async {
    final mainAcc = await firstWhereSubAccountId(subAccountId);
    final data = <String, dynamic>{};
    if (isIncrement) {
      data[MainAccountsTable().debitBalance] = mainAcc.debitBalance + amount;
    } else {
      data[MainAccountsTable().creditBalance] = mainAcc.creditBalance + amount;
    }
    await _db.update(
      table: MainAccountsTable().tableName,
      data: data,
      where: {MainAccountsTable().id: mainAcc.id},
    );
    return true;
  }

  @override
  Future<MainAccountEntity> firstWhereSubAccountId(int subAccountId) async {
    final db = await _db.database;
    final sql =
        '''
      SELECT m.* FROM ${MainAccountsTable().tableName} m
      INNER JOIN sub_accounts s ON s.main_account_id = m.${MainAccountsTable().id}
      WHERE s.account_id = ?
    ''';
    final stmt = db.prepare(sql);
    final rs = stmt.select([subAccountId]);
    if (rs.isEmpty) {
      stmt.dispose();
      throw StateError(
        'No main account found for sub account ID: $subAccountId',
      );
    }
    final mainAcc = fromMap(Map<String, dynamic>.from(rs.first));
    stmt.dispose();
    return mainAcc;
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
