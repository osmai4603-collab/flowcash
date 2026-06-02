import 'package:flowcash/core/tables/values_table.dart';
import 'package:flowcash/core/enums/app_value_type_enum.dart';
import '../../domain/entities/app_value_entity.dart';

final class AppValueModel extends AppValueEntity {
  const AppValueModel({
    required super.id,
    required super.value,
    required super.valueType,
  });

  factory AppValueModel.fromMap(Map<String, dynamic> map) {
    final typeName = map[ValuesTable.valueType] as String? ?? '';
    return AppValueModel(
      id: map[ValuesTable.id] ?? 0,
      value: map[ValuesTable.value]?.toString() ?? '',
      valueType: _typeFromName(typeName),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ValuesTable.value: value,
      ValuesTable.valueType: valueType.name,
    };
  }

  @override
  AppValueModel copyWith({
    int? id,
    String? value,
    AppValueType? valueType,
  }) {
    return AppValueModel(
      id: id ?? this.id,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
    );
  }

  static AppValueType _typeFromName(String name) {
    try {
      return AppValueType.of(name);
    } catch (_) {
      return AppValueType.companyDescription;
    }
  }
}
