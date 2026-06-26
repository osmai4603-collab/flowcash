import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_repository.dart';
import 'package:fpdart/fpdart.dart';

class PostBillToCostingUseCase {
  final BillRepository _repository;
  const PostBillToCostingUseCase(this._repository);

  Future<Either<Failure, BillEntity>> call({
    required BillEntity bill,
    required int userId,
  }) async {
    // In a real implementation, we would call a specific method in the repository
    // For now, let's assume it's part of the BillRepository interface
    // return await _repository.postToCosting(bill: bill, userId: userId);
    throw UnimplementedError('postToCosting is not yet implemented in BillRepository');
  }
}
