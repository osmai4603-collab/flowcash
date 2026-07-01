import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';
import 'package:flowcash/core/enums/warehouse_value_type_enum.dart';
import 'package:flowcash/core/tables/warehouse_values_table.dart';
import 'package:flowcash/core/models/model.dart';

final class WarehouseValueModel extends WarehouseValueEntity implements Model {
  const WarehouseValueModel({
    required super.id,
    required super.warehouseId,
    required super.valueType,
    super.value,
  });

  factory WarehouseValueModel.fromMap(Map<String, dynamic> map) {
    return WarehouseValueModel(
      id: map[WarehouseValuesTable().id] as int,
      warehouseId: map[WarehouseValuesTable().warehouseId] as int,
      valueType: WarehouseValueType.of(
        map[WarehouseValuesTable().valueType] as String,
      ),
      value: map[WarehouseValuesTable().value],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id > 0) WarehouseValuesTable().id: id,
      WarehouseValuesTable().warehouseId: warehouseId,
      WarehouseValuesTable().valueType: valueType.name,
      WarehouseValuesTable().value: value,
    };
  }

  @override
  WarehouseValueModel copyWith({
    int? id,
    int? warehouseId,
    WarehouseValueType? valueType,
    Object? value,
  }) {
    return WarehouseValueModel(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      valueType: valueType ?? this.valueType,
      value: value ?? this.value,
    );
  }
}
