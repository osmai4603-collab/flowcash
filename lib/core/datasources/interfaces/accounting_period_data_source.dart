import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';

abstract interface class AccountingPeriodDataSource
    implements
        AppDataSource<int, AccountingPeriodEntity, Map<String, dynamic>> {
  Future<AccountingPeriodEntity?> whereIdOpen();
}
