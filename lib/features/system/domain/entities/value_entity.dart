import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';

class ValueEntity extends Entity {
  final int id;
  final Object? value;
  final ValueType valueType;

  const ValueEntity({
    required this.id,
    this.value,
    required this.valueType,
  });

  @override
  List<Object?> get props => [id, value, valueType];

  @override
  ValueEntity copyWith({
    int? id,
    Object? value,
    ValueType? valueType,
  }) {
    return ValueEntity(
      id: id ?? this.id,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
    );
  }
}
