import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';

sealed class ChartOfAccountsEvent extends Equatable {
  const ChartOfAccountsEvent();

  @override
  List<Object?> get props => [];
}

class LoadChartOfAccounts extends ChartOfAccountsEvent {
  const LoadChartOfAccounts();
}

class FilterChartOfAccounts extends ChartOfAccountsEvent {
  final MainAccountGroup? group;
  const FilterChartOfAccounts(this.group);

  @override
  List<Object?> get props => [group];
}

class DeleteMainAccount extends ChartOfAccountsEvent {
  final int id;
  const DeleteMainAccount(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteSubAccount extends ChartOfAccountsEvent {
  final int id;
  const DeleteSubAccount(this.id);

  @override
  List<Object?> get props => [id];
}
