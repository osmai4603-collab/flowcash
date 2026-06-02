import 'app_enum.dart';

sealed class PeriodType extends AppEnum {
  const PeriodType();

  static const permanent = PermanentPeriodType._();
  static const temporary = TemporaryPeriodType._();

  static const List<PeriodType> values = [
    permanent,
    temporary,
  ];

  static PeriodType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown PeriodType: $name'),
    );
  }
}

final class PermanentPeriodType extends PeriodType {
  const PermanentPeriodType._();

  @override
  String get name => 'permanent';

  @override
  int get index => 0;

  @override
  String displayName() => 'مستمر';
}

final class TemporaryPeriodType extends PeriodType {
  const TemporaryPeriodType._();

  @override
  String get name => 'temporary';

  @override
  int get index => 1;

  @override
  String displayName() => 'مؤقت';
}
