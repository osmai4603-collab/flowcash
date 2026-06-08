import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';

class MainAccountEntity extends Entity {
  final int id;
  final String accountName;
  final String accountNumber;
  final String? currencyId;
  final double debitBalance;
  final double creditBalance;
  final MainAccountType mainAccountType;
  final int numbersCounter;

  const MainAccountEntity({
    required this.id,
    this.accountName = '',
    this.accountNumber = '',
    this.currencyId,
    this.debitBalance = 0.0,
    this.creditBalance = 0.0,
    required this.mainAccountType,
    this.numbersCounter = 1,
  });

  @override
  List<Object?> get props => [
    id,
    accountName,
    accountNumber,
    currencyId,
    debitBalance,
    creditBalance,
    mainAccountType,
    numbersCounter,
  ];

  double get balance {
    return debitBalance - creditBalance;
  }

  MainAccountEntity copyWith({
    int? id,
    String? accountName,
    String? accountNumber,
    String? currencyId,
    double? debitBalance,
    double? creditBalance,
    MainAccountType? mainAccountType,
    int? numbersCounter,
  }) {
    return MainAccountEntity(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      currencyId: currencyId ?? this.currencyId,
      debitBalance: debitBalance ?? this.debitBalance,
      creditBalance: creditBalance ?? this.creditBalance,
      mainAccountType: mainAccountType ?? this.mainAccountType,
      numbersCounter: numbersCounter ?? this.numbersCounter,
    );
  }
}
