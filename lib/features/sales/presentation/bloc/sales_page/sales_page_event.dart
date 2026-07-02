import 'package:equatable/equatable.dart';
import 'package:flowcash/features/sales/presentation/bloc/sales_page/sales_page_state.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/cost_good_bill_order_entity.dart';

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

class PostSalesDocumentToAccountingEvent extends SalesPageEvent {
  final SalesDocument doc;

  const PostSalesDocumentToAccountingEvent(this.doc);

  @override
  List<Object?> get props => [doc];
}

class PostSalesDocumentToInventoryEvent extends SalesPageEvent {
  final SalesDocument doc;

  const PostSalesDocumentToInventoryEvent(this.doc);

  @override
  List<Object?> get props => [doc];
}

class PostSalesDocumentToCostingEvent extends SalesPageEvent {
  final SalesDocument doc;
  final List<CostGoodBillOrderEntity>? overrideOrders;

  const PostSalesDocumentToCostingEvent(this.doc, {this.overrideOrders});

  @override
  List<Object?> get props => [doc, overrideOrders];
}
