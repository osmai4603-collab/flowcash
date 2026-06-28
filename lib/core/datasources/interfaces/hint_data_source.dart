import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/system/domain/entities/hint_entity.dart';
import 'package:flowcash/core/enums/hint_type_enum.dart';

abstract interface class HintDataSource
    implements AppDataSource<int, HintEntity, Map<String, dynamic>> {
  Future<List<HintEntity>> whereHintType(Iterable<HintType> hintTypes);
  Future<Map<int, HintEntity>> getWhereHintTypeAsMap(
    Iterable<HintType> hintTypes,
  );
}
