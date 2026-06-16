import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';

sealed class MainAccountFormEvent extends Equatable {
  const MainAccountFormEvent();

  @override
  List<Object?> get props => [];
}

class InitMainAccountForm extends MainAccountFormEvent {
  final MainAccountEntity? editingAccount;
  final MainAccountGroup group;
  const InitMainAccountForm({this.editingAccount, required this.group});

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
  final CurrencyEntity currency;
  const MainAccountCurrencyChanged(this.currency);

  @override
  List<Object?> get props => [currency];
}

class SubmitMainAccountForm extends MainAccountFormEvent {
  const SubmitMainAccountForm();
}
