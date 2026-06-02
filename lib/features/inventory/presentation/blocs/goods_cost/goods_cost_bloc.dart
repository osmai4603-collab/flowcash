import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/usecases/goods_cost_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'goods_cost_event.dart';
import 'goods_cost_state.dart';

class GoodsCostBloc extends Bloc<GoodsCostEvent, GoodsCostState> {
  final GetGoodsCostsUseCase _getGoodsCosts;
  final InsertGoodsCostUseCase _insertGoodsCost;
  final DeleteGoodsCostUseCase _deleteGoodsCost;
  final GetWarehousesUseCase _getWarehouses;

  GoodsCostBloc({
    required GetGoodsCostsUseCase getGoodsCosts,
    required InsertGoodsCostUseCase insertGoodsCost,
    required DeleteGoodsCostUseCase deleteGoodsCost,
    required GetWarehousesUseCase getWarehouses,
  })  : _getGoodsCosts = getGoodsCosts,
        _insertGoodsCost = insertGoodsCost,
        _deleteGoodsCost = deleteGoodsCost,
        _getWarehouses = getWarehouses,
        super(const GoodsCostState()) {
    on<LoadGoodsCostEvent>(_onLoad);
    on<AddGoodsCostEvent>(_onAdd);
    on<DeleteGoodsCostEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadGoodsCostEvent event,
    Emitter<GoodsCostState> emit,
  ) async {
    emit(state.toLoading());

    final cRes = await _getGoodsCosts();
    final wRes = await _getWarehouses();

    cRes.fold(
      (f) => emit(state.toError(f.message)),
      (costsList) {
        wRes.fold(
          (f) => emit(state.toError(f.message)),
          (warehousesList) {
            emit(state.copyWith(
              status: GoodsCostStatus.success,
              costs: costsList,
              warehouses: warehousesList,
            ));
          },
        );
      },
    );
  }

  Future<void> _onAdd(
    AddGoodsCostEvent event,
    Emitter<GoodsCostState> emit,
  ) async {
    final result = await _insertGoodsCost(event.cost);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (newItem) => emit(state.addCost(newItem)),
    );
  }

  Future<void> _onDelete(
    DeleteGoodsCostEvent event,
    Emitter<GoodsCostState> emit,
  ) async {
    final result = await _deleteGoodsCost(event.id);
    result.fold(
      (f) => emit(state.toError(f.message)),
      (_) => emit(state.removeCost(event.id)),
    );
  }
}
