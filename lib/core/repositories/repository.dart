import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class RepositoryDB<E extends Entity> {
  Future<Either<Failure, List<E>>> get({Iterable<int>? ids});

  Future<Either<Failure, E?>> getById(int id);

  Future<Either<Failure, E>> insert(E entity);

  Future<Either<Failure, E>> update(E entity);

  Future<Either<Failure, bool>> delete(int id);
}
