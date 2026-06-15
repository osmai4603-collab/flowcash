import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/core/tables/opening_quantities_table.dart';

final class OpeningQuantityModel extends OpeningQuantityEntity {
  const OpeningQuantityModel({
    required super.id,
    required super.inventoryId,
    super.countUnits = 0.0,
    required super.createdAt,
    super.costTotal = 0.0,
    super.periodId = 0,
    super.currencyId,
    super.journalEntryId,
  });

  factory OpeningQuantityModel.fromMap(Map<String, dynamic> map) {
    return OpeningQuantityModel(
      id: map[OpeningQuantitiesTable.id] as int,
      inventoryId: map[OpeningQuantitiesTable.inventoryId] as int,
      countUnits: ((map[OpeningQuantitiesTable.countUnits]) as num).toDouble(),
      createdAt: DateTime.parse(
        map[OpeningQuantitiesTable.createdAt] as String? ?? "",
      ),
      costTotal: ((map[OpeningQuantitiesTable.costTotal]) as num).toDouble(),
      periodId: map[OpeningQuantitiesTable.periodId] as int,
      currencyId: map[OpeningQuantitiesTable.currencyId] as String?,
      journalEntryId: map[OpeningQuantitiesTable.journalEntryId] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) OpeningQuantitiesTable.id: id,
      OpeningQuantitiesTable.inventoryId: inventoryId,
      OpeningQuantitiesTable.countUnits: countUnits,
      OpeningQuantitiesTable.createdAt: createdAt.toIso8601String(),
      OpeningQuantitiesTable.costTotal: costTotal,
      OpeningQuantitiesTable.periodId: periodId,
      OpeningQuantitiesTable.currencyId: currencyId,
      OpeningQuantitiesTable.journalEntryId: journalEntryId,
    };
  }

  @override
  OpeningQuantityModel copyWith({
    int? id,
    int? inventoryId,
    double? countUnits,
    DateTime? createdAt,
    double? costTotal,
    int? periodId,
    String? currencyId,
    int? journalEntryId,
  }) {
    return OpeningQuantityModel(
      id: id ?? this.id,
      inventoryId: inventoryId ?? this.inventoryId,
      countUnits: countUnits ?? this.countUnits,
      createdAt: createdAt ?? this.createdAt,
      costTotal: costTotal ?? this.costTotal,
      periodId: periodId ?? this.periodId,
      currencyId: currencyId ?? this.currencyId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
    );
  }
}
