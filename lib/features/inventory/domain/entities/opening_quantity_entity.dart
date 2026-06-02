import 'package:flowcash/core/entities/entity.dart';

class OpeningQuantityEntity extends Entity {
  final int id;
  final int categoryId;
  final double countUnits;
  final int warehouseId;
  final DateTime createdAt;
  final double costTotal;
  final int periodId;

  const OpeningQuantityEntity({
    required this.id,
    this.categoryId = 0,
    this.countUnits = 0.0,
    this.warehouseId = 0,
    required this.createdAt,
    this.costTotal = 0.0,
    this.periodId = 0,
  });

  @override
  List<Object?> get props => [id, categoryId, countUnits, warehouseId, createdAt, costTotal, periodId];

  @override
  OpeningQuantityEntity copyWith({
    int? id,
    int? categoryId,
    double? countUnits,
    int? warehouseId,
    DateTime? createdAt,
    double? costTotal,
    int? periodId,
  }) {
    return OpeningQuantityEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      countUnits: countUnits ?? this.countUnits,
      warehouseId: warehouseId ?? this.warehouseId,
      createdAt: createdAt ?? this.createdAt,
      costTotal: costTotal ?? this.costTotal,
      periodId: periodId ?? this.periodId,
    );
  }
}