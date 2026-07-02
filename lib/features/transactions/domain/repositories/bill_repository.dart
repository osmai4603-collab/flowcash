import 'package:flowcash/features/transactions/domain/entities/cost_good_bill_order_entity.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';

abstract interface class BillRepository implements RepositoryDB<BillEntity> {
  Future<Either<Failure, List<BillEntity>>> whereHasNotGoneInStore({
    bool trigger = false,
    bool printQuery = true,
  });

  /// ترحيل الفاتورة محاسبياً — إنشاء قيد يومية وتحديث الأرصدة.
  Future<Either<Failure, BillEntity>> postToAccounting({
    required BillEntity bill,
    required int userId,
    required String currencyId,
    required List<ExchangePriceEntity> exPrices,
  });

  /// ترحيل الفاتورة مخزنياً — إنشاء حركة مخزون.
  Future<Either<Failure, BillEntity>> postToInventory({
    required BillEntity bill,
    required int userId,
  });

  /// ترحيل تكلفة الفاتورة (COGS).
  Future<Either<Failure, BillEntity>> postToCosting({
    required BillEntity bill,
    required int userId,
    List<CostGoodBillOrderEntity>? overrideOrders,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getBillsWithCustomer();
}
