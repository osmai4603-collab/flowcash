import 'package:equatable/equatable.dart';
import 'package:flowcash/core/entities/person_entity.dart';

abstract class CustomersPageEvent extends Equatable {
  const CustomersPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersPageEvent extends CustomersPageEvent {}

class SearchCustomersPageEvent extends CustomersPageEvent {
  final String query;

  const SearchCustomersPageEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddCustomerEvent extends CustomersPageEvent {
  final PersonEntity person;

  const AddCustomerEvent(this.person);

  @override
  List<Object?> get props => [person];
}
