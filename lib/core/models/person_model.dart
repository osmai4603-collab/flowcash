import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';
import 'package:flowcash/core/tables/persons_table.dart';

final class PersonModel extends PersonEntity {
  const PersonModel({
    required super.id,
    super.personName = '',
    super.phoneNumber = '',
    super.address = '',
    super.email,
    super.receivableAccountId,
    super.payableAccountId,
    required super.personType,
    super.createdAt,
  });

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map[PersonsTable().id] as int,
      personName: map[PersonsTable().personName] as String? ?? '',
      phoneNumber: map[PersonsTable().phoneNumber] as String? ?? '',
      address: map[PersonsTable().address] as String? ?? '',
      email: map[PersonsTable().email] as String?,
      receivableAccountId: map[PersonsTable().receivableAccountId] as int?,
      payableAccountId: map[PersonsTable().payableAccountId] as int?,
      personType: PersonType.of(
        map[PersonsTable().personType] as String? ?? 'customer',
      ),
      createdAt: map[PersonsTable().createdAt] != null
          ? DateTime.tryParse(map[PersonsTable().createdAt] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      PersonsTable().id: id,
      PersonsTable().personName: personName,
      PersonsTable().phoneNumber: phoneNumber,
      PersonsTable().address: address,
      PersonsTable().email: email,
      PersonsTable().receivableAccountId: receivableAccountId,
      PersonsTable().payableAccountId: payableAccountId,
      PersonsTable().personType: personType.name,
      PersonsTable().createdAt: createdAt?.toIso8601String(),
    };
  }

  @override
  PersonModel copyWith({
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
    return PersonModel(
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
