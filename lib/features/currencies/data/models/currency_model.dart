import 'package:flowcash/core/tables/currencies_table.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/core/models/model.dart';

final class CurrencyModel extends CurrencyEntity implements Model {
  const CurrencyModel({
    required super.id,
    required super.name,
    required super.symbol,
    required super.isDefault,
  });

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      id: map[CurrenciesTable().id] as String,
      name: (map[CurrenciesTable().currencyName] as String?) ?? '',
      symbol: (map[CurrenciesTable().symbol] as String?) ?? '',
      isDefault: map[CurrenciesTable().isDefault] == true || map[CurrenciesTable().isDefault] == 1,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      CurrenciesTable().id: id,
      CurrenciesTable().currencyName: name,
      CurrenciesTable().symbol: symbol,
      CurrenciesTable().isDefault: isDefault ? 1 : 0,
    };
  }

  @override
  CurrencyModel copyWith({
    String? id,
    String? name,
    String? symbol,
    bool? isDefault,
  }) {
    return CurrencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
