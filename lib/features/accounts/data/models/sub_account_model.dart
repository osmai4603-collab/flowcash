import 'package:flowcash/core/tables/sub_accounts_table.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

final class SubAccountModel extends SubAccountEntity {
  const SubAccountModel({
    required super.id,
    required super.mainAccountId,
    super.accountName = '',
    required super.accountNumber,
    super.incrementBalance = 0.0,
    super.decrementBalance = 0.0,
    required super.currencyId,
    super.balanceMax,
    required super.subAccountType,
    required super.createdAt,
  });

  factory SubAccountModel.fromMap(Map<String, dynamic> map) {
    return SubAccountModel(
      id: map[SubAccountsTable().id] as int,
      mainAccountId: map[SubAccountsTable().mainAccountId] as int,
      accountName: (map[SubAccountsTable().accountName] as String?) ?? "",
      accountNumber: (map[SubAccountsTable().accountNumber] as String?) ?? "",
      incrementBalance: ((map[SubAccountsTable().incrementBalance]) as num?)?.toDouble() ?? 0.0,
      decrementBalance: ((map[SubAccountsTable().decrementBalance]) as num?)?.toDouble() ?? 0.0,
      currencyId: map[SubAccountsTable().currencyId] as String,
      balanceMax: ((map[SubAccountsTable().balanceMax]) as num?)?.toDouble(),
      subAccountType: SubAccountType.of(map[SubAccountsTable().subAccountType]),
      createdAt: DateTime.parse(map[SubAccountsTable().createdAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) SubAccountsTable().id: id,
      SubAccountsTable().mainAccountId: mainAccountId,
      SubAccountsTable().accountNumber: accountNumber,
      SubAccountsTable().accountName: accountName,
      SubAccountsTable().incrementBalance: incrementBalance,
      SubAccountsTable().decrementBalance: decrementBalance,
      SubAccountsTable().currencyId: currencyId,
      SubAccountsTable().balanceMax: balanceMax,
      SubAccountsTable().subAccountType: subAccountType.name,
      SubAccountsTable().createdAt: createdAt.toIso8601String(),
    };
  }

  @override
  SubAccountModel copyWith({
    int? id,
    int? mainAccountId,
    String? accountName,
    String? accountNumber,
    double? incrementBalance,
    double? decrementBalance,
    String? currencyId,
    double? balanceMax,
    SubAccountType? subAccountType,
    DateTime? createdAt,
  }) {
    return SubAccountModel(
      id: id ?? this.id,
      mainAccountId: mainAccountId ?? this.mainAccountId,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      incrementBalance: incrementBalance ?? this.incrementBalance,
      decrementBalance: decrementBalance ?? this.decrementBalance,
      currencyId: currencyId ?? this.currencyId,
      balanceMax: balanceMax ?? this.balanceMax,
      subAccountType: subAccountType ?? this.subAccountType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
