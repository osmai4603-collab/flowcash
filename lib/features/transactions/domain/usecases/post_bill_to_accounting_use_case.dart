import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_repository.dart';
import 'package:fpdart/fpdart.dart';

class PostBillToAccountingUseCase {
  final BillRepository _repository;
  const PostBillToAccountingUseCase(this._repository);

  Future<Either<Failure, BillEntity>> call({
    required BillEntity bill,
    required int userId,
    required String currencyId,
    required List<ExchangePriceEntity> exPrices,
  }) async {
    return await _repository.postToAccounting(
      bill: bill,
      userId: userId,
      currencyId: currencyId,
      exPrices: exPrices,
    );
  }
}
