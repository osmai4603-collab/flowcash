import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';

enum MainAccountFormStatus { initial, loading, success, failure }

class MainAccountFormState extends Equatable {
  final MainAccountFormStatus status;
  final MainAccountEntity? editingAccount;
  final String accountName;
  final String accountNumber;
  final MainAccountGroup? selectedGroup;
  final MainAccountType? selectedType;
  final CurrencyEntity? selectedCurrency;
  final List<CurrencyEntity> currencies;
  final String? errorMessage;
  final String? currencyErrorMessage;

  bool get canEnabledFields {
    return status != MainAccountFormStatus.loading;
  }

  const MainAccountFormState({
    required this.status,
    this.editingAccount,
    required this.accountName,
    required this.accountNumber,
    this.selectedGroup,
    this.selectedType,
    required this.selectedCurrency,
    required this.currencies,
    this.errorMessage,
    this.currencyErrorMessage,
  });

  factory MainAccountFormState.initial() {
    return const MainAccountFormState(
      status: MainAccountFormStatus.initial,
      accountName: '',
      accountNumber: '',
      selectedCurrency: null,
      currencies: [],
      currencyErrorMessage: null,
    );
  }

  MainAccountFormState copyWith({
    MainAccountFormStatus? status,
    MainAccountEntity? editingAccount,
    String? accountName,
    String? accountNumber,
    MainAccountGroup? selectedGroup,
    MainAccountType? selectedType,
    CurrencyEntity? selectedCurrency,
    List<CurrencyEntity>? currencies,
    String? errorMessage,
    String? currencyErrorMessage,
  }) {
    return MainAccountFormState(
      status: status ?? this.status,
      editingAccount: editingAccount ?? this.editingAccount,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      selectedType: selectedType ?? this.selectedType,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      currencies: currencies ?? this.currencies,
      errorMessage: errorMessage ?? this.errorMessage,
      currencyErrorMessage: currencyErrorMessage ?? this.currencyErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    editingAccount,
    accountName,
    accountNumber,
    selectedGroup,
    selectedType,
    selectedCurrency,
    currencies,
    errorMessage,
    currencyErrorMessage,
  ];
}
