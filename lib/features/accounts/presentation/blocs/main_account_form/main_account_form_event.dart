import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';

sealed class MainAccountFormEvent extends Equatable {
  const MainAccountFormEvent();

  @override
  List<Object?> get props => [];
}

class InitMainAccountForm extends MainAccountFormEvent {
  final MainAccountEntity? editingAccount;
  const InitMainAccountForm({this.editingAccount});

  @override
  List<Object?> get props => [editingAccount];
}

class MainAccountNameChanged extends MainAccountFormEvent {
  final String name;
  const MainAccountNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class MainAccountGroupChanged extends MainAccountFormEvent {
  final MainAccountGroup group;
  const MainAccountGroupChanged(this.group);

  @override
  List<Object?> get props => [group];
}

class MainAccountTypeChanged extends MainAccountFormEvent {
  final MainAccountType type;
  const MainAccountTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class MainAccountCurrencyChanged extends MainAccountFormEvent {
  final String currencyId;
  const MainAccountCurrencyChanged(this.currencyId);

  @override
  List<Object?> get props => [currencyId];
}

class SubmitMainAccountForm extends MainAccountFormEvent {
  const SubmitMainAccountForm();
}
