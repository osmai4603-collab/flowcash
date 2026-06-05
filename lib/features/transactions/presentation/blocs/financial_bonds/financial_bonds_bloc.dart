import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/transactions/domain/usecases/financial_bond_repository_usecases.dart';
import 'financial_bonds_event.dart';
import 'financial_bonds_state.dart';

class FinancialBondsBloc extends Bloc<FinancialBondsEvent, FinancialBondsState> {
  final GetFinancialBondsUseCase _getFinancialBondsUseCase;
  final InsertFinancialBondUseCase _insertFinancialBondUseCase;
  final UpdateFinancialBondUseCase _updateFinancialBondUseCase;
  final DeleteFinancialBondUseCase _deleteFinancialBondUseCase;

  FinancialBondsBloc({
    required GetFinancialBondsUseCase getFinancialBondsUseCase,
    required InsertFinancialBondUseCase insertFinancialBondUseCase,
    required UpdateFinancialBondUseCase updateFinancialBondUseCase,
    required DeleteFinancialBondUseCase deleteFinancialBondUseCase,
  })  : _getFinancialBondsUseCase = getFinancialBondsUseCase,
        _insertFinancialBondUseCase = insertFinancialBondUseCase,
        _updateFinancialBondUseCase = updateFinancialBondUseCase,
        _deleteFinancialBondUseCase = deleteFinancialBondUseCase,
        super(const FinancialBondsState()) {
    on<LoadFinancialBondsEvent>(_onLoadBonds);
    on<AddFinancialBondEvent>(_onAddBond);
    on<UpdateFinancialBondEvent>(_onUpdateBond);
    on<DeleteFinancialBondEvent>(_onDeleteBond);
    on<SelectFinancialBondEvent>(_onSelectBond);
  }

  Future<void> _onLoadBonds(LoadFinancialBondsEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _getFinancialBondsUseCase();
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (bonds) => emit(state.copyWith(
        bonds: bonds,
        status: FinancialBondsStatus.success,
      )),
    );
  }

  Future<void> _onAddBond(AddFinancialBondEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _insertFinancialBondUseCase(event.bond);
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (newBond) => emit(state.addBond(newBond)),
    );
  }

  Future<void> _onUpdateBond(UpdateFinancialBondEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _updateFinancialBondUseCase(event.bond);
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (updatedBond) => emit(state.updateBond(updatedBond)),
    );
  }

  Future<void> _onDeleteBond(DeleteFinancialBondEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _deleteFinancialBondUseCase(event.id);
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (_) => emit(state.removeBond(event.id)),
    );
  }

  void _onSelectBond(SelectFinancialBondEvent event, EmitFn emit) {
    emit(state.copyWith(selectedBond: event.bond));
  }
}

typedef EmitFn = Emitter<FinancialBondsState>;
