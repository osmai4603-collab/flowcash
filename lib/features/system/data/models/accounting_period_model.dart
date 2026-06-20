import 'package:flowcash/core/enums/accounting_inventory_type_enum.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';
import 'package:flowcash/core/tables/accounting_periods_table.dart';

final class AccountingPeriodModel extends AccountingPeriodEntity {
  const AccountingPeriodModel({
    required super.id,
    required super.periodName,
    required super.dateOfStartPeriod,
    super.dateOfEndPeriod,
    super.lastPeriodId,
    required super.currencyId,
    super.balance = 0.0,
    super.inventoryType,
  });

  factory AccountingPeriodModel.fromMap(Map<String, dynamic> map) {
    return AccountingPeriodModel(
      id: map[AccountingPeriodsTable.id] as int,
      periodName: map[AccountingPeriodsTable.periodName] as String? ?? '',
      dateOfStartPeriod: DateTime.parse(
        map[AccountingPeriodsTable.dateOfStartPeriod] as String,
      ),
      dateOfEndPeriod: map[AccountingPeriodsTable.dateOfEndPeriod] != null
          ? DateTime.tryParse(
              map[AccountingPeriodsTable.dateOfEndPeriod] as String,
            )
          : null,
      lastPeriodId: map[AccountingPeriodsTable.lastPeriodId] as int?,
      currencyId: map[AccountingPeriodsTable.currencyId] as String? ?? '',
      balance: (map[AccountingPeriodsTable.balance] ?? 0.0).toDouble(),
      inventoryType: map[AccountingPeriodsTable.inventoryType] != null
          ? AccountingInventoryType.of(
              map[AccountingPeriodsTable.inventoryType] as String,
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AccountingPeriodsTable.id: id,
      AccountingPeriodsTable.periodName: periodName,
      AccountingPeriodsTable.dateOfStartPeriod: dateOfStartPeriod
          .toIso8601String(),
      AccountingPeriodsTable.dateOfEndPeriod: dateOfEndPeriod
          ?.toIso8601String(),
      AccountingPeriodsTable.lastPeriodId: lastPeriodId,
      AccountingPeriodsTable.currencyId: currencyId,
      AccountingPeriodsTable.balance: balance,
      AccountingPeriodsTable.inventoryType: inventoryType?.name,
    };
  }

  @override
  AccountingPeriodModel copyWith({
    int? id,
    String? periodName,
    DateTime? dateOfStartPeriod,
    DateTime? dateOfEndPeriod,
    int? lastPeriodId,
    String? currencyId,
    double? balance,
    AccountingInventoryType? inventoryType,
  }) {
    return AccountingPeriodModel(
      id: id ?? this.id,
      periodName: periodName ?? this.periodName,
      dateOfStartPeriod: dateOfStartPeriod ?? this.dateOfStartPeriod,
      dateOfEndPeriod: dateOfEndPeriod ?? this.dateOfEndPeriod,
      lastPeriodId: lastPeriodId ?? this.lastPeriodId,
      currencyId: currencyId ?? this.currencyId,
      balance: balance ?? this.balance,
      inventoryType: inventoryType ?? this.inventoryType,
    );
  }
}
