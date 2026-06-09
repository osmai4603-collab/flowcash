import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';
import '../../../../../core/datasources/datasource.dart';
import '../../models/value_counter_model.dart';

abstract class ValueCounterDataSource implements AppDataSource<int, ValueCounterEntity, Map<String, dynamic>> {
  Future<ValueCounterModel> getCounter(ValueCounterType type);
  Future<int> incrementCounter(ValueCounterType type);
  Future<ValueCounterModel> setCounter(ValueCounterModel counter);

  Future<ValueCounterEntity> getValueCounterByCounterType(ValueCounterType counterType);
}
