import 'package:flowcash/core/entities/entity.dart';

class InventorySubcategoryEntity extends Entity {
  final int id;
  final int storeId;
  final int catalogId;
  final int? revenueAccountId;
  final int? expenseAccountId;
  final int? incomeStockId;
  final int? outcomeStockId;

  const InventorySubcategoryEntity({
    required this.id,
    this.storeId = 0,
    this.catalogId = 0,
    this.revenueAccountId,
    this.expenseAccountId,
    this.incomeStockId,
    this.outcomeStockId,
  });

  @override
  List<Object?> get props => [
    id,
    storeId,
    catalogId,
    revenueAccountId,
    expenseAccountId,
    incomeStockId,
    outcomeStockId,
  ];

  InventorySubcategoryEntity copyWith({
    int? id,
    int? storeId,
    int? subcategoryId,
    int? revenueAccountId,
    int? expenseAccountId,
    int? incomeStockId,
    int? outcomeStockId,
  }) {
    return InventorySubcategoryEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      catalogId: subcategoryId ?? this.catalogId,
      revenueAccountId: revenueAccountId ?? this.revenueAccountId,
      expenseAccountId: expenseAccountId ?? this.expenseAccountId,
      incomeStockId: incomeStockId ?? this.incomeStockId,
      outcomeStockId: outcomeStockId ?? this.outcomeStockId,
    );
  }
}
