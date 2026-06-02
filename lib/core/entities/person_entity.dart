
import 'package:flowcash/core/enums/person_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';


class PersonEntity extends Entity {
  final int id;
  final String personName;
  final String? phoneNumber;
  final String? address;
  final String? email;
  final int? receivableAccountId;
  final int? payableAccountId;
  final PersonType personType;
  final DateTime? createdAt;

  const PersonEntity({
    required this.id,
    this.personName = '',
    this.phoneNumber = '',
    this.address = '',
    this.email,
    this.receivableAccountId,
    this.payableAccountId,
    required this.personType,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        personName,
        phoneNumber,
        address,
        email,
        receivableAccountId,
        payableAccountId,
        personType,
        createdAt,
      ];

  @override
  PersonEntity copyWith({
    int? id,
    String? personName,
    String? phoneNumber,
    String? address,
    String? email,
    int? receivableAccountId,
    int? payableAccountId,
    PersonType? personType,
    DateTime? createdAt,
  }) {
    return PersonEntity(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      email: email ?? this.email,
      receivableAccountId: receivableAccountId ?? this.receivableAccountId,
      payableAccountId: payableAccountId ?? this.payableAccountId,
      personType: personType ?? this.personType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}