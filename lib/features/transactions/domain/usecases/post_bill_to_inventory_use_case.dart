import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_repository.dart';
import 'package:fpdart/fpdart.dart';

class PostBillToInventoryUseCase {
  final BillRepository _repository;
  const PostBillToInventoryUseCase(this._repository);

  Future<Either<Failure, BillEntity>> call({
    required BillEntity bill,
    required int userId,
  }) async {
    return await _repository.postToInventory(
      bill: bill,
      userId: userId,
    );
  }
}
