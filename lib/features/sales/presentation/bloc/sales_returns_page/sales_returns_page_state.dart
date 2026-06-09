import 'package:equatable/equatable.dart';

class SalesReturnDocument extends Equatable {
  final int id;
  final String returnNumber;
  final String customerName;
  final double amount;
  final String status;
  final DateTime date;

  const SalesReturnDocument({
    required this.id,
    required this.returnNumber,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.date,
  });

  @override
  List<Object?> get props => [id, returnNumber, customerName, amount, status, date];
}

abstract class SalesReturnsPageState extends Equatable {
  const SalesReturnsPageState();

  @override
  List<Object?> get props => [];
}

class SalesReturnsPageInitial extends SalesReturnsPageState {}

class SalesReturnsPageLoadInProgress extends SalesReturnsPageState {}

class SalesReturnsPageLoadSuccess extends SalesReturnsPageState {
  final List<SalesReturnDocument> returns;
  final String query;

  const SalesReturnsPageLoadSuccess(this.returns, {this.query = ''});

  @override
  List<Object?> get props => [returns, query];
}

class SalesReturnsPageOperationFailure extends SalesReturnsPageState {
  final String message;

  const SalesReturnsPageOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
