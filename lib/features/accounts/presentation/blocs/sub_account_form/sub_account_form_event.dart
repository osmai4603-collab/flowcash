import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

sealed class SubAccountFormEvent extends Equatable {
  const SubAccountFormEvent();

  @override
  List<Object?> get props => [];
}

class InitSubAccountForm extends SubAccountFormEvent {
  final int mainAccountId;
  final SubAccountEntity? editingSubAccount;

  const InitSubAccountForm({
    required this.mainAccountId,
    this.editingSubAccount,
  });

  @override
  List<Object?> get props => [mainAccountId, editingSubAccount];
}

class SubAccountNameChanged extends SubAccountFormEvent {
  final String name;
  const SubAccountNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class SubAccountTypeChanged extends SubAccountFormEvent {
  final SubAccountType type;
  const SubAccountTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class SubAccountCurrencyChanged extends SubAccountFormEvent {
  final String currencyId;
  const SubAccountCurrencyChanged(this.currencyId);

  @override
  List<Object?> get props => [currencyId];
}

class SubAccountBalanceMaxChanged extends SubAccountFormEvent {
  final double? balanceMax;
  const SubAccountBalanceMaxChanged(this.balanceMax);

  @override
  List<Object?> get props => [balanceMax];
}

class SubmitSubAccountForm extends SubAccountFormEvent {
  const SubmitSubAccountForm();
}
