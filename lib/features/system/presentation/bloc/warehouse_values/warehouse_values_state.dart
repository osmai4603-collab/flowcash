part of 'warehouse_values_cubit.dart';

abstract class WarehouseValuesState extends Equatable {
  const WarehouseValuesState();
}

class WarehouseValuesInitial extends WarehouseValuesState {
  const WarehouseValuesInitial();

  @override
  List<Object?> get props => [];
}

class WarehouseValuesLoading extends WarehouseValuesState {
  const WarehouseValuesLoading();

  @override
  List<Object?> get props => [];
}

class WarehouseValuesSuccess extends WarehouseValuesState {
  final List<dynamic> items;

  const WarehouseValuesSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class WarehouseValuesFailure extends WarehouseValuesState {
  final String errorMessage;

  const WarehouseValuesFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
