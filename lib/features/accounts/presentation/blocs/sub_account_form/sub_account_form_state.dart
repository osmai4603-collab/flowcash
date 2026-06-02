import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

enum SubAccountFormStatus { initial, loading, success, failure }

class SubAccountFormState extends Equatable {
  final SubAccountFormStatus status;
  final SubAccountEntity? editingSubAccount;
  final int mainAccountId;
  final MainAccountEntity? parentMainAccount;
  final String accountName;
  final String accountNumber;
  final SubAccountType? selectedType;
  final String selectedCurrencyId;
  final double? balanceMax;
  final String? errorMessage;

  const SubAccountFormState({
    required this.status,
    this.editingSubAccount,
    required this.mainAccountId,
    this.parentMainAccount,
    required this.accountName,
    required this.accountNumber,
    this.selectedType,
    required this.selectedCurrencyId,
    this.balanceMax,
    this.errorMessage,
  });

  factory SubAccountFormState.initial(int mainAccountId) {
    return SubAccountFormState(
      status: SubAccountFormStatus.initial,
      mainAccountId: mainAccountId,
      accountName: '',
      accountNumber: '',
      selectedCurrencyId: '1',
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
    String? selectedCurrencyId,
    double? balanceMax,
    bool clearBalanceMax = false,
    String? errorMessage,
  }) {
    return SubAccountFormState(
      status: status ?? this.status,
      editingSubAccount: editingSubAccount ?? this.editingSubAccount,
      mainAccountId: mainAccountId ?? this.mainAccountId,
      parentMainAccount: parentMainAccount ?? this.parentMainAccount,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      selectedType: selectedType ?? this.selectedType,
      selectedCurrencyId: selectedCurrencyId ?? this.selectedCurrencyId,
      balanceMax: clearBalanceMax ? null : (balanceMax ?? this.balanceMax),
      errorMessage: errorMessage ?? this.errorMessage,
    );
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
        selectedCurrencyId,
        balanceMax,
        errorMessage,
      ];
}
