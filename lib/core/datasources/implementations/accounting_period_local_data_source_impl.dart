import 'package:flowcash/core/datasources/interfaces/accounting_period_data_source.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';
import 'package:flowcash/core/enums/accounting_inventory_type_enum.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/tables/accounting_periods_table.dart';

final class AccountingPeriodLocalDataSourceImpl
    implements AccountingPeriodDataSource {
  final SqliteService _db;
  const AccountingPeriodLocalDataSourceImpl(this._db);

  @override
  Future<List<AccountingPeriodEntity>> get({Iterable<int>? ids}) async {
    if (ids == null) {
      final rows = await _db.query(table: AccountingPeriodsTable().tableName);
      return rows.map(fromMap).toList();
    }
    final where =
        '${AccountingPeriodsTable().id} IN (${List.filled(ids.length, '?').join(', ')})';
    final rows = await _db.query(
      table: AccountingPeriodsTable().tableName,
      where: where,
      whereArgs: ids.toList(),
    );
    return rows.map(fromMap).toList();
  }

  @override
  Future<AccountingPeriodEntity?> getById(int id) async {
    final rows = await _db.query(
      table: AccountingPeriodsTable().tableName,
      where: '${AccountingPeriodsTable().id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }

  @override
  Future<AccountingPeriodEntity> insert(AccountingPeriodEntity entity) async {
    final entityId = await _db.insert(
      table: AccountingPeriodsTable().tableName,
      data: toMap(entity),
    );
    if (entityId < 0) {
      throw Exception('Failed to insert accounting period');
    }
    return entity.copyWith(id: entityId);
  }

  @override
  Future<AccountingPeriodEntity> update(AccountingPeriodEntity entity) async {
    await _db.update(
      table: AccountingPeriodsTable().tableName,
      data: toMap(entity),
      where: {AccountingPeriodsTable().id: entity.id},
    );
    return entity;
  }

  @override
  Future<bool> delete(int id) async {
    await _db.deleteWhere(
      table: AccountingPeriodsTable().tableName,
      where: {AccountingPeriodsTable().id: id},
    );
    return true;
  }

  @override
  AccountingPeriodEntity fromMap(Map<String, dynamic> map) {
    return AccountingPeriodEntity(
      id: map[AccountingPeriodsTable().id] as int,
      periodName: (map[AccountingPeriodsTable().periodName] as String?) ?? "",
      dateOfStartPeriod: DateTime.parse(
        map[AccountingPeriodsTable().dateOfStartPeriod] as String,
      ),
      dateOfEndPeriod: DateTime.tryParse(
        map[AccountingPeriodsTable().dateOfEndPeriod] ?? '',
      ),
      lastPeriodId: map[AccountingPeriodsTable().lastPeriodId] as int?,
      currencyId: map[AccountingPeriodsTable().currencyId],
      balance: ((map[AccountingPeriodsTable().balance]) as num).toDouble(),
      inventoryType: map[AccountingPeriodsTable().inventoryType] == null
          ? null
          : AccountingInventoryType.values.firstWhere(
              (e) =>
                  e.name == map[AccountingPeriodsTable().inventoryType] as String,
            ),
    );
  }

  @override
  Map<String, dynamic> toMap(AccountingPeriodEntity entity) {
    return {
      if (entity.id > 0) AccountingPeriodsTable().id: entity.id,
      AccountingPeriodsTable().periodName: entity.periodName,
      AccountingPeriodsTable().dateOfStartPeriod: entity.dateOfStartPeriod
          .toIso8601String(),
      AccountingPeriodsTable().dateOfEndPeriod: entity.dateOfEndPeriod
          ?.toIso8601String(),
      AccountingPeriodsTable().lastPeriodId: entity.lastPeriodId,
      AccountingPeriodsTable().currencyId: entity.currencyId,
      AccountingPeriodsTable().balance: entity.balance,
      AccountingPeriodsTable().inventoryType: entity.inventoryType?.name,
    };
  }

  @override
  Future<AccountingPeriodEntity?> whereIdOpen() async {
    final rows = await _db.query(
      table: AccountingPeriodsTable().tableName,
      where:
          '${AccountingPeriodsTable().dateOfEndPeriod} IS NULL OR ${AccountingPeriodsTable().dateOfEndPeriod} >= ?',
      whereArgs: [DateTime.now().toIso8601String()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return fromMap(rows.first);
  }
}
