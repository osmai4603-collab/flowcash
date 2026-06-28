import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/core/tables/bill_orders_table.dart';

final class BillOrderModel extends BillOrderEntity {
  const BillOrderModel({
    required super.id,
    required super.billId,
    required super.categoryId,
    required super.countUnits,
    required super.totalPrice,
  });

  factory BillOrderModel.fromMap(Map<String, dynamic> map) {
    return BillOrderModel(
      id: map[BillOrdersTable().id] as int,
      billId: map[BillOrdersTable().billId] as int,
      categoryId: map[BillOrdersTable().categoryId] as int,
      countUnits: (map[BillOrdersTable().countUnits] ?? 0.0).toDouble(),
      totalPrice: (map[BillOrdersTable().totalPrice] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      BillOrdersTable().id: id,
      BillOrdersTable().billId: billId,
      BillOrdersTable().categoryId: categoryId,
      BillOrdersTable().countUnits: countUnits,
      BillOrdersTable().totalPrice: totalPrice,
    };
  }

  @override
  BillOrderModel copyWith({
    int? id,
    int? billId,
    int? categoryId,
    double? countUnits,
    double? totalPrice,
  }) {
    return BillOrderModel(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      categoryId: categoryId ?? this.categoryId,
      countUnits: countUnits ?? this.countUnits,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
