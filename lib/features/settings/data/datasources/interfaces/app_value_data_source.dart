import 'package:flowcash/core/enums/app_value_type_enum.dart';
import '../../models/app_value_model.dart';

abstract class AppValueDataSource {
  Future<List<AppValueModel>> getAllValues();
  Future<AppValueModel> getValueByType(AppValueType type);
  Future<bool> updateValue(AppValueModel value);
}
