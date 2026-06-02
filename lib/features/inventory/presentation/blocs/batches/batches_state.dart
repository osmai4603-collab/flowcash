import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';

enum BatchesStatus { initial, loading, success, error }

class BatchesState extends Equatable {
  final List<InventoryBatchEntity> batches;
  final List<InventoryEntity> inventoryItems;
  final BatchesStatus status;
  final String? errorMessage;
  final InventoryBatchEntity? selectedBatch;

  const BatchesState({
    this.batches = const [],
    this.inventoryItems = const [],
    this.status = BatchesStatus.initial,
    this.errorMessage,
    this.selectedBatch,
  });

  BatchesState copyWith({
    List<InventoryBatchEntity>? batches,
    List<InventoryEntity>? inventoryItems,
    BatchesStatus? status,
    String? errorMessage,
    InventoryBatchEntity? selectedBatch,
  }) {
    return BatchesState(
      batches: batches ?? this.batches,
      inventoryItems: inventoryItems ?? this.inventoryItems,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedBatch: selectedBatch ?? this.selectedBatch,
    );
  }

  BatchesState addBatch(InventoryBatchEntity batch) {
    return copyWith(
      batches: [batch, ...batches],
      status: BatchesStatus.success,
    );
  }

  BatchesState updateBatch(InventoryBatchEntity batch) {
    final updated = batches.map((b) => b.id == batch.id ? batch : b).toList();
    return copyWith(
      batches: updated,
      selectedBatch: selectedBatch?.id == batch.id ? batch : selectedBatch,
      status: BatchesStatus.success,
    );
  }

  BatchesState removeBatch(int id) {
    final updated = batches.where((b) => b.id != id).toList();
    return copyWith(
      batches: updated,
      selectedBatch: selectedBatch?.id == id ? null : selectedBatch,
      status: BatchesStatus.success,
    );
  }

  BatchesState toError(String message) {
    return copyWith(
      status: BatchesStatus.error,
      errorMessage: message,
    );
  }

  BatchesState toLoading() {
    return copyWith(
      status: BatchesStatus.loading,
    );
  }

  @override
  List<Object?> get props => [batches, inventoryItems, status, errorMessage, selectedBatch];
}
