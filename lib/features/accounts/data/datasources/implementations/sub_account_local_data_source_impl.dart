import 'package:flowcash/features/accounts/data/datasources/interfaces/sub_account_data_source.dart';
import 'package:flowcash/core/entities/data_record.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/data/models/sub_account_model.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/features/accounts/data/models/sub_account_simple_model.dart';
import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';

final class SubAccountLocalDataSourceImpl implements SubAccountDataSource {
  final SqliteService _db;
  const SubAccountLocalDataSourceImpl(this._db);

  @override
  Future<List<SubAccountEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: SubAccountsTable.tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${SubAccountsTable.id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<SubAccountEntity?> getById(int id) async {
    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where: '${SubAccountsTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<SubAccountEntity> insert(SubAccountEntity entity) async {
    final entityId = await _db.insert(
      table: SubAccountsTable.tableName,
      data: _sanitizeInsertData(toMap(entity), SubAccountsTable.id),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert sub account');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<SubAccountEntity> update(SubAccountEntity entity) async {
    await _db.update(
      table: SubAccountsTable.tableName,
      data: toMap(entity),
      where: {SubAccountsTable.id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: SubAccountsTable.tableName,
      where: {SubAccountsTable.id: id},
    );
    return true;
  }

  @override
  SubAccountEntity fromMap(Map<String, dynamic> map) {
    return SubAccountModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(SubAccountEntity entity) {
    if (entity is SubAccountModel) {
      return entity.toMap();
    }
    return SubAccountModel(
      id: entity.id,
      mainAccountId: entity.mainAccountId,
      accountName: entity.accountName,
      accountNumber: entity.accountNumber,
      incrementBalance: entity.incrementBalance,
      decrementBalance: entity.decrementBalance,
      currencyId: entity.currencyId,
      balanceMax: entity.balanceMax,
      subAccountType: entity.subAccountType,
      createdAt: entity.createdAt,
    ).toMap();
  }

  @override
  Future<List<SubAccountEntity>> whereMainAccount(int mainAccountId) async {
    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where: '${SubAccountsTable.mainAccountId} = ?',
      whereArgs: [mainAccountId],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<SubAccountEntity>> whereSubAccountType(
    Iterable<SubAccountType> accountsTypes,
  ) async {
    if (accountsTypes.isEmpty) return [];
    final names = accountsTypes.map((e) => e.name).toList();
    final placeholders = List.filled(names.length, '?').join(', ');
    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where: '${SubAccountsTable.subAccountType} IN ($placeholders)',
      whereArgs: names,
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<SubAccountEntity>> whereStoresAccounts(int periodId) async {
    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where: '${SubAccountsTable.subAccountType} = ?',
      whereArgs: [SubAccountType.inventory.name],
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<SubAccountEntity>> whereMainAccountId(Iterable<int> ids) async {
    if (ids.isEmpty) return [];
    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where: '${SubAccountsTable.mainAccountId} IN ($placeholders)',
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<double> getBalance(int subAccountId) async {
    final subAcc = await getById(subAccountId);
    if (subAcc == null) return 0.0;
    return subAcc.incrementBalance - subAcc.decrementBalance;
  }

  @override
  Future<int> getCountHistories(int subAccountId) async {
    final db = await _db.database;
    final sql =
        'SELECT COUNT(*) AS cnt FROM journal_items WHERE account_id = ?';
    final stmt = db.prepare(sql);
    final rs = stmt.select([subAccountId]);
    final cnt = rs.isNotEmpty ? rs.first['cnt'] as int : 0;
    stmt.dispose();
    return cnt;
  }

  @override
  Future<int> getCountCreditorHistories(int subAccountId) async {
    final db = await _db.database;
    final sql =
        'SELECT COUNT(*) AS cnt FROM journal_items WHERE account_id = ? AND credit > 0';
    final stmt = db.prepare(sql);
    final rs = stmt.select([subAccountId]);
    final cnt = rs.isNotEmpty ? rs.first['cnt'] as int : 0;
    stmt.dispose();
    return cnt;
  }

  @override
  Future<int> getCountDebtorHistories(int subAccountId) async {
    final db = await _db.database;
    final sql =
        'SELECT COUNT(*) AS cnt FROM journal_items WHERE account_id = ? AND debit > 0';
    final stmt = db.prepare(sql);
    final rs = stmt.select([subAccountId]);
    final cnt = rs.isNotEmpty ? rs.first['cnt'] as int : 0;
    stmt.dispose();
    return cnt;
  }

  @override
  Future<double> getDebtorBalance(int branchAccountId) async {
    final subAcc = await getById(branchAccountId);
    return subAcc?.incrementBalance ?? 0.0;
  }

  @override
  Future<double> getCreditorBalance(int branchAccountId) async {
    final subAcc = await getById(branchAccountId);
    return subAcc?.decrementBalance ?? 0.0;
  }

  @override
  Future<SubAccountEntity?> firstWhereMainAccount(int mainAccountId) async {
    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where: '${SubAccountsTable.mainAccountId} = ?',
      whereArgs: [mainAccountId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<bool> updateBalances({
    required double incrementBalance,
    required double decrementBalance,
    required int incrementsCountHistories,
    required int decrementsCountHistories,
    required int id,
  }) async {
    final subAcc = await getById(id);
    if (subAcc == null) return false;
    await _db.update(
      table: SubAccountsTable.tableName,
      data: {
        SubAccountsTable.incrementBalance:
            subAcc.incrementBalance + incrementBalance,
        SubAccountsTable.decrementBalance:
            subAcc.decrementBalance + decrementBalance,
      },
      where: {SubAccountsTable.id: id},
    );
    return true;
  }

  @override
  Future<bool> changeDefaultAccount({
    required int id,
    required int mainAccountId,
  }) async {
    await _db.update(
      table: SubAccountsTable.tableName,
      data: {SubAccountsTable.mainAccountId: mainAccountId},
      where: {SubAccountsTable.id: id},
    );
    return true;
  }

  @override
  Future<bool> updateBalance({
    required bool isIncrement,
    required double amount,
    required int id,
  }) async {
    final subAcc = await getById(id);
    if (subAcc == null) return false;
    final data = <String, dynamic>{};
    if (isIncrement) {
      data[SubAccountsTable.incrementBalance] =
          subAcc.incrementBalance + amount;
    } else {
      data[SubAccountsTable.decrementBalance] =
          subAcc.decrementBalance + amount;
    }
    await _db.update(
      table: SubAccountsTable.tableName,
      data: data,
      where: {SubAccountsTable.id: id},
    );
    return true;
  }

  @override
  Future<List<SubAccountEntity>> whereWarehouse(int warehouseId) async {
    final rows = await _db.query(table: SubAccountsTable.tableName);
    return rows.map(fromMap).toList();
  }

  @override
  Future<List<SubAccountEntity>> whereAccountType(
    Iterable<SubAccountType> types,
  ) async {
    return await whereSubAccountType(types);
  }

  @override
  Future<List<SubAccountEntity>> wherePerson(
    int personId,
    int warehouseId,
  ) async {
    final db = await _db.database;
    final sql =
        'SELECT receivable_acc_id, payable_acc_id FROM persons WHERE person_id = ?';
    final stmt = db.prepare(sql);
    final rs = stmt.select([personId]);
    if (rs.isEmpty) {
      stmt.dispose();
      return [];
    }
    final recId = rs.first['receivable_acc_id'] as int?;
    final payId = rs.first['payable_acc_id'] as int?;
    stmt.dispose();

    final ids = [recId, payId].whereType<int>().toList();
    if (ids.isEmpty) return [];
    return await get(ids: ids);
  }

  @override
  Future<SubAccountEntity?> firstWhereMainAccountAndPerson(
    int mainAccountId,
    int personId,
  ) async {
    final db = await _db.database;
    final sql =
        'SELECT receivable_acc_id, payable_acc_id FROM persons WHERE person_id = ?';
    final stmt = db.prepare(sql);
    final rs = stmt.select([personId]);
    if (rs.isEmpty) {
      stmt.dispose();
      return null;
    }
    final recId = rs.first['receivable_acc_id'] as int?;
    final payId = rs.first['payable_acc_id'] as int?;
    stmt.dispose();

    final ids = [recId, payId].whereType<int>().toList();
    if (ids.isEmpty) return null;

    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where:
          '${SubAccountsTable.id} IN (${ids.join(", ")}) AND ${SubAccountsTable.mainAccountId} = ?',
      whereArgs: [mainAccountId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<List<DataRecord>> whereAccountNameLike({
    required String contains,
    List<SubAccountType> types = const [],
  }) async {
    final whereClauses = <String>[];
    final whereArgs = <Object>[];
    whereClauses.add('${SubAccountsTable.accountName} LIKE ?');
    whereArgs.add('%$contains%');

    if (types.isNotEmpty) {
      final typeNames = types.map((e) => e.name).toList();
      final placeholders = List.filled(typeNames.length, '?').join(', ');
      whereClauses.add('${SubAccountsTable.subAccountType} IN ($placeholders)');
      whereArgs.addAll(typeNames);
    }

    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
    );

    return rows
        .map(
          (row) => DataRecord(
            id: row[SubAccountsTable.id] as int,
            data: row[SubAccountsTable.accountName] as String,
          ),
        )
        .toList();
  }

  @override
  Future<List<SubAccountSimpleEntity>> getAccountsWhereMainAccountId(
    int mainAccountId,
  ) async {
    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where: '${SubAccountsTable.mainAccountId} = ?',
      whereArgs: [mainAccountId],
    );
    return rows.map(SubAccountSimpleModel.fromMap).toList();
  }

  @override
  Future<List<SubAccountSimpleEntity>> getSubAccountsSimple({
    required String query,
  }) async {
    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where:
          '${SubAccountsTable.accountName} LIKE ? OR ${SubAccountsTable.accountNumber} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return rows.map(SubAccountSimpleModel.fromMap).toList();
  }

  @override
  Future<List<SubAccountEntity>> search(String query) async {
    final rows = await _db.query(
      table: SubAccountsTable.tableName,
      where:
          '${SubAccountsTable.accountName} LIKE ? OR ${SubAccountsTable.accountNumber} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return rows.map(fromMap).toList();
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
