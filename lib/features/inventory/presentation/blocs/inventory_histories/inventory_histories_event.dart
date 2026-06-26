part of 'inventory_histories_bloc.dart';

sealed class InventoryHistoriesEvent extends Equatable {
  const InventoryHistoriesEvent();

  @override
  List<Object> get props => [];
}

class LoadInventoryHistories extends InventoryHistoriesEvent {}
