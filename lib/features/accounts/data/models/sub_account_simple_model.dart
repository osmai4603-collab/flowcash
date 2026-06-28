import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';

final class SubAccountSimpleModel extends SubAccountSimpleEntity {
  const SubAccountSimpleModel({
    required super.id,
    required super.accountName,
    required super.accountNumber,
    required super.accountType,
    required super.mainAccountId,
    required super.balance,
    required super.currencyName,
  });

  factory SubAccountSimpleModel.fromMap(Map<String, dynamic> map) {
    return SubAccountSimpleModel(
      id: map[SubAccountsTable().id] as int,
      accountName: (map[SubAccountsTable().accountName] as String?) ?? "",
      accountNumber: (map[SubAccountsTable().accountNumber] as String?) ?? "",
      accountType: SubAccountType.of(map[SubAccountsTable().subAccountType]),
      mainAccountId: map[SubAccountsTable().mainAccountId] as int,
      balance: ((map[SubAccountsTable().incrementBalance] ?? 0.0) as num).toDouble() -
          ((map[SubAccountsTable().decrementBalance] ?? 0.0) as num).toDouble(),
      currencyName: (map[SubAccountsTable().currencyId] as String?) ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) SubAccountsTable().id: id,
      SubAccountsTable().accountName: accountName,
      SubAccountsTable().accountNumber: accountNumber,
      SubAccountsTable().subAccountType: accountType.name,
      SubAccountsTable().mainAccountId: mainAccountId,
      SubAccountsTable().currencyId: currencyName,
    };
  }

  @override
  SubAccountSimpleModel copyWith({
    int? id,
    String? accountName,
    String? accountNumber,
    SubAccountType? accountType,
    int? mainAccountId,
    double? balance,
    String? currencyName,
  }) {
    return SubAccountSimpleModel(
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
