import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flutter/rendering.dart';

enum SubAccountFormStatus { initial, loading, success, failure }

class SubAccountFormState extends Equatable {
  final SubAccountFormStatus status;
  final SubAccountEntity? editingSubAccount;
  final int mainAccountId;
  final MainAccountEntity? parentMainAccount;
  final String accountName;
  final String accountNumber;
  final SubAccountType? selectedType;
  final CurrencyEntity? selectedCurrency;
  final List<CurrencyEntity> currencies;
  final double? balanceMax;
  final String? errorMessage;
  final String? currencyErrorMessage;
  final List<SubAccountType> subAccountTypes;

  const SubAccountFormState({
    required this.status,
    this.editingSubAccount,
    required this.mainAccountId,
    this.parentMainAccount,
    required this.accountName,
    required this.accountNumber,
    this.selectedType,
    this.selectedCurrency,
    this.currencies = const [],
    this.balanceMax,
    this.errorMessage,
    this.currencyErrorMessage,
    this.subAccountTypes = const [],
  });

  factory SubAccountFormState.initial(int mainAccountId) {
    return SubAccountFormState(
      status: SubAccountFormStatus.initial,
      mainAccountId: mainAccountId,
      accountName: '',
      accountNumber: '',
      currencies: const [],
      subAccountTypes: const [],
    );
  }

  SubAccountFormState copyWith({
    SubAccountFormStatus? status,
    SubAccountEntity? editingSubAccount,
    int? mainAccountId,
    MainAccountEntity? parentMainAccount,
    String? accountName,
    String? accountNumber,
    SubAccountType? selectedType,
    CurrencyEntity? selectedCurrency,
    List<CurrencyEntity>? currencies,
    double? balanceMax,
    bool clearBalanceMax = false,
    String? errorMessage,
    String? currencyErrorMessage,
    List<SubAccountType>? subAccountTypes,
  }) {
    final result = SubAccountFormState(
      status: status ?? this.status,
      editingSubAccount: editingSubAccount ?? this.editingSubAccount,
      mainAccountId: mainAccountId ?? this.mainAccountId,
      parentMainAccount: parentMainAccount ?? this.parentMainAccount,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      selectedType: selectedType ?? this.selectedType,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      currencies: currencies ?? this.currencies,
      balanceMax: clearBalanceMax ? null : (balanceMax ?? this.balanceMax),
      errorMessage: errorMessage ?? this.errorMessage,
      currencyErrorMessage: currencyErrorMessage ?? this.currencyErrorMessage,
      subAccountTypes: subAccountTypes ?? this.subAccountTypes,
    );
    debugPrint(toString());
    return result;
  }

  @override
  List<Object?> get props => [
    status,
    editingSubAccount,
    mainAccountId,
    parentMainAccount,
    accountName,
    accountNumber,
    selectedType,
    selectedCurrency,
    currencies,
    balanceMax,
    errorMessage,
    currencyErrorMessage,
    subAccountTypes,
  ];
}
