import 'app_enum.dart';

sealed class JournalStatus extends AppEnum {
  const JournalStatus();

  static const increment = DebitJournalStatus._();
  static const decrement = CreditJournalStatus._();

  static const List<JournalStatus> values = [increment, decrement];

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
  String get name => 'increment';

  @override
  int get index => 0;

  @override
  String displayName() => 'مدين';
}

final class CreditJournalStatus extends JournalStatus {
  const CreditJournalStatus._();

  @override
  String get name => 'decrement';

  @override
  int get index => 1;

  @override
  String displayName() => 'دائن';
}
