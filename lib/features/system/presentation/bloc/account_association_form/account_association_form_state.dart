import 'package:equatable/equatable.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';

enum AccountAssociationFormStatus { initial, ready, saving, saved, failure }

class AccountAssociationFormState extends Equatable {
  final int id;
  final PersonType personType;
  final String personName;
  final String? phoneNumber;
  final String? address;
  final String? email;
  final int? receivableAccountId;
  final int? payableAccountId;
  final DateTime? createdAt;
  final AccountAssociationFormStatus status;
  final String? messageError;

  const AccountAssociationFormState({
    this.id = 0,
    this.personType = PersonType.client,
    this.personName = '',
    this.phoneNumber,
    this.address,
    this.email,
    this.receivableAccountId,
    this.payableAccountId,
    this.createdAt,
    this.status = AccountAssociationFormStatus.initial,
    this.messageError,
  });

  AccountAssociationFormState copyWith({
    int? id,
    PersonType? personType,
    String? personName,
    String? phoneNumber,
    String? address,
    String? email,
    int? receivableAccountId,
    int? payableAccountId,
    DateTime? createdAt,
    AccountAssociationFormStatus? status,
    String? messageError,
  }) {
    return AccountAssociationFormState(
      id: id ?? this.id,
      personType: personType ?? this.personType,
      personName: personName ?? this.personName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      email: email ?? this.email,
      receivableAccountId: receivableAccountId ?? this.receivableAccountId,
      payableAccountId: payableAccountId ?? this.payableAccountId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      messageError: messageError ?? this.messageError,
    );
  }

  PersonEntity toEntity() {
    return PersonEntity(
      id: id,
      personName: personName.trim(),
      phoneNumber: personType.isPerson ? phoneNumber?.trim() : null,
      address: personType.isPerson ? address?.trim() : null,
      email: personType.isPerson ? email?.trim() : null,
      receivableAccountId: receivableAccountId,
      payableAccountId: payableAccountId,
      personType: personType,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        personType,
        personName,
        phoneNumber,
        address,
        email,
        receivableAccountId,
        payableAccountId,
        createdAt,
        status,
        messageError,
      ];
}
