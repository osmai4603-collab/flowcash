import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';

abstract interface class CurrencyDataSource
    implements AppDataSource<String, CurrencyEntity, Map<String, dynamic>> {
  Future<List<CurrencyEntity>> whereSelected();
  Future<List<CurrencyEntity>> whereNotSelected();
}
