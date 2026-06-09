import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';
import 'package:flowcash/core/repositories/interfaces/person_repository.dart';
import 'package:flowcash/core/datasources/interfaces/person_data_source.dart';

class PersonRepositoryImpl implements PersonRepository {
  final PersonDataSource _dataSource;

  const PersonRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<PersonEntity>>> get({
    Iterable<int>? ids,
  }) async {
    try {
      final res = await _dataSource.get(ids: ids);
      return right(res);
    } on Failure catch (f) {
      return left(f);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonEntity?>> getById(int id) async {
    try {
      final res = await _dataSource.getById(id);
      return right(res);
    } on Failure catch (f) {
      return left(f);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonEntity>> insert(PersonEntity entity) async {
    try {
      final res = await _dataSource.insert(entity);
      return right(res);
    } on Failure catch (f) {
      return left(f);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonEntity>> update(PersonEntity entity) async {
    try {
      final res = await _dataSource.update(entity);
      return right(res);
    } on Failure catch (f) {
      return left(f);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(int id) async {
    try {
      final res = await _dataSource.delete(id);
      return right(res);
    } on Failure catch (f) {
      return left(f);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonEntity?>> firstWherePersonName({
    required String personName,
  }) async {
    try {
      final res = await _dataSource.firstWherePersonName(
        personName: personName,
      );
      return right(res);
    } on Failure catch (f) {
      return left(f);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PersonEntity>>> wherePersonTypes(
    Iterable<PersonType> personTypes,
  ) async {
    try {
      final res = await _dataSource.wherePersonTypes(personTypes);
      return right(res);
    } on Failure catch (f) {
      return left(f);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PersonEntity>>> whereIsPerson() async {
    try {
      final res = await _dataSource.whereIsPerson();
      return right(res);
    } on Failure catch (f) {
      return left(f);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PersonEntity>>> wherePersonNameContains(
    String personName, {
    List<PersonType> personsTypes = const [],
  }) async {
    try {
      final res = await _dataSource.wherePersonNameContains(
        personName,
        personsTypes: personsTypes,
      );
      return right(res);
    } on Failure catch (f) {
      return left(f);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
