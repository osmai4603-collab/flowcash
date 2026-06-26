import 'package:flowcash/core/tables/cost_good_bill_orders_table.dart';
import 'package:flowcash/features/transactions/domain/entities/cost_good_bill_order_entity.dart';

final class CostGoodBillOrderModel extends CostGoodBillOrderEntity {
  const CostGoodBillOrderModel({
    required super.id,
    required super.costGoodBillId,
    required super.categoryId,
    required super.countUnits,
    required super.totalPrice,
  });

  factory CostGoodBillOrderModel.fromMap(Map<String, dynamic> map) {
    return CostGoodBillOrderModel(
      id: map[CostGoodBillOrdersTable.id] as int,
      costGoodBillId: map[CostGoodBillOrdersTable.billId] as int,
      categoryId: map[CostGoodBillOrdersTable.categoryId] as int,
      countUnits: (map[CostGoodBillOrdersTable.countUnits] as num).toDouble(),
      totalPrice: (map[CostGoodBillOrdersTable.totalPrice] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) CostGoodBillOrdersTable.id: id,
      CostGoodBillOrdersTable.billId: costGoodBillId,
      CostGoodBillOrdersTable.categoryId: categoryId,
      CostGoodBillOrdersTable.countUnits: countUnits,
      CostGoodBillOrdersTable.totalPrice: totalPrice,
    };
  }

  @override
  CostGoodBillOrderModel copyWith({
    int? id,
    int? costGoodBillId,
    int? categoryId,
    double? countUnits,
    double? totalPrice,
  }) {
    return CostGoodBillOrderModel(
      id: id ?? this.id,
      costGoodBillId: costGoodBillId ?? this.costGoodBillId,
      categoryId: categoryId ?? this.categoryId,
      countUnits: countUnits ?? this.countUnits,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
