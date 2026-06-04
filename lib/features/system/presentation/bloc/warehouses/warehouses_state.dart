part of 'warehouses_cubit.dart';

abstract class WarehousesState extends Equatable {
  const WarehousesState();
}

class WarehousesInitial extends WarehousesState {
  const WarehousesInitial();

  @override
  List<Object?> get props => [];
}

class WarehousesLoading extends WarehousesState {
  const WarehousesLoading();

  @override
  List<Object?> get props => [];
}

class WarehousesSuccess extends WarehousesState {
  final List<WarehouseEntity> items;

  const WarehousesSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class WarehousesFailure extends WarehousesState {
  final String errorMessage;

  const WarehousesFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
