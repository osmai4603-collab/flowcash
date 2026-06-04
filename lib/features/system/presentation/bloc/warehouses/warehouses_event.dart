part of 'warehouses_cubit.dart';

abstract class WarehousesEvent extends Equatable {
  const WarehousesEvent();

  @override
  List<Object?> get props => [];
}

class LoadWarehousesEvent extends WarehousesEvent {}
