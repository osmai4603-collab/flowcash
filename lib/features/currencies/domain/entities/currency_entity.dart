import 'package:flowcash/core/entities/entity.dart';

/// كينونة العملة (CurrencyEntity) المستخدمة في العمليات المالية.
class CurrencyEntity extends Entity {
  final String id;
  final String name;
  final String symbol;
  final String fullSymbol;
  final String country;
  final bool selected;

  const CurrencyEntity({
    required this.id,
    required this.name,
    required this.symbol,
    required this.fullSymbol,
    required this.country,
    required this.selected,
  });

  @override
  List<Object?> get props => [id, name, symbol, fullSymbol, country, selected];

  @override
  CurrencyEntity copyWith({
    String? id,
    String? name,
    String? symbol,
    String? fullSymbol,
    String? country,
    bool? selected,
  }) {
    return CurrencyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      fullSymbol: fullSymbol ?? this.fullSymbol,
      country: country ?? this.country,
      selected: selected ?? this.selected,
    );
  }
}
