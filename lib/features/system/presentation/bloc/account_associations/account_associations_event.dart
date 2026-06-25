import 'package:equatable/equatable.dart';
import 'package:flowcash/core/entities/person_entity.dart';

abstract class AccountAssociationsEvent extends Equatable {
  const AccountAssociationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccountAssociationsEvent extends AccountAssociationsEvent {}

class SearchAccountAssociationsEvent extends AccountAssociationsEvent {
  final String query;
  const SearchAccountAssociationsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddAccountAssociationEvent extends AccountAssociationsEvent {
  final PersonEntity person;
  const AddAccountAssociationEvent(this.person);

  @override
  List<Object?> get props => [person];
}

class UpdateAccountAssociationEvent extends AccountAssociationsEvent {
  final PersonEntity person;
  const UpdateAccountAssociationEvent(this.person);

  @override
  List<Object?> get props => [person];
}

class DeleteAccountAssociationEvent extends AccountAssociationsEvent {
  final int id;
  const DeleteAccountAssociationEvent(this.id);

  @override
  List<Object?> get props => [id];
}
