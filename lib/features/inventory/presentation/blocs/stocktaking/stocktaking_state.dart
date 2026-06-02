import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';

enum StocktakingStatus { initial, loading, success, error }

class StocktakingState extends Equatable {
  final List<InventoryEntity> items;
  final List<WarehouseEntity> warehouses;
  final Map<int, double> actualCounts; // Key: categoryId, Value: actual count inputted
  final StocktakingStatus status;
  final String? errorMessage;

  const StocktakingState({
    this.items = const [],
    this.warehouses = const [],
    this.actualCounts = const {},
    this.status = StocktakingStatus.initial,
    this.errorMessage,
  });

  StocktakingState copyWith({
    List<InventoryEntity>? items,
    List<WarehouseEntity>? warehouses,
    Map<int, double>? actualCounts,
    StocktakingStatus? status,
    String? errorMessage,
  }) {
    return StocktakingState(
      items: items ?? this.items,
      warehouses: warehouses ?? this.warehouses,
      actualCounts: actualCounts ?? this.actualCounts,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  StocktakingState updateActualCount(int catId, double val) {
    final updated = Map<int, double>.from(actualCounts)..[catId] = val;
    return copyWith(
      actualCounts: updated,
      status: StocktakingStatus.success,
    );
  }

  StocktakingState toError(String message) {
    return copyWith(
      status: StocktakingStatus.error,
      errorMessage: message,
    );
  }

  StocktakingState toLoading() {
    return copyWith(
      status: StocktakingStatus.loading,
    );
  }

  @override
  List<Object?> get props => [items, warehouses, actualCounts, status, errorMessage];
}
