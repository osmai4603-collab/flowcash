import 'app_enum.dart';

sealed class JournalStatus extends AppEnum {
  const JournalStatus();

  static const debit = DebitJournalStatus._();
  static const credit = CreditJournalStatus._();

  static const List<JournalStatus> values = [debit, credit];

  static JournalStatus of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown JournalStatus: $name'),
    );
  }
}

final class DebitJournalStatus extends JournalStatus {
  const DebitJournalStatus._();

  @override
  String get name => 'debit';

  @override
  int get index => 0;

  @override
  String displayName() => 'مدين';
}

final class CreditJournalStatus extends JournalStatus {
  const CreditJournalStatus._();

  @override
  String get name => 'credit';

  @override
  int get index => 1;

  @override
  String displayName() => 'دائن';
}
