import 'package:flowcash/core/tables/main_accounts_table.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';

final class MainAccountModel extends MainAccountEntity {
  const MainAccountModel({
    required super.id,
    super.accountName = '',
    super.accountNumber = '',
    super.currencyId,
    super.debitBalance = 0.0,
    super.creditBalance = 0.0,
    required super.mainAccountType,
    super.numbersCounter = 1,
  });

  factory MainAccountModel.fromMap(Map<String, dynamic> map) {
    return MainAccountModel(
      id: map[MainAccountsTable.id] as int,
      accountName: (map[MainAccountsTable.accountName] as String?) ?? "",
      accountNumber: (map[MainAccountsTable.accountNumber] as String?) ?? "",
      currencyId: map[MainAccountsTable.currencyId] as String?,
      debitBalance: ((map[MainAccountsTable.debitBalance]) as num?)?.toDouble() ?? 0.0,
      creditBalance: ((map[MainAccountsTable.creditBalance]) as num?)?.toDouble() ?? 0.0,
      mainAccountType: MainAccountType.of(map[MainAccountsTable.mainAccountType]),
      numbersCounter: (map[MainAccountsTable.numbersCounter] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) MainAccountsTable.id: id,
      MainAccountsTable.accountName: accountName,
      MainAccountsTable.accountNumber: accountNumber,
      MainAccountsTable.currencyId: currencyId,
      MainAccountsTable.debitBalance: debitBalance,
      MainAccountsTable.creditBalance: creditBalance,
      MainAccountsTable.mainAccountType: mainAccountType.name,
      MainAccountsTable.numbersCounter: numbersCounter,
    };
  }

  @override
  MainAccountModel copyWith({
    int? id,
    String? accountName,
    String? accountNumber,
    String? currencyId,
    double? debitBalance,
    double? creditBalance,
    MainAccountType? mainAccountType,
    int? numbersCounter,
  }) {
    return MainAccountModel(
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
