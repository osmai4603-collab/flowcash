import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/cost_good_bill_order_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_repository.dart';
import 'package:fpdart/fpdart.dart';

class PostBillToCostingUseCase {
  final BillRepository _repository;
  const PostBillToCostingUseCase(this._repository);

  Future<Either<Failure, BillEntity>> call({
    required BillEntity bill,
    required int userId,
    List<CostGoodBillOrderEntity>? overrideOrders,
  }) async {
    return await _repository.postToCosting(
      bill: bill,
      userId: userId,
      overrideOrders: overrideOrders,
    );
  }
}
