import 'package:equatable/equatable.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_transaction_entity.dart';

abstract class FinancialTransactionsEvent extends Equatable {
  const FinancialTransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFinancialTransactionsEvent extends FinancialTransactionsEvent {}

class AddFinancialTransactionEvent extends FinancialTransactionsEvent {
  final FinancialTransactionEntity transaction;

  const AddFinancialTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateFinancialTransactionEvent extends FinancialTransactionsEvent {
  final FinancialTransactionEntity transaction;

  const UpdateFinancialTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteFinancialTransactionEvent extends FinancialTransactionsEvent {
  final int id;

  const DeleteFinancialTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectFinancialTransactionEvent extends FinancialTransactionsEvent {
  final FinancialTransactionEntity? transaction;

  const SelectFinancialTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
