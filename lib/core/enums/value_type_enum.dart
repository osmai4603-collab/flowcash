import 'app_enum.dart';
import 'package:flowcash/core/enums/warehouse_value_type_enum.dart';

sealed class ValueType extends AppEnum {
  const ValueType();

  static const firstDate = FirstDateValueType._();
  static const lastDate = LastDateValueType._();
  static const defaultCurrency = DefaultCurrencyValueType._();
  static const nameInArabic1 = NameInArabic1ValueType._();
  static const nameInArabic2 = NameInArabic2ValueType._();
  static const nameInEnglish1 = NameInEnglish1ValueType._();
  static const nameInEnglish2 = NameInEnglish2ValueType._();
  static const description1Arabic = Description1ArabicValueType._();
  static const description2Arabic = Description2ArabicValueType._();
  static const description3Arabic = Description3ArabicValueType._();
  static const description1English = Description1EnglishValueType._();
  static const description2English = Description2EnglishValueType._();
  static const description3English = Description3EnglishValueType._();
  static const phoneNumber1 = PhoneNumber1ValueType._();
  static const phoneNumber2 = PhoneNumber2ValueType._();
  static const phoneNumber3 = PhoneNumber3ValueType._();
  static const addressInArabic = AddressInArabicValueType._();
  static const addressInEnglish = AddressInEnglishValueType._();
  static const databaseVersion = DatabaseVersionValueType._();
  static const companyLogo = CompanyLogoValueType._();
  static const pageFormat = PageFormatValueType._();

  static const List<ValueType> values = [
    firstDate,
    lastDate,
    defaultCurrency,
    nameInArabic1,
    nameInArabic2,
    nameInEnglish1,
    nameInEnglish2,
    description1Arabic,
    description2Arabic,
    description3Arabic,
    description1English,
    description2English,
    description3English,
    phoneNumber1,
    phoneNumber2,
    phoneNumber3,
    addressInArabic,
    addressInEnglish,
    databaseVersion,
    companyLogo,
    pageFormat,
  ];

  static ValueType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown ValueType: $name'),
    );
  }

  DataType get dataType;
  String get defaultValue;
}

final class FirstDateValueType extends ValueType {
  const FirstDateValueType._();

  @override
  String get name => 'firstDate';

  @override
  int get index => 0;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '01/01/2000';

  @override
  String displayName() => 'تاريخ أولي';
}

final class LastDateValueType extends ValueType {
  const LastDateValueType._();

  @override
  String get name => 'lastDate';

  @override
  int get index => 1;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '01/10/2024';

  @override
  String displayName() => 'تاريخ أخير';
}

final class DefaultCurrencyValueType extends ValueType {
  const DefaultCurrencyValueType._();

  @override
  String get name => 'defaultCurrency';

  @override
  int get index => 2;

  @override
  DataType get dataType => DataType.integer;

  @override
  String get defaultValue => '1';

  @override
  String displayName() => 'عملة افتراضية';
}

final class NameInArabic1ValueType extends ValueType {
  const NameInArabic1ValueType._();

  @override
  String get name => 'nameInArabic1';

  @override
  int get index => 3;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => 'التدفق النقدي';

  @override
  String displayName() => 'اسم عربي 1';
}

final class NameInArabic2ValueType extends ValueType {
  const NameInArabic2ValueType._();

  @override
  String get name => 'nameInArabic2';

  @override
  int get index => 4;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => 'التدفق النقدي';

  @override
  String displayName() => 'اسم عربي 2';
}

final class NameInEnglish1ValueType extends ValueType {
  const NameInEnglish1ValueType._();

  @override
  String get name => 'nameInEnglish1';

  @override
  int get index => 5;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => 'Cashing Business';

  @override
  String displayName() => 'اسم إنجليزي 1';
}

final class NameInEnglish2ValueType extends ValueType {
  const NameInEnglish2ValueType._();

  @override
  String get name => 'nameInEnglish2';

  @override
  int get index => 6;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => 'Cashing Business';

  @override
  String displayName() => 'اسم إنجليزي 2';
}

final class Description1ArabicValueType extends ValueType {
  const Description1ArabicValueType._();

  @override
  String get name => 'description1Arabic';

  @override
  int get index => 7;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '';

  @override
  String displayName() => 'وصف عربي 1';
}

final class Description2ArabicValueType extends ValueType {
  const Description2ArabicValueType._();

  @override
  String get name => 'description2Arabic';

  @override
  int get index => 8;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '';

  @override
  String displayName() => 'وصف عربي 2';
}

final class Description3ArabicValueType extends ValueType {
  const Description3ArabicValueType._();

  @override
  String get name => 'description3Arabic';

  @override
  int get index => 9;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '';

  @override
  String displayName() => 'وصف عربي 3';
}

final class Description1EnglishValueType extends ValueType {
  const Description1EnglishValueType._();

  @override
  String get name => 'description1English';

  @override
  int get index => 10;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '';

  @override
  String displayName() => 'وصف إنجليزي 1';
}

final class Description2EnglishValueType extends ValueType {
  const Description2EnglishValueType._();

  @override
  String get name => 'description2English';

  @override
  int get index => 11;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '';

  @override
  String displayName() => 'وصف إنجليزي 2';
}

final class Description3EnglishValueType extends ValueType {
  const Description3EnglishValueType._();

  @override
  String get name => 'description3English';

  @override
  int get index => 12;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '';

  @override
  String displayName() => 'وصف إنجليزي 3';
}

final class PhoneNumber1ValueType extends ValueType {
  const PhoneNumber1ValueType._();

  @override
  String get name => 'phoneNumber1';

  @override
  int get index => 13;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '775 374 303';

  @override
  String displayName() => 'رقم هاتف 1';
}

final class PhoneNumber2ValueType extends ValueType {
  const PhoneNumber2ValueType._();

  @override
  String get name => 'phoneNumber2';

  @override
  int get index => 14;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '';

  @override
  String displayName() => 'رقم هاتف 2';
}

final class PhoneNumber3ValueType extends ValueType {
  const PhoneNumber3ValueType._();

  @override
  String get name => 'phoneNumber3';

  @override
  int get index => 15;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '';

  @override
  String displayName() => 'رقم هاتف 3';
}

final class AddressInArabicValueType extends ValueType {
  const AddressInArabicValueType._();

  @override
  String get name => 'addressInArabic';

  @override
  int get index => 16;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => 'اليمن صنعاء الحصبة الجنوبية شارع القاهرة';

  @override
  String displayName() => 'عنوان عربي';
}

final class AddressInEnglishValueType extends ValueType {
  const AddressInEnglishValueType._();

  @override
  String get name => 'addressInEnglish';

  @override
  int get index => 17;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '';

  @override
  String displayName() => 'عنوان إنجليزي';
}

final class DatabaseVersionValueType extends ValueType {
  const DatabaseVersionValueType._();

  @override
  String get name => 'databaseVersion';

  @override
  int get index => 18;

  @override
  DataType get dataType => DataType.integer;

  @override
  String get defaultValue => '1';

  @override
  String displayName() => 'إصدار قاعدة البيانات';
}

final class CompanyLogoValueType extends ValueType {
  const CompanyLogoValueType._();

  @override
  String get name => 'companyLogo';

  @override
  int get index => 19;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => '';

  @override
  String displayName() => 'شعار الشركة';
}

final class PageFormatValueType extends ValueType {
  const PageFormatValueType._();

  @override
  String get name => 'pageFormat';

  @override
  int get index => 20;

  @override
  DataType get dataType => DataType.text;

  @override
  String get defaultValue => 'a4';

  @override
  String displayName() => 'تنسيق الصفحة';
}

sealed class AccountingPatternType extends AppEnum {
  const AccountingPatternType();

  static const personal = PersonalAccountingPatternType._();
  static const business = BusinessAccountingPatternType._();

  static const List<AccountingPatternType> values = [personal, business];

  static AccountingPatternType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown AccountingPatternType: $name'),
    );
  }
}

final class PersonalAccountingPatternType extends AccountingPatternType {
  const PersonalAccountingPatternType._();

  @override
  String get name => 'personal';

  @override
  int get index => 0;

  @override
  String displayName() => 'شخصي';
}

final class BusinessAccountingPatternType extends AccountingPatternType {
  const BusinessAccountingPatternType._();

  @override
  String get name => 'business';

  @override
  int get index => 1;

  @override
  String displayName() => 'اعمال';
}
