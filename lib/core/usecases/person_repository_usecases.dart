import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/repositories/interfaces/person_repository.dart';

/// UseCases for PersonRepository

class GetPersonsUseCase {
  final PersonRepository _repository;

  const GetPersonsUseCase(this._repository);

  Future<Either<Failure, List<PersonEntity>>> call({Iterable<int>? ids}) async {
    return await _repository.get(ids: ids);
  }
}

class GetPersonByIdUseCase {
  final PersonRepository _repository;

  const GetPersonByIdUseCase(this._repository);

  Future<Either<Failure, PersonEntity?>> call(int id) async {
    return await _repository.getById(id);
  }
}

class InsertPersonUseCase {
  final PersonRepository _repository;

  const InsertPersonUseCase(this._repository);

  Future<Either<Failure, PersonEntity>> call(PersonEntity entity) async {
    return await _repository.insert(entity);
  }
}

class UpdatePersonUseCase {
  final PersonRepository _repository;

  const UpdatePersonUseCase(this._repository);

  Future<Either<Failure, PersonEntity>> call(PersonEntity entity) async {
    return await _repository.update(entity);
  }
}

class DeletePersonUseCase {
  final PersonRepository _repository;

  const DeletePersonUseCase(this._repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await _repository.delete(id);
  }
}

class FirstWherePersonNameUseCase {
  final PersonRepository _repository;

  const FirstWherePersonNameUseCase(this._repository);

  Future<Either<Failure, PersonEntity?>> call({
    required String personName,
  }) async {
    return await _repository.firstWherePersonName(personName: personName);
  }
}
