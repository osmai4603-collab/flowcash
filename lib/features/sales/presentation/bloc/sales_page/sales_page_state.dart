import 'package:equatable/equatable.dart';

class SalesDocument extends Equatable {
  final int id;
  final String invoiceNumber;
  final String customerName;
  final double amount;
  final String status;
  final DateTime date;

  const SalesDocument({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.date,
  });

  @override
  List<Object?> get props => [id, invoiceNumber, customerName, amount, status, date];
}

abstract class SalesPageState extends Equatable {
  const SalesPageState();

  @override
  List<Object?> get props => [];
}

class SalesPageInitial extends SalesPageState {}

class SalesPageLoadInProgress extends SalesPageState {}

class SalesPageLoadSuccess extends SalesPageState {
  final List<SalesDocument> sales;
  final String query;

  const SalesPageLoadSuccess(this.sales, {this.query = ''});

  @override
  List<Object?> get props => [sales, query];
}

class SalesPageOperationFailure extends SalesPageState {
  final String message;

  const SalesPageOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
