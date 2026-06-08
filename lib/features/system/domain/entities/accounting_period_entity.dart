import 'package:flowcash/core/enums/accounting_inventory_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';

class AccountingPeriodEntity extends Entity {
  final int id;
  final String periodName;
  final DateTime dateOfStartPeriod;
  final DateTime? dateOfEndPeriod;
  final int? lastPeriodId;
  final String currencyId;
  final double balance;
  final AccountingInventoryType? inventoryType;

  const AccountingPeriodEntity({
    required this.id,
    required this.periodName,
    required this.dateOfStartPeriod,
    this.dateOfEndPeriod,
    this.lastPeriodId,
    required this.currencyId,
    this.balance = 0.0,
    this.inventoryType,
  });

  @override
  List<Object?> get props => [
    id,
    periodName,
    dateOfStartPeriod,
    dateOfEndPeriod,
    lastPeriodId,
    currencyId,
    balance,
    inventoryType,
  ];

  @override
  AccountingPeriodEntity copyWith({
    int? id,
    String? periodName,
    DateTime? dateOfStartPeriod,
    DateTime? dateOfEndPeriod,
    int? lastPeriodId,
    String? currencyId,
    double? balance,
    AccountingInventoryType? inventoryType,
  }) {
    return AccountingPeriodEntity(
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

  bool get isOpen {
    if (dateOfEndPeriod == null) return true;
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    final endDate = DateTime(
      dateOfEndPeriod!.year,
      dateOfEndPeriod!.month,
      dateOfEndPeriod!.day,
    );
    return endDate.isAtSameMomentAs(currentDate) ||
        endDate.isAfter(currentDate);
  }

  bool get hasLocked => dateOfEndPeriod != null;
}
