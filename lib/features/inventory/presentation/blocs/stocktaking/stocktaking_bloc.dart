import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'stocktaking_event.dart';
import 'stocktaking_state.dart';

class StocktakingBloc extends Bloc<StocktakingEvent, StocktakingState> {
  final GetInventorysUseCase _getInventorys;
  final GetWarehousesUseCase _getWarehouses;

  StocktakingBloc({
    required GetInventorysUseCase getInventorys,
    required GetWarehousesUseCase getWarehouses,
  })  : _getInventorys = getInventorys,
        _getWarehouses = getWarehouses,
        super(const StocktakingState()) {
    on<LoadStocktakingEvent>(_onLoad);
    on<UpdateActualCountEvent>(_onUpdateActual);
  }

  Future<void> _onLoad(
    LoadStocktakingEvent event,
    Emitter<StocktakingState> emit,
  ) async {
    emit(state.toLoading());

    final iRes = await _getInventorys();
    final wRes = await _getWarehouses();

    iRes.fold(
      (f) => emit(state.toError(f.message)),
      (itemsList) {
        wRes.fold(
          (f) => emit(state.toError(f.message)),
          (warehousesList) {
            // Pre-populate actualCounts with book count values initially for comfort
            final Map<int, double> defaultCounts = {};
            for (var item in itemsList) {
              defaultCounts[item.categoryId] = item.countUnits;
            }

            emit(state.copyWith(
              status: StocktakingStatus.success,
              items: itemsList,
              warehouses: warehousesList,
              actualCounts: defaultCounts,
            ));
          },
        );
      },
    );
  }

  void _onUpdateActual(
    UpdateActualCountEvent event,
    Emitter<StocktakingState> emit,
  ) {
    emit(state.updateActualCount(event.categoryId, event.count));
  }
}
