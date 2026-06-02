


import 'package:flowcash/core/entities/entity.dart';

abstract interface class AppDataSource<Id, E extends Entity, Converter> {
  Future<List<E>> get({Iterable<Id>? ids});

  Future<E?> getById(Id id);

  Future<E> insert(E entity);

  Future<E> update(E entity);

  Future<bool> delete(Id id);

  E fromMap(Converter map);

  Converter toMap(E entity);
}