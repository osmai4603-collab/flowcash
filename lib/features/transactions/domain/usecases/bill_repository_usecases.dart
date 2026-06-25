import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_repository.dart';

/// UseCases for BillRepository

class GetBillsUseCase {
  final BillRepository _repository;

  const GetBillsUseCase(this._repository);

  Future<Either<Failure, List<BillEntity>>> call({Iterable<int>? ids}) async {
    return await _repository.get(ids: ids);
  }
}

class GetBillsWithCustomerUseCase {
  final BillRepository _repository;

  const GetBillsWithCustomerUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() async {
    return await _repository.getBillsWithCustomer();
  }
}

class GetBillByIdUseCase {
  final BillRepository _repository;

  const GetBillByIdUseCase(this._repository);

  Future<Either<Failure, BillEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertBillUseCase {
  final BillRepository _repository;

  const InsertBillUseCase(this._repository);

  Future<Either<Failure, BillEntity>> call(BillEntity entity) async {
    return await _repository.insert(entity);
  }
}

class UpdateBillUseCase {
  final BillRepository _repository;

  const UpdateBillUseCase(this._repository);

  Future<Either<Failure, BillEntity>> call(BillEntity entity) async {
    return await _repository.update(entity);
  }
}

class DeleteBillUseCase {
  final BillRepository _repository;

  const DeleteBillUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}
