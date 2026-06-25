import 'package:equatable/equatable.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

abstract class AccountAssociationsState extends Equatable {
  const AccountAssociationsState();

  @override
  List<Object?> get props => [];
}

class AccountAssociationsInitial extends AccountAssociationsState {}

class AccountAssociationsLoadInProgress extends AccountAssociationsState {}

class AccountAssociationsLoadSuccess extends AccountAssociationsState {
  final List<PersonEntity> persons;
  final List<SubAccountEntity> subAccounts;
  final String query;

  const AccountAssociationsLoadSuccess({
    required this.persons,
    required this.subAccounts,
    this.query = '',
  });

  @override
  List<Object?> get props => [persons, subAccounts, query];
}

class AccountAssociationsOperationFailure extends AccountAssociationsState {
  final String message;
  const AccountAssociationsOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
