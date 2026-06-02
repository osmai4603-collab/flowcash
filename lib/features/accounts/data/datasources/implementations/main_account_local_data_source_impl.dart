import 'package:flowcash/features/accounts/data/datasources/interfaces/main_account_data_source.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';

final class MainAccountLocalDataSourceImpl implements MainAccountDataSource {
  final SqliteService _db;
  const MainAccountLocalDataSourceImpl(this._db);

  @override
  Future<List<MainAccountEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: MainAccountsTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${MainAccountsTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: MainAccountsTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<MainAccountEntity?> getById(int id) async {
    final rows = await _db.query(
      table: MainAccountsTable.tableName,
      where: '${MainAccountsTable.id} = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<MainAccountEntity> insert(MainAccountEntity entity) async {
    await _db.insert(
      table: MainAccountsTable.tableName,
      data: _sanitizeInsertData(toMap(entity), MainAccountsTable.id),
    );
    return entity;
  }

  @override
  Future<MainAccountEntity> update(MainAccountEntity entity) async {
    await _db.update(
      table: MainAccountsTable.tableName,
      data: toMap(entity),
      where: {MainAccountsTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: MainAccountsTable.tableName,
      where: {MainAccountsTable.id: id},
    );
    return true;
  }

  @override
  MainAccountEntity fromMap(Map<String, dynamic> map) {
    return MainAccountEntity(
      id: map[MainAccountsTable.id] as int,
      accountName: (map[MainAccountsTable.accountName] as String?) ?? "",
      accountNumber: (map[MainAccountsTable.accountNumber] as String?) ?? "",
      imagePath: (map[MainAccountsTable.imagePath] as String?) ?? "",
      currencyId: map[MainAccountsTable.currencyId],
      incrementsBalance: ((map[MainAccountsTable.incrementsBalance]) as num)
          .toDouble(),
      decrementsBalance: ((map[MainAccountsTable.decrementsBalance]) as num)
          .toDouble(),
      mainAccountType: MainAccountType.values.firstWhere(
        (e) => e.name == map[MainAccountsTable.mainAccountType] as String,
      ),
      numbersCounter: map[MainAccountsTable.numbersCounter] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(MainAccountEntity entity) {
    return {
      if (entity.id > 0) MainAccountsTable.id: entity.id,
      MainAccountsTable.accountName: entity.accountName,
      MainAccountsTable.accountNumber: entity.accountNumber,
      MainAccountsTable.imagePath: entity.imagePath,
      MainAccountsTable.currencyId: entity.currencyId,
      MainAccountsTable.incrementsBalance: entity.incrementsBalance,
      MainAccountsTable.decrementsBalance: entity.decrementsBalance,
      MainAccountsTable.mainAccountType: entity.mainAccountType.name,
      MainAccountsTable.numbersCounter: entity.numbersCounter,
    };
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
      table: MainAccountsTable.tableName,
      where: '${MainAccountsTable.mainAccountType} IN ($typePlaceholders)',
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
      table: MainAccountsTable.tableName,
      where: '${MainAccountsTable.mainAccountType} = ?',
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
      table: MainAccountsTable.tableName,
      where: '${MainAccountsTable.mainAccountType} IN ($placeholders)',
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
      table: MainAccountsTable.tableName,
      where: '${MainAccountsTable.mainAccountType} IN ($placeholders)',
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
        'SELECT MAX(CAST(${MainAccountsTable.accountNumber} AS INTEGER)) AS max_num FROM ${MainAccountsTable.tableName} WHERE ${MainAccountsTable.mainAccountType} IN ($placeholders)';
    final stmt = db.prepare(sql);
    final rs = stmt.select(types);
    final maxNum = rs.isNotEmpty ? rs.first['max_num'] as int? : null;
    stmt.dispose();
    return maxNum;
  }

  @override
  Future<List<MainAccountEntity>> whereWarehouse(int warehouseId) async {
    final rows = await _db.query(table: MainAccountsTable.tableName);
    return rows.map(fromMap).toList();
  }

  @override
  Future<bool> updateCounter({required int counter, required int id}) async {
    await _db.update(
      table: MainAccountsTable.tableName,
      data: {MainAccountsTable.numbersCounter: counter},
      where: {MainAccountsTable.id: id},
    );
    return true;
  }

  @override
  Future<bool> updateBalances({
    required double incrementBalance,
    required double decrementBalance,
    required int id,
  }) async {
    final mainAcc = await getById(id);
    if (mainAcc == null) return false;
    await _db.update(
      table: MainAccountsTable.tableName,
      data: {
        MainAccountsTable.incrementsBalance:
            mainAcc.incrementsBalance + incrementBalance,
        MainAccountsTable.decrementsBalance:
            mainAcc.decrementsBalance + decrementBalance,
      },
      where: {MainAccountsTable.id: id},
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
      data[MainAccountsTable.incrementsBalance] =
          mainAcc.incrementsBalance + amount;
    } else {
      data[MainAccountsTable.decrementsBalance] =
          mainAcc.decrementsBalance + amount;
    }
    await _db.update(
      table: MainAccountsTable.tableName,
      data: data,
      where: {MainAccountsTable.id: mainAcc.id},
    );
    return true;
  }

  @override
  Future<MainAccountEntity> firstWhereSubAccountId(int subAccountId) async {
    final db = await _db.database;
    final sql =
        '''
      SELECT m.* FROM ${MainAccountsTable.tableName} m
      INNER JOIN sub_accounts s ON s.main_account_id = m.${MainAccountsTable.id}
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
