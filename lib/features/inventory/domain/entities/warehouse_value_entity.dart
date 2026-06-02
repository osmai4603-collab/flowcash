import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/warehouse_value_type.dart';


class WarehouseValueEntity extends Entity {
  final int id;
  final int warehouseId;
  final WarehouseValueType valueType;
  final Object? value;

  const WarehouseValueEntity({
    required this.id,
    required this.warehouseId,
    required this.valueType,
    this.value,
  });

  @override
  List<Object?> get props => [id, warehouseId, valueType, value];

  @override
  WarehouseValueEntity copyWith({
    int? id,
    int? warehouseId,
    WarehouseValueType? valueType,
    Object? value,
  }) {
    return WarehouseValueEntity(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      valueType: valueType ?? this.valueType,
      value: value ?? this.value,
    );
  }
}
