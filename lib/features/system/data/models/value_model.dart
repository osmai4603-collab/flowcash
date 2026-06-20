import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';
import 'package:flowcash/core/tables/values_table.dart';

final class ValueModel extends ValueEntity {
  const ValueModel({required super.id, super.value, required super.valueType});

  factory ValueModel.fromMap(Map<String, dynamic> map) {
    return ValueModel(
      id: map[ValuesTable.id] as int,
      value: map[ValuesTable.value],
      valueType: ValueType.of(
        map[ValuesTable.valueType] as String? ?? 'app_name',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ValuesTable.id: id,
      ValuesTable.value: value,
      ValuesTable.valueType: valueType.name,
    };
  }

  @override
  ValueModel copyWith({int? id, Object? value, ValueType? valueType}) {
    return ValueModel(
      id: id ?? this.id,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
    );
  }
}
