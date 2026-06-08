import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class WarehouseRepository
    implements RepositoryDB<WarehouseEntity> {
  Future<Either<Failure, WarehouseEntity?>> getByCode(String code);
}
