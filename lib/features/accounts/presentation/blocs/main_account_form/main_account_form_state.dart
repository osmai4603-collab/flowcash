import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';

enum MainAccountFormStatus { initial, loading, success, failure }

class MainAccountFormState extends Equatable {
  final MainAccountFormStatus status;
  final MainAccountEntity? editingAccount;
  final String accountName;
  final String accountNumber;
  final MainAccountGroup? selectedGroup;
  final MainAccountType? selectedType;
  final String selectedCurrencyId;
  final String? errorMessage;

  const MainAccountFormState({
    required this.status,
    this.editingAccount,
    required this.accountName,
    required this.accountNumber,
    this.selectedGroup,
    this.selectedType,
    required this.selectedCurrencyId,
    this.errorMessage,
  });

  factory MainAccountFormState.initial() {
    return const MainAccountFormState(
      status: MainAccountFormStatus.initial,
      accountName: '',
      accountNumber: '',
      selectedCurrencyId: '1', // Default to currency 1 (ريال يمني)
    );
  }

  MainAccountFormState copyWith({
    MainAccountFormStatus? status,
    MainAccountEntity? editingAccount,
    String? accountName,
    String? accountNumber,
    MainAccountGroup? selectedGroup,
    MainAccountType? selectedType,
    String? selectedCurrencyId,
    String? errorMessage,
  }) {
    return MainAccountFormState(
      status: status ?? this.status,
      editingAccount: editingAccount ?? this.editingAccount,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      selectedType: selectedType ?? this.selectedType,
      selectedCurrencyId: selectedCurrencyId ?? this.selectedCurrencyId,
      errorMessage: errorMessage ?? this.errorMessage,
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
    selectedCurrencyId,
    errorMessage,
  ];
}
