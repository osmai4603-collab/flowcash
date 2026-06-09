import 'package:equatable/equatable.dart';
import 'package:flowcash/core/entities/person_entity.dart';

abstract class CustomerFormEvent extends Equatable {
  const CustomerFormEvent();

  @override
  List<Object?> get props => [];
}

class InitCustomerForm extends CustomerFormEvent {
  final PersonEntity? person;
  const InitCustomerForm([this.person]);

  @override
  List<Object?> get props => [person];
}

class ChangePersonNameEvent extends CustomerFormEvent {
  final String personName;
  const ChangePersonNameEvent(this.personName);

  @override
  List<Object?> get props => [personName];
}

class ChangePhoneNumberEvent extends CustomerFormEvent {
  final String? phoneNumber;
  const ChangePhoneNumberEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class ChangeAddressEvent extends CustomerFormEvent {
  final String? address;
  const ChangeAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class ChangeEmailEvent extends CustomerFormEvent {
  final String? email;
  const ChangeEmailEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class ChangeReceivableAccountIdEvent extends CustomerFormEvent {
  final int? receivableAccountId;
  const ChangeReceivableAccountIdEvent(this.receivableAccountId);

  @override
  List<Object?> get props => [receivableAccountId];
}

class ChangePayableAccountIdEvent extends CustomerFormEvent {
  final int? payableAccountId;
  const ChangePayableAccountIdEvent(this.payableAccountId);

  @override
  List<Object?> get props => [payableAccountId];
}

class SaveCustomerEvent extends CustomerFormEvent {
  const SaveCustomerEvent();

  @override
  List<Object?> get props => [];
}
