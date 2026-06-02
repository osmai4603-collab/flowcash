import 'package:equatable/equatable.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

enum TrialBalanceStatus { initial, loading, success, failure }

class TrialBalanceState extends Equatable {
  final TrialBalanceStatus status;
  final List<MainAccountEntity> mainAccounts;
  final List<SubAccountEntity> subAccounts;
  final Map<int, Map<String, double>>
  subaccountBalances; // Map of subAccountId -> {'debit': value, 'credit': value}
  final String? errorMessage;
  final DateTime? startDate;
  final DateTime? endDate;

  const TrialBalanceState({
    required this.status,
    required this.mainAccounts,
    required this.subAccounts,
    required this.subaccountBalances,
    this.errorMessage,
    this.startDate,
    this.endDate,
  });

  factory TrialBalanceState.initial() {
    return const TrialBalanceState(
      status: TrialBalanceStatus.initial,
      mainAccounts: [],
      subAccounts: [],
      subaccountBalances: {},
    );
  }

  TrialBalanceState copyWith({
    TrialBalanceStatus? status,
    List<MainAccountEntity>? mainAccounts,
    List<SubAccountEntity>? subAccounts,
    Map<int, Map<String, double>>? subaccountBalances,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return TrialBalanceState(
      status: status ?? this.status,
      mainAccounts: mainAccounts ?? this.mainAccounts,
      subAccounts: subAccounts ?? this.subAccounts,
      subaccountBalances: subaccountBalances ?? this.subaccountBalances,
      errorMessage: errorMessage ?? this.errorMessage,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }

  @override
  List<Object?> get props => [
    status,
    mainAccounts,
    subAccounts,
    subaccountBalances,
    errorMessage,
    startDate,
    endDate,
  ];
}
