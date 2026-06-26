import 'package:flowcash/core/entities/entity.dart';

class CostGoodBillOrderEntity extends Entity {
  final int id;
  final int costGoodBillId;
  final int categoryId;
  final double countUnits;
  final double totalPrice;

  const CostGoodBillOrderEntity({
    required this.id,
    required this.costGoodBillId,
    required this.categoryId,
    required this.countUnits,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [id, costGoodBillId, categoryId, countUnits, totalPrice];

  @override
  CostGoodBillOrderEntity copyWith({
    int? id,
    int? costGoodBillId,
    int? categoryId,
    double? countUnits,
    double? totalPrice,
  }) {
    return CostGoodBillOrderEntity(
      id: id ?? this.id,
      costGoodBillId: costGoodBillId ?? this.costGoodBillId,
      categoryId: categoryId ?? this.categoryId,
      countUnits: countUnits ?? this.countUnits,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
