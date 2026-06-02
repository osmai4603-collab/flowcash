import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';

abstract class OpeningQuantitiesEvent extends Equatable {
  const OpeningQuantitiesEvent();

  @override
  List<Object?> get props => [];
}

class LoadOpeningQuantitiesEvent extends OpeningQuantitiesEvent {
  const LoadOpeningQuantitiesEvent();
}

class AddOpeningQuantityEvent extends OpeningQuantitiesEvent {
  final OpeningQuantityEntity entity;
  const AddOpeningQuantityEvent(this.entity);

  @override
  List<Object?> get props => [entity];
}

class DeleteOpeningQuantityEvent extends OpeningQuantitiesEvent {
  final int id;
  const DeleteOpeningQuantityEvent(this.id);

  @override
  List<Object?> get props => [id];
}
