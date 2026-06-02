import 'app_enum.dart';

sealed class AccountStatus extends AppEnum {
  const AccountStatus();

  static const debtor = DebtorAccountStatus._();
  static const creditor = CreditorAccountStatus._();

  static const List<AccountStatus> values = [
    debtor,
    creditor,
  ];

  bool get isCreditor => false;
  bool get isDebtor => true;

  AccountStatus get not;

  static AccountStatus of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown AccountStatus: $name'),
    );
  }
}

final class DebtorAccountStatus extends AccountStatus {
  const DebtorAccountStatus._();

  @override
  String get name => 'debtor';

  @override
  int get index => 0;

  @override
  String displayName() => 'مدين';

  @override
  bool get isDebtor => true;
  
  @override
  AccountStatus get not => AccountStatus.creditor;
}

final class CreditorAccountStatus extends AccountStatus {
  const CreditorAccountStatus._();

  @override
  String get name => 'creditor';

  @override
  int get index => 1;

  @override
  String displayName() => 'دائن';

  @override
  bool get isCreditor => true;
  
  @override
  AccountStatus get not => AccountStatus.debtor;
}
