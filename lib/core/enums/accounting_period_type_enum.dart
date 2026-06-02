
import 'app_enum.dart';

sealed class AccountingsPeriodType extends AppEnum {
  final String typeName;
  const AccountingsPeriodType({required this.typeName});

  @override
  String displayName() {
    return typeName;
  }

  static const temporary = TemporaryAccountingsPeriodType._();
  static const permanent = ContinuedAccountingsPeriodType._();

  static List<AccountingsPeriodType> values = [
    temporary, permanent,
  ];
}


final class TemporaryAccountingsPeriodType extends AccountingsPeriodType {
  const TemporaryAccountingsPeriodType._() : super(typeName: 'مؤقت');

  @override
  String get name => 'temporary';

  @override
  int get index => 0;
}

final class ContinuedAccountingsPeriodType extends AccountingsPeriodType {
  const ContinuedAccountingsPeriodType._() : super(typeName: 'مستمر');

  @override
  String get name => 'continued';

  @override
  int get index => 1;
}
