import 'package:equatable/equatable.dart';

abstract class SalesReturnsPageEvent extends Equatable {
  const SalesReturnsPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesReturnsPageEvent extends SalesReturnsPageEvent {}

class RefreshSalesReturnsPageEvent extends SalesReturnsPageEvent {}

class SearchSalesReturnsPageEvent extends SalesReturnsPageEvent {
  final String query;

  const SearchSalesReturnsPageEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddSalesReturnDocumentEvent extends SalesReturnsPageEvent {}
