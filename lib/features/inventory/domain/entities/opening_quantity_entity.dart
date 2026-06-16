import 'package:flowcash/core/entities/entity.dart';

class OpeningQuantityEntity extends Entity {
  final int id;
  final int inventoryId;
  final double countUnits;
  final DateTime createdAt;
  final double costTotal;
  final int periodId;
  final String currencyId;
  final int? journalEntryId;

  const OpeningQuantityEntity({
    required this.id,
    required this.inventoryId,
    this.countUnits = 0.0,
    required this.createdAt,
    this.costTotal = 0.0,
    this.periodId = 0,
    required this.currencyId,
    this.journalEntryId,
  });

  @override
  List<Object?> get props => [
    id,
    inventoryId,
    countUnits,
    createdAt,
    costTotal,
    periodId,
    currencyId,
    journalEntryId,
  ];

  @override
  OpeningQuantityEntity copyWith({
    int? id,
    int? inventoryId,
    double? countUnits,
    DateTime? createdAt,
    double? costTotal,
    int? periodId,
    String? currencyId,
    int? journalEntryId,
  }) {
    return OpeningQuantityEntity(
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
