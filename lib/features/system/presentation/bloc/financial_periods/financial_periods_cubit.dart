import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/core/usecases/accounting_period_repository_usecases.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';

part 'financial_periods_state.dart';
part 'financial_periods_event.dart';

class FinancialPeriodsBloc extends Bloc<FinancialPeriodsEvent, FinancialPeriodsState> {
  final GetAccountingPeriodsUseCase _getAccountingPeriodsUseCase;

  FinancialPeriodsBloc(this._getAccountingPeriodsUseCase)
      : super(const FinancialPeriodsInitial()) {
    on<LoadFinancialPeriodsEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadFinancialPeriodsEvent event,
    Emitter<FinancialPeriodsState> emit,
  ) async {
    emit(const FinancialPeriodsLoading());

    final result = await _getAccountingPeriodsUseCase.call();
    result.fold(
      (failure) => emit(FinancialPeriodsFailure(failure.message)),
      (items) => emit(FinancialPeriodsSuccess(items)),
    );
  }
}
