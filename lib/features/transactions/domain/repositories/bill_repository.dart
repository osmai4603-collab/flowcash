import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class BillRepository implements RepositoryDB<BillEntity> {
  Future<Either<Failure, List<BillEntity>>> whereHasNotGoneInStore({
    bool trigger = false,
    bool printQuery = true,
  });
}
