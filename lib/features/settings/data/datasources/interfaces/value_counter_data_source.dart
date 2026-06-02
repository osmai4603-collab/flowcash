import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import '../../models/value_counter_model.dart';

abstract class ValueCounterDataSource {
  Future<ValueCounterModel> getCounter(ValueCounterType type);
  Future<int> incrementCounter(ValueCounterType type);
}
