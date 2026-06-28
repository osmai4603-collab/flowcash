import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/core/enums/warehouse_type_enum.dart';
import 'package:flowcash/core/tables/warehouses_table.dart';

final class WarehouseModel extends WarehouseEntity {
  const WarehouseModel({
    required super.id,
    super.warehouseName = '',
    super.location = '',
    required super.warehouseType,
    super.parentId,
  });

  factory WarehouseModel.fromMap(Map<String, dynamic> map) {
    return WarehouseModel(
      id: map[WarehousesTable().id] as int,
      warehouseName: (map[WarehousesTable().warehouseName] as String?) ?? "",
      location: (map[WarehousesTable().location] as String?) ?? "",
      warehouseType: WarehouseType.of(map[WarehousesTable().warehouseType]),
      parentId: map[WarehousesTable().parentId] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) WarehousesTable().id: id,
      WarehousesTable().warehouseName: warehouseName,
      WarehousesTable().location: location,
      WarehousesTable().warehouseType: warehouseType.name,
      WarehousesTable().parentId: parentId,
    };
  }

  @override
  WarehouseModel copyWith({
    int? id,
    String? warehouseName,
    String? location,
    WarehouseType? warehouseType,
    int? parentId,
  }) {
    return WarehouseModel(
      id: id ?? this.id,
      warehouseName: warehouseName ?? this.warehouseName,
      location: location ?? this.location,
      warehouseType: warehouseType ?? this.warehouseType,
      parentId: parentId ?? this.parentId,
    );
  }
}
