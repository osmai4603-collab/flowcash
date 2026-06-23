import 'package:equatable/equatable.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';

class SalesDocument extends Equatable {
  final int id;
  final String billHistory;
  final String customerName;
  final double amount;
  final String currencySymbol;
  final DateTime date;
  final bool isJournalPosted;
  final bool isInventoryPosted;
  final bool isCostGoodPosted;
  final BillEntity rawBill;

  const SalesDocument({
    required this.id,
    required this.billHistory,
    required this.customerName,
    required this.amount,
    required this.currencySymbol,
    required this.date,
    required this.isJournalPosted,
    required this.isInventoryPosted,
    required this.isCostGoodPosted,
    required this.rawBill,
  });

  @override
  List<Object?> get props => [
    id,
    billHistory,
    customerName,
    amount,
    currencySymbol,
    date,
    isJournalPosted,
    isInventoryPosted,
    isCostGoodPosted,
    rawBill,
  ];
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
