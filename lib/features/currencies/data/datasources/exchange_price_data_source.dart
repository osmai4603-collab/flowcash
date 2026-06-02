import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';

abstract interface class ExchangePriceDataSource
    implements AppDataSource<int, ExchangePriceEntity, Map<String, dynamic>> {
  Future<double> getExPrice(String fromCurrencyId, String toCurrencyId);
  Future<List<ExchangePriceEntity>> getWhereFromCurrencyId(
    Iterable<String> ids,
  );
}
