import 'package:fpdart/fpdart.dart';
import 'package:flowcash/core/errors/failure.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class PersonRepository implements RepositoryDB<PersonEntity> {
  Future<Either<Failure, PersonEntity?>> firstWherePersonName({required String personName});
  Future<Either<Failure, List<PersonEntity>>> wherePersonTypes(Iterable<PersonType> personTypes);
  Future<Either<Failure, List<PersonEntity>>> whereIsPerson();
  Future<Either<Failure, List<PersonEntity>>> wherePersonNameContains(String personName, {List<PersonType> personsTypes = const []});
}
