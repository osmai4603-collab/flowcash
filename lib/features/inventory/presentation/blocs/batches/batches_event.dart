import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';

abstract class BatchesEvent extends Equatable {
  const BatchesEvent();

  @override
  List<Object?> get props => [];
}

class LoadBatchesEvent extends BatchesEvent {
  const LoadBatchesEvent();
}

class AddBatchEvent extends BatchesEvent {
  final InventoryBatchEntity batch;
  const AddBatchEvent(this.batch);

  @override
  List<Object?> get props => [batch];
}

class UpdateBatchEvent extends BatchesEvent {
  final InventoryBatchEntity batch;
  const UpdateBatchEvent(this.batch);

  @override
  List<Object?> get props => [batch];
}

class DeleteBatchEvent extends BatchesEvent {
  final int id;
  const DeleteBatchEvent(this.id);

  @override
  List<Object?> get props => [id];
}
