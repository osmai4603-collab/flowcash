


import 'package:flowcash/core/enums/warehouse_value_type.dart';

enum ValueType {
  firstDate(dataType: DataType.text, defaultValue: '01/01/2000'),
  lastDate(dataType: DataType.text, defaultValue: '01/10/2024'),
  defaultCurrency(dataType: DataType.integer, defaultValue: '1'),
  nameInArabic1(dataType: DataType.text, defaultValue: 'التدفق النقدي'),
  nameInArabic2(dataType: DataType.text, defaultValue: 'التدفق النقدي'),
  nameInEnglish1(dataType: DataType.text, defaultValue: 'Cashing Business'),
  nameInEnglish2(dataType: DataType.text, defaultValue: 'Cashing Business'),
  description1Arabic(dataType: DataType.text),
  description2Arabic(dataType: DataType.text),
  description3Arabic(dataType: DataType.text),
  description1English(dataType: DataType.text),
  description2English(dataType: DataType.text),
  description3English(dataType: DataType.text),
  phoneNumber1(dataType: DataType.text, defaultValue: '775 374 303'),
  phoneNumber2(dataType: DataType.text),
  phoneNumber3(dataType: DataType.text),
  addressInArabic(dataType: DataType.text, defaultValue: 'اليمن صنعاء الحصبة الجنوبية شارع القاهرة'),
  addressInEnglish(dataType: DataType.text),
  databaseVersion(dataType: DataType.integer, defaultValue: '1'),
  companyLogo(dataType: DataType.text, defaultValue: ''),
  accountingPatternType(dataType: DataType.text, defaultValue: 'business'),
  pageFormat(dataType: DataType.text, defaultValue: 'a4'),
  ;

  final DataType dataType;
  final String defaultValue;

  const ValueType({required this.dataType, this.defaultValue = ''});

  @override
  String toString() {
    return name;
  }

}


enum AccountingPatternType {
  personal, business;
}