import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';

class SalesDocument extends Equatable {
  final int billId;
  final String customerName;
  final double totalAmount;
  final String currencyId;
  final DateTime createdAt;
  final int? journalStatusId;
  final int? costOfGoodId;
  final int? inventoryTransactionId;
  final InvoiceType billType;
  final bool isCash;
  final int billNumber;
  final BillEntity rawBill;

  const SalesDocument({
    required this.billId,
    required this.customerName,
    required this.totalAmount,
    required this.currencyId,
    required this.createdAt,
    this.journalStatusId,
    this.costOfGoodId,
    this.inventoryTransactionId,
    required this.billType,
    required this.isCash,
    required this.billNumber,
    required this.rawBill,
  });

  String get billnumberFormat => billNumber.toString().padLeft(5, '0');

  String get billHistory =>
      '${billType.displayName()} ${isCash ? 'نقدا' : 'آجل'} رقم $billnumberFormat';

  bool get isJournalPosted => journalStatusId != null;
  bool get isInventoryPosted => inventoryTransactionId != null;
  bool get isCostGoodPosted => costOfGoodId != null;

  @override
  List<Object?> get props => [
    billId,
    customerName,
    totalAmount,
    currencyId,
    createdAt,
    journalStatusId,
    costOfGoodId,
    inventoryTransactionId,
    billType,
    isCash,
    billNumber,
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

class SalesPageOperationSuccess extends SalesPageState {
  final String message;

  const SalesPageOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
