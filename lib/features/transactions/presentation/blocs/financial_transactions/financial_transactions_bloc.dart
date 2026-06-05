import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/transactions/domain/usecases/financial_transaction_repository_usecases.dart';
import 'financial_transactions_event.dart';
import 'financial_transactions_state.dart';

class FinancialTransactionsBloc extends Bloc<FinancialTransactionsEvent, FinancialTransactionsState> {
  final GetFinancialTransactionsUseCase _getFinancialTransactionsUseCase;
  final InsertFinancialTransactionUseCase _insertFinancialTransactionUseCase;
  final UpdateFinancialTransactionUseCase _updateFinancialTransactionUseCase;
  final DeleteFinancialTransactionUseCase _deleteFinancialTransactionUseCase;

  FinancialTransactionsBloc({
    required GetFinancialTransactionsUseCase getFinancialTransactionsUseCase,
    required InsertFinancialTransactionUseCase insertFinancialTransactionUseCase,
    required UpdateFinancialTransactionUseCase updateFinancialTransactionUseCase,
    required DeleteFinancialTransactionUseCase deleteFinancialTransactionUseCase,
  })  : _getFinancialTransactionsUseCase = getFinancialTransactionsUseCase,
        _insertFinancialTransactionUseCase = insertFinancialTransactionUseCase,
        _updateFinancialTransactionUseCase = updateFinancialTransactionUseCase,
        _deleteFinancialTransactionUseCase = deleteFinancialTransactionUseCase,
        super(const FinancialTransactionsState()) {
    on<LoadFinancialTransactionsEvent>(_onLoadTransactions);
    on<AddFinancialTransactionEvent>(_onAddTransaction);
    on<UpdateFinancialTransactionEvent>(_onUpdateTransaction);
    on<DeleteFinancialTransactionEvent>(_onDeleteTransaction);
    on<SelectFinancialTransactionEvent>(_onSelectTransaction);
  }

  Future<void> _onLoadTransactions(LoadFinancialTransactionsEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _getFinancialTransactionsUseCase();
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (transactions) => emit(state.copyWith(
        transactions: transactions,
        status: FinancialTransactionsStatus.success,
      )),
    );
  }

  Future<void> _onAddTransaction(AddFinancialTransactionEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _insertFinancialTransactionUseCase(event.transaction);
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (newTransaction) => emit(state.addTransaction(newTransaction)),
    );
  }

  Future<void> _onUpdateTransaction(UpdateFinancialTransactionEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _updateFinancialTransactionUseCase(event.transaction);
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (updatedTransaction) => emit(state.updateTransaction(updatedTransaction)),
    );
  }

  Future<void> _onDeleteTransaction(DeleteFinancialTransactionEvent event, EmitFn emit) async {
    emit(state.toLoading());
    final result = await _deleteFinancialTransactionUseCase(event.id);
    result.fold(
      (failure) => emit(state.toError(failure.message)),
      (_) => emit(state.removeTransaction(event.id)),
    );
  }

  void _onSelectTransaction(SelectFinancialTransactionEvent event, EmitFn emit) {
    emit(state.copyWith(selectedTransaction: event.transaction));
  }
}

typedef EmitFn = Emitter<FinancialTransactionsState>;
