import 'package:flowcash/core/tables/exchange_prices_table.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';

final class ExchangePriceModel extends ExchangePriceEntity {
  const ExchangePriceModel({
    required super.id,
    required super.fromCurrencyId,
    required super.toCurrencyId,
    required super.price,
  });

  factory ExchangePriceModel.fromMap(Map<String, dynamic> map) {
    return ExchangePriceModel(
      id: map[ExchangePricesTable().id] as int? ?? 0,
      fromCurrencyId: (map[ExchangePricesTable().fromCurrencyId] as String),
      toCurrencyId: (map[ExchangePricesTable().toCurrencyId] as String?) ?? '',
      price: ((map[ExchangePricesTable().exchangePrice]) as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) ExchangePricesTable().id: id,
      ExchangePricesTable().fromCurrencyId: fromCurrencyId,
      ExchangePricesTable().toCurrencyId: toCurrencyId,
      ExchangePricesTable().exchangePrice: price,
    };
  }

  @override
  ExchangePriceModel copyWith({
    int? id,
    String? fromCurrencyId,
    String? toCurrencyId,
    double? price,
  }) {
    return ExchangePriceModel(
      id: id ?? this.id,
      fromCurrencyId: fromCurrencyId ?? this.fromCurrencyId,
      toCurrencyId: toCurrencyId ?? this.toCurrencyId,
      price: price ?? this.price,
    );
  }
}
