import 'package:flowcash/core/enums/app_value_type_enum.dart';
import 'package:equatable/equatable.dart';

class AppValueEntity extends Equatable {
  final int id;
  final String value;
  final AppValueType valueType;

  const AppValueEntity({
    this.id = 0,
    this.value = '',
    this.valueType = AppValueType.companyDescription,
  });

  @override
  List<Object?> get props => [id, value, valueType];

  AppValueEntity copyWith({int? id, String? value, AppValueType? valueType}) {
    return AppValueEntity(
      id: id ?? this.id,
      value: value ?? this.value,
      valueType: valueType ?? this.valueType,
    );
  }
}
