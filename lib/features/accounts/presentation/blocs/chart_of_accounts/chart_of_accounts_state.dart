import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

enum ChartOfAccountsStatus { initial, loading, success, failure }

class ChartOfAccountsState extends Equatable {
  final ChartOfAccountsStatus status;
  final List<MainAccountEntity> mainAccounts;
  final List<SubAccountEntity> subAccounts;
  final MainAccountGroup? selectedGroup;
  final String? errorMessage;

  const ChartOfAccountsState({
    required this.status,
    required this.mainAccounts,
    required this.subAccounts,
    this.selectedGroup,
    this.errorMessage,
  });

  factory ChartOfAccountsState.initial() {
    return const ChartOfAccountsState(
      status: ChartOfAccountsStatus.initial,
      mainAccounts: [],
      subAccounts: [],
    );
  }

  ChartOfAccountsState copyWith({
    ChartOfAccountsStatus? status,
    List<MainAccountEntity>? mainAccounts,
    List<SubAccountEntity>? subAccounts,
    MainAccountGroup? selectedGroup,
    bool clearGroup = false,
    String? errorMessage,
  }) {
    return ChartOfAccountsState(
      status: status ?? this.status,
      mainAccounts: mainAccounts ?? this.mainAccounts,
      subAccounts: subAccounts ?? this.subAccounts,
      selectedGroup: clearGroup ? null : (selectedGroup ?? this.selectedGroup),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        mainAccounts,
        subAccounts,
        selectedGroup,
        errorMessage,
      ];
}
