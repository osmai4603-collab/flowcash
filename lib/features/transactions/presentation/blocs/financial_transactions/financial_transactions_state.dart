import 'package:equatable/equatable.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_transaction_entity.dart';

enum FinancialTransactionsStatus { initial, loading, success, error }

class FinancialTransactionsState extends Equatable {
  final List<FinancialTransactionEntity> transactions;
  final FinancialTransactionsStatus status;
  final String? errorMessage;
  final FinancialTransactionEntity? selectedTransaction;

  const FinancialTransactionsState({
    this.transactions = const [],
    this.status = FinancialTransactionsStatus.initial,
    this.errorMessage,
    this.selectedTransaction,
  });

  FinancialTransactionsState copyWith({
    List<FinancialTransactionEntity>? transactions,
    FinancialTransactionsStatus? status,
    String? errorMessage,
    FinancialTransactionEntity? selectedTransaction,
  }) {
    return FinancialTransactionsState(
      transactions: transactions ?? this.transactions,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedTransaction: selectedTransaction ?? this.selectedTransaction,
    );
  }

  FinancialTransactionsState addTransaction(FinancialTransactionEntity transaction) {
    return copyWith(
      transactions: [transaction, ...transactions],
      status: FinancialTransactionsStatus.success,
    );
  }

  FinancialTransactionsState updateTransaction(FinancialTransactionEntity transaction) {
    final updatedList = transactions.map((t) => t.id == transaction.id ? transaction : t).toList();
    return copyWith(
      transactions: updatedList,
      selectedTransaction: selectedTransaction?.id == transaction.id ? transaction : selectedTransaction,
      status: FinancialTransactionsStatus.success,
    );
  }

  FinancialTransactionsState removeTransaction(int id) {
    final updatedList = transactions.where((t) => t.id != id).toList();
    return copyWith(
      transactions: updatedList,
      selectedTransaction: selectedTransaction?.id == id ? null : selectedTransaction,
      status: FinancialTransactionsStatus.success,
    );
  }

  FinancialTransactionsState toError(String message) {
    return copyWith(
      status: FinancialTransactionsStatus.error,
      errorMessage: message,
    );
  }

  FinancialTransactionsState toLoading() {
    return copyWith(
      status: FinancialTransactionsStatus.loading,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        status,
        errorMessage,
        selectedTransaction,
      ];
}
