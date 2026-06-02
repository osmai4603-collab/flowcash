import 'package:flowcash/core/entities/entity.dart';

/// كينونة سعر الصرف (ExchangePriceEntity) بين عملتين.
class ExchangePriceEntity extends Entity {
  final int id;
  final String fromCurrencyId;
  final String toCurrencyId;
  final double price;

  const ExchangePriceEntity({
    required this.id,
    required this.fromCurrencyId,
    required this.toCurrencyId,
    required this.price,
  });

  @override
  List<Object?> get props => [id, fromCurrencyId, toCurrencyId, price];

  @override
  ExchangePriceEntity copyWith({
    int? id,
    String? fromCurrencyId,
    String? toCurrencyId,
    double? price,
  }) {
    return ExchangePriceEntity(
      id: id ?? this.id,
      fromCurrencyId: fromCurrencyId ?? this.fromCurrencyId,
      toCurrencyId: toCurrencyId ?? this.toCurrencyId,
      price: price ?? this.price,
    );
  }
}
