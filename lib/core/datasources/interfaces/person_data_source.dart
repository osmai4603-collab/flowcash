import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';

abstract interface class PersonDataSource implements AppDataSource<int, PersonEntity, Map<String, dynamic>> {
  Future<PersonEntity?> firstWherePersonName({required String personName});
  Future<List<PersonEntity>> wherePersonTypes(Iterable<PersonType> personTypes, );
  Future<List<PersonEntity>> whereIsPerson();
  Future<List<PersonEntity>> wherePersonNameContains(String personName, {List<PersonType> personsTypes = const []});
}
