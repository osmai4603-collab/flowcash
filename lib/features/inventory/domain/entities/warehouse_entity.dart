import 'package:flowcash/core/enums/warehouse_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';

class WarehouseEntity extends Entity {
  final int id;
  final String warehouseName;
  final String location;
  final WarehouseType warehouseType;
  final int? parentId;

  const WarehouseEntity({
    required this.id,
    this.warehouseName = '',
    this.location = '',
    required this.warehouseType,
    this.parentId,
  });

  @override
  List<Object?> get props => [
    id,
    warehouseName,
    location,
    warehouseType,
    parentId,
  ];

  WarehouseEntity copyWith({
    int? id,
    String? warehouseName,
    String? location,
    WarehouseType? warehouseType,
    int? parentId,
  }) {
    return WarehouseEntity(
      id: id ?? this.id,
      warehouseName: warehouseName ?? this.warehouseName,
      location: location ?? this.location,
      warehouseType: warehouseType ?? this.warehouseType,
      parentId: parentId ?? this.parentId,
    );
  }
}
