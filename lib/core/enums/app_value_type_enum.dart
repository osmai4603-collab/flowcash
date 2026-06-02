import 'app_enum.dart';

sealed class AppValueType extends AppEnum {
  const AppValueType();

  static const defaultCurrency = DefaultCurrencyAppValueType._();
  static const companyName = CompanyNameAppValueType._();
  static const companyPhone = CompanyPhoneAppValueType._();
  static const companyAddress = CompanyAddressAppValueType._();
  static const pageFormat = PageFormatAppValueType._();
  static const companyDescription = CompanyDescriptionAppValueType._();

  static const List<AppValueType> values = [
    defaultCurrency,
    companyName,
    companyPhone,
    companyAddress,
    pageFormat,
    companyDescription,
  ];

  static AppValueType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown AppValueType: $name'),
    );
  }
}

final class DefaultCurrencyAppValueType extends AppValueType {
  const DefaultCurrencyAppValueType._();

  @override
  String get name => 'default_currency';

  @override
  int get index => 0;

  @override
  String displayName() => 'العملة الافتراضية';
}

final class CompanyNameAppValueType extends AppValueType {
  const CompanyNameAppValueType._();

  @override
  String get name => 'company_name';

  @override
  int get index => 1;

  @override
  String displayName() => 'اسم الشركة';
}

final class CompanyPhoneAppValueType extends AppValueType {
  const CompanyPhoneAppValueType._();

  @override
  String get name => 'company_phone';

  @override
  int get index => 2;

  @override
  String displayName() => 'هاتف الشركة';
}

final class CompanyAddressAppValueType extends AppValueType {
  const CompanyAddressAppValueType._();

  @override
  String get name => 'company_address';

  @override
  int get index => 3;

  @override
  String displayName() => 'عنوان الشركة';
}

final class PageFormatAppValueType extends AppValueType {
  const PageFormatAppValueType._();

  @override
  String get name => 'page_format';

  @override
  int get index => 4;

  @override
  String displayName() => 'تنسيق الصفحة';
}

final class CompanyDescriptionAppValueType extends AppValueType {
  const CompanyDescriptionAppValueType._();

  @override
  String get name => 'company_description';

  @override
  int get index => 5;

  @override
  String displayName() => 'وصف الشركة';
}
