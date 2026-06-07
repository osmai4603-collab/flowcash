import 'package:flowcash/core/entities/entity.dart';

/// كينونة العملة (CurrencyEntity) المستخدمة في العمليات المالية.
class CurrencyEntity extends Entity {
  final String id;
  final String name;
  final String symbol;
  final bool isDefault;

  const CurrencyEntity({
    required this.id,
    required this.name,
    required this.symbol,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [id, name, symbol, isDefault];

  @override
  CurrencyEntity copyWith({
    String? id,
    String? name,
    String? symbol,
    bool? isDefault,
  }) {
    return CurrencyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
