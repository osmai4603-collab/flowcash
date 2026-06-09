import 'package:equatable/equatable.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';

enum CustomerFormStatus { initial, ready, saving, saved, failure }

class CustomerFormState extends Equatable {
  final int id;
  final PersonType personType;
  final String personName;
  final String? phoneNumber;
  final String? address;
  final String? email;
  final int? receivableAccountId;
  final int? payableAccountId;
  final DateTime? createdAt;
  final CustomerFormStatus status;
  final String? messageError;

  const CustomerFormState({
    this.id = 0,
    this.personType = PersonType.client,
    this.personName = '',
    this.phoneNumber,
    this.address,
    this.email,
    this.receivableAccountId,
    this.payableAccountId,
    this.createdAt,
    this.status = CustomerFormStatus.initial,
    this.messageError,
  });

  CustomerFormState copyWith({
    int? id,
    PersonType? personType,
    String? personName,
    String? phoneNumber,
    String? address,
    String? email,
    int? receivableAccountId,
    int? payableAccountId,
    DateTime? createdAt,
    CustomerFormStatus? status,
    String? messageError,
  }) {
    return CustomerFormState(
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
      phoneNumber: phoneNumber?.trim(),
      address: address?.trim(),
      email: email?.trim(),
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
