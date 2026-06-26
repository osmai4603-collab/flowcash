part of 'inventory_histories_bloc.dart';

sealed class InventoryHistoriesState extends Equatable {
  const InventoryHistoriesState();

  @override
  List<Object> get props => [];
}

class InventoryHistoriesInitial extends InventoryHistoriesState {}

class InventoryHistoriesLoading extends InventoryHistoriesState {}

class InventoryHistoriesLoaded extends InventoryHistoriesState {
  final List<InventoryHistory> histories;

  const InventoryHistoriesLoaded(this.histories);

  @override
  List<Object> get props => [histories];
}

class InventoryHistoriesError extends InventoryHistoriesState {
  final String message;

  const InventoryHistoriesError(this.message);

  @override
  List<Object> get props => [message];
}
