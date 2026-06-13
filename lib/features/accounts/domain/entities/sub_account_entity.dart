import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/core/entities/entity.dart';

class SubAccountEntity extends Entity {
  final int id;
  final int mainAccountId;
  final String accountName;
  final String accountNumber;
  final double incrementBalance;
  final double decrementBalance;
  final String currencyId;
  final double? balanceMax;
  final SubAccountType subAccountType;
  final DateTime createdAt;

  const SubAccountEntity({
    required this.id,
    required this.mainAccountId,
    this.accountName = '',
    required this.accountNumber,
    this.incrementBalance = 0.0,
    this.decrementBalance = 0.0,
    required this.currencyId,
    this.balanceMax,
    required this.subAccountType,
    required this.createdAt,
  });

  double get balance => incrementBalance - decrementBalance;

  @override
  List<Object?> get props => [
    id,
    mainAccountId,
    accountName,
    accountNumber,
    incrementBalance,
    decrementBalance,
    currencyId,
    balanceMax,
    subAccountType,
    createdAt,
  ];

  @override
  SubAccountEntity copyWith({
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
    return SubAccountEntity(
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
