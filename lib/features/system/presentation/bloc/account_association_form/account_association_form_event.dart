import 'package:equatable/equatable.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';

abstract class AccountAssociationFormEvent extends Equatable {
  const AccountAssociationFormEvent();

  @override
  List<Object?> get props => [];
}

class InitAccountAssociationForm extends AccountAssociationFormEvent {
  final PersonEntity? person;
  const InitAccountAssociationForm({this.person});

  @override
  List<Object?> get props => [person];
}

class ChangePersonTypeEvent extends AccountAssociationFormEvent {
  final PersonType personType;
  const ChangePersonTypeEvent(this.personType);

  @override
  List<Object?> get props => [personType];
}

class ChangePersonNameEvent extends AccountAssociationFormEvent {
  final String personName;
  const ChangePersonNameEvent(this.personName);

  @override
  List<Object?> get props => [personName];
}

class ChangePhoneNumberEvent extends AccountAssociationFormEvent {
  final String? phoneNumber;
  const ChangePhoneNumberEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class ChangeAddressEvent extends AccountAssociationFormEvent {
  final String? address;
  const ChangeAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class ChangeEmailEvent extends AccountAssociationFormEvent {
  final String? email;
  const ChangeEmailEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class ChangeReceivableAccountIdEvent extends AccountAssociationFormEvent {
  final int? receivableAccountId;
  const ChangeReceivableAccountIdEvent(this.receivableAccountId);

  @override
  List<Object?> get props => [receivableAccountId];
}

class ChangePayableAccountIdEvent extends AccountAssociationFormEvent {
  final int? payableAccountId;
  const ChangePayableAccountIdEvent(this.payableAccountId);

  @override
  List<Object?> get props => [payableAccountId];
}

class SaveAccountAssociationEvent extends AccountAssociationFormEvent {
  const SaveAccountAssociationEvent();
}
