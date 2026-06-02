import 'package:equatable/equatable.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';

enum AccountStatementStatus { initial, loading, success, failure }

class AccountStatementState extends Equatable {
  final AccountStatementStatus status;
  final SubAccountEntity? subAccount;
  final List<JournalItemEntity> items;
  final Map<int, JournalEntryEntity> entries;
  final double openingBalance;
  final String? errorMessage;
  final DateTime? startDate;
  final DateTime? endDate;

  const AccountStatementState({
    required this.status,
    this.subAccount,
    required this.items,
    required this.entries,
    required this.openingBalance,
    this.errorMessage,
    this.startDate,
    this.endDate,
  });

  factory AccountStatementState.initial() {
    return const AccountStatementState(
      status: AccountStatementStatus.initial,
      items: [],
      entries: {},
      openingBalance: 0.0,
    );
  }

  AccountStatementState copyWith({
    AccountStatementStatus? status,
    SubAccountEntity? subAccount,
    List<JournalItemEntity>? items,
    Map<int, JournalEntryEntity>? entries,
    double? openingBalance,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return AccountStatementState(
      status: status ?? this.status,
      subAccount: subAccount ?? this.subAccount,
      items: items ?? this.items,
      entries: entries ?? this.entries,
      openingBalance: openingBalance ?? this.openingBalance,
      errorMessage: errorMessage ?? this.errorMessage,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }

  @override
  List<Object?> get props => [
    status,
    subAccount,
    items,
    entries,
    openingBalance,
    errorMessage,
    startDate,
    endDate,
  ];
}
