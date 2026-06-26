import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_history.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_history_usecases.dart';

part 'inventory_histories_event.dart';
part 'inventory_histories_state.dart';

class InventoryHistoriesBloc
    extends Bloc<InventoryHistoriesEvent, InventoryHistoriesState> {
  final GetInventoryHistoriesUseCase _getHistories;

  InventoryHistoriesBloc({
    required GetInventoryHistoriesUseCase getHistories,
  }) : _getHistories = getHistories,
       super(InventoryHistoriesInitial()) {
    on<LoadInventoryHistories>(_onLoadInventoryHistories);
  }

  Future<void> _onLoadInventoryHistories(
    LoadInventoryHistories event,
    Emitter<InventoryHistoriesState> emit,
  ) async {
    emit(InventoryHistoriesLoading());
    final result = await _getHistories();
    result.fold(
      (failure) => emit(InventoryHistoriesError(failure.message)),
      (histories) => emit(InventoryHistoriesLoaded(histories)),
    );
  }
}
