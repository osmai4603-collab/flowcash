import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_batch_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_usecases.dart';
import 'batches_event.dart';
import 'batches_state.dart';

class BatchesBloc extends Bloc<BatchesEvent, BatchesState> {
  final GetInventoryBatchsUseCase _getInventoryBatchs;
  final InsertInventoryBatchUseCase _insertInventoryBatch;
  final UpdateInventoryBatchUseCase _updateInventoryBatch;
  final DeleteInventoryBatchUseCase _deleteInventoryBatch;
  final GetInventorysUseCase _getInventorys;

  BatchesBloc({
    required GetInventoryBatchsUseCase getInventoryBatchs,
    required InsertInventoryBatchUseCase insertInventoryBatch,
    required UpdateInventoryBatchUseCase updateInventoryBatch,
    required DeleteInventoryBatchUseCase deleteInventoryBatch,
    required GetInventorysUseCase getInventorys,
  })  : _getInventoryBatchs = getInventoryBatchs,
        _insertInventoryBatch = insertInventoryBatch,
        _updateInventoryBatch = updateInventoryBatch,
        _deleteInventoryBatch = deleteInventoryBatch,
        _getInventorys = getInventorys,
        super(const BatchesState()) {
    on<LoadBatchesEvent>(_onLoadBatches);
    on<AddBatchEvent>(_onAddBatch);
    on<UpdateBatchEvent>(_onUpdateBatch);
    on<DeleteBatchEvent>(_onDeleteBatch);
  }

  Future<void> _onLoadBatches(
    LoadBatchesEvent event,
    Emitter<BatchesState> emit,
  ) async {
    emit(state.toLoading());
    
    final batchesResult = await _getInventoryBatchs();
    final itemsResult = await _getInventorys();

    batchesResult.fold(
      (f) => emit(state.toError(f.message)),
      (batchesList) {
        itemsResult.fold(
          (f) => emit(state.toError(f.message)),
          (itemsList) {
            emit(state.copyWith(
              status: BatchesStatus.success,
              batches: batchesList,
              inventoryItems: itemsList,
            ));
          },
        );
      },
    );
  }

  Future<void> _onAddBatch(
    AddBatchEvent event,
    Emitter<BatchesState> emit,
  ) async {
    final result = await _insertInventoryBatch(event.batch);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (newBatch) => emit(state.addBatch(newBatch)),
    );
  }

  Future<void> _onUpdateBatch(
    UpdateBatchEvent event,
    Emitter<BatchesState> emit,
  ) async {
    final result = await _updateInventoryBatch(event.batch);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (updatedBatch) => emit(state.updateBatch(updatedBatch)),
    );
  }

  Future<void> _onDeleteBatch(
    DeleteBatchEvent event,
    Emitter<BatchesState> emit,
  ) async {
    final result = await _deleteInventoryBatch(event.id);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (_) => emit(state.removeBatch(event.id)),
    );
  }
}
