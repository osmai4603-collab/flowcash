import 'package:flowcash/core/enums/warehouse_value_type_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

/// واجهة مستودع إعدادات المخزن (Warehouse values)
abstract interface class WarehouseValueRepository
    implements RepositoryDB<WarehouseValueEntity> {
  /// جلب قيمة معينة من المخزن بحسب النوع.
  Future<Either<Failure, WarehouseValueEntity?>> fetchValue({
    required int warehouseId,
    required WarehouseValueType valueType,
  });

  /// جلب معرف حساب المبيعات الافتراضي للمخزن.
  Future<Either<Failure, int>> fetchDefaultSalesAccount({
    required int warehouseId,
  });

  /// جلب معرف حساب مرتجع المبيعات الافتراضي للمخزن.
  Future<Either<Failure, int>> fetchDefaultSalesReturnAccount({
    required int warehouseId,
  });

  /// جلب معرف حساب المشتريات الافتراضي للمخزن.
  Future<Either<Failure, int>> fetchDefaultBuysAccount({
    required int warehouseId,
  });

  /// جلب معرف حساب مرتجع المشتريات الافتراضي للمخزن.
  Future<Either<Failure, int>> fetchDefaultBuysReturnAccount({
    required int warehouseId,
  });

  /// جلب كل القيم كخريطة حسب نوع القيمة.
  Future<Either<Failure, Map<WarehouseValueType, WarehouseValueEntity>>>
  fetchAsMap();

  /// تحديث قيمة محددة.
  Future<Either<Failure, bool>> updateValue({
    required String? value,
    required int id,
  });
}
