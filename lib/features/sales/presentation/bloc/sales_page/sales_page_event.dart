import 'package:equatable/equatable.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';

abstract class SalesPageEvent extends Equatable {
  const SalesPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesPageEvent extends SalesPageEvent {}

class RefreshSalesPageEvent extends SalesPageEvent {}

class SearchSalesPageEvent extends SalesPageEvent {
  final String query;

  const SearchSalesPageEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddSalesDocumentEvent extends SalesPageEvent {
  final BillEntity bill;

  const AddSalesDocumentEvent(this.bill);

  @override
  List<Object?> get props => [bill];
}

class UpdateSalesDocumentEvent extends SalesPageEvent {
  final BillEntity bill;

  const UpdateSalesDocumentEvent(this.bill);

  @override
  List<Object?> get props => [bill];
}

class DeleteSalesDocumentEvent extends SalesPageEvent {
  final int billId;

  const DeleteSalesDocumentEvent(this.billId);

  @override
  List<Object?> get props => [billId];
}
