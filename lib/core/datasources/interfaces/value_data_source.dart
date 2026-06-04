import 'dart:typed_data';

import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';

abstract interface class ValueDataSource implements AppDataSource<int, ValueEntity, Map<String, dynamic>> {
  Future<ValueEntity?> firstValue(ValueType valueType);
  Future<ValueEntity> getValue(ValueType valueType);
  Future<int> fetchLocalCurrency();
  Future<String> fetchFirstDate();
  Future<String> getLastDate();
  Future<String> fetchCompanyNameArabic();
  Future<String> fetchCompanyNameEnglish();
  Future<String> fetchCompanyLocation();
  Future<String> fetchCompanyDescription1Arabic();
  Future<String> fetchCompanyDescription2Arabic();
  Future<String> fetchCompanyDescription3Arabic();
  Future<String> fetchCompanyDescription1English();
  Future<String> fetchCompanyDescription2English();
  Future<String> fetchCompanyDescription3English();
  Future<int> fetchDatabaseVersion();
  Future<Uint8List> fetchCompanyLogo();
  Future<Map<ValueType, ValueEntity>> fetchAsMap();
  Future<bool> updateValue({required String value, required int rowId});
}
