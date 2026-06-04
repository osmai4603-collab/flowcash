import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/repositories/repository.dart';
import 'package:fpdart/fpdart.dart';

/// واجهة مستودع فترات المحاسبة
abstract interface class AccountingPeriodRepository implements RepositoryDB<AccountingPeriodEntity> {
  Future<Either<Failure, AccountingPeriodEntity?>> whereIdOpen();
}
