import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';

class MainAccountEntity extends Entity {
  final int id;
  final String accountName;
  final String accountNumber;
  final String imagePath;
  final String? currencyId;
  final double incrementsBalance;
  final double decrementsBalance;
  final MainAccountType mainAccountType;
  final int numbersCounter;


  const MainAccountEntity({
    required this.id,
    this.accountName = '',
    this.accountNumber = '',
    this.imagePath = '',
    this.currencyId,
    this.incrementsBalance = 0.0,
    this.decrementsBalance = 0.0,
    required this.mainAccountType,
    this.numbersCounter = 1,
  });

  @override
  List<Object?> get props => [
        id,
        accountName,
        accountNumber,
        imagePath,
        currencyId,
        incrementsBalance,
        decrementsBalance,
        mainAccountType,
        numbersCounter,
      ];

  double get balance {
    return incrementsBalance - decrementsBalance;
  }

  MainAccountEntity copyWith({
    int? id,
    String? accountName,
    String? accountNumber,
    String? imagePath,
    String? currencyId,
    double? incrementsBalance,
    double? decrementsBalance,
    MainAccountType? mainAccountType,
    int? numbersCounter,
  }) {
    return MainAccountEntity(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      imagePath: imagePath ?? this.imagePath,
      currencyId: currencyId ?? this.currencyId,
      incrementsBalance: incrementsBalance ?? this.incrementsBalance,
      decrementsBalance: decrementsBalance ?? this.decrementsBalance,
      mainAccountType: mainAccountType ?? this.mainAccountType,
      numbersCounter: numbersCounter ?? this.numbersCounter,
    );
  }
}
