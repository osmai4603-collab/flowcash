part of 'warehouse_values_cubit.dart';

abstract class WarehouseValuesEvent extends Equatable {
  const WarehouseValuesEvent();

  @override
  List<Object?> get props => [];
}

class LoadWarehouseValuesEvent extends WarehouseValuesEvent {}
