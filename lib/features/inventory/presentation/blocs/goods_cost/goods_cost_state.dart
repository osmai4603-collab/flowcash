import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/goods_cost_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';

enum GoodsCostStatus { initial, loading, success, error }

class GoodsCostState extends Equatable {
  final List<GoodsCostEntity> costs;
  final List<WarehouseEntity> warehouses;
  final GoodsCostStatus status;
  final String? errorMessage;

  const GoodsCostState({
    this.costs = const [],
    this.warehouses = const [],
    this.status = GoodsCostStatus.initial,
    this.errorMessage,
  });

  GoodsCostState copyWith({
    List<GoodsCostEntity>? costs,
    List<WarehouseEntity>? warehouses,
    GoodsCostStatus? status,
    String? errorMessage,
  }) {
    return GoodsCostState(
      costs: costs ?? this.costs,
      warehouses: warehouses ?? this.warehouses,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  GoodsCostState addCost(GoodsCostEntity cost) {
    return copyWith(costs: [cost, ...costs], status: GoodsCostStatus.success);
  }

  GoodsCostState removeCost(int id) {
    return copyWith(
      costs: costs.where((c) => c.id != id).toList(),
      status: GoodsCostStatus.success,
    );
  }

  GoodsCostState toError(String message) {
    return copyWith(status: GoodsCostStatus.error, errorMessage: message);
  }

  GoodsCostState toLoading() {
    return copyWith(status: GoodsCostStatus.loading);
  }

  @override
  List<Object?> get props => [costs, warehouses, status, errorMessage];
}
