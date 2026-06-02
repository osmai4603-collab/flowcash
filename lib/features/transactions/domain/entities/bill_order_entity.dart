import 'package:flowcash/core/entities/entity.dart';

class BillOrderEntity extends Entity {
  final int id;
  final int billId;
  final int categoryId;
  final double countUnits;
  final double totalPrice;

  const BillOrderEntity({
    required this.id,
    required this.billId,
    required this.categoryId,
    required this.countUnits,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [id, billId, categoryId, countUnits, totalPrice];

  @override
  BillOrderEntity copyWith({
    int? id,
    int? billId,
    int? categoryId,
    double? countUnits,
    double? totalPrice,
  }) {
    return BillOrderEntity(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      categoryId: categoryId ?? this.categoryId,
      countUnits: countUnits ?? this.countUnits,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
