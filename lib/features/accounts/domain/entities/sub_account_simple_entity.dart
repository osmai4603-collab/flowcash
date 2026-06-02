import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';

class SubAccountSimpleEntity extends Entity {
  final int id;
  final String accountName;
  final String accountNumber;
  final SubAccountType accountType;
  final int mainAccountId;
  final double balance;
  final String currencyName;

  const SubAccountSimpleEntity({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.accountType,
    required this.mainAccountId,
    required this.balance,
    required this.currencyName,
  });

  @override
  List<Object?> get props => [
    id,
    accountName,
    accountNumber,
    accountType,
    mainAccountId,
    balance,
    currencyName,
  ];

  @override
  SubAccountSimpleEntity copyWith({
    int? id,
    String? accountName,
    String? accountNumber,
    SubAccountType? accountType,
    int? mainAccountId,
    double? balance,
    String? currencyName,
  }) {
    return SubAccountSimpleEntity(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      mainAccountId: mainAccountId ?? this.mainAccountId,
      balance: balance ?? this.balance,
      currencyName: currencyName ?? this.currencyName,
    );
  }
}
