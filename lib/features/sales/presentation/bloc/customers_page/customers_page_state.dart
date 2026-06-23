import 'package:equatable/equatable.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

abstract class CustomersPageState extends Equatable {
  const CustomersPageState();

  @override
  List<Object?> get props => [];
}

class CustomersPageInitial extends CustomersPageState {}

class CustomersPageLoadInProgress extends CustomersPageState {}

class CustomersPageLoadSuccess extends CustomersPageState {
  final List<PersonEntity> persons;
  final List<SubAccountEntity> subAccounts;
  final String query;

  const CustomersPageLoadSuccess({
    required this.persons,
    required this.subAccounts,
    this.query = '',
  });

  @override
  List<Object?> get props => [persons, subAccounts, query];
}

class CustomersPageOperationFailure extends CustomersPageState {
  final String message;

  const CustomersPageOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
