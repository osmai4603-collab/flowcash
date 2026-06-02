import 'package:flowcash/core/enums/batch_source_enum.dart';
import 'package:flowcash/core/enums/batch_status_enum.dart';
import 'package:flowcash/core/entities/entity.dart';

class InventoryBatchEntity extends Entity {
  final int id;
  final String batchNumber;
  final int inventoryId;
  final int? personId;
  final BatchSource batchSource;
  final BatchStatus batchStatus;
  final double countUnits;
  final double unitCost;
  final DateTime inputDate;
  final DateTime? productionDate;
  final DateTime? expirationDate;

  const InventoryBatchEntity({
    required this.id,
    this.batchNumber = '',
    this.inventoryId = 0,
    this.personId,
    this.batchSource = BatchSource.buys,
    this.batchStatus = BatchStatus.available,
    this.countUnits = 0.0,
    this.unitCost = 0.0,
    required this.inputDate,
    this.productionDate,
    this.expirationDate,
  });

  @override
  List<Object?> get props => [
    id,
    batchNumber,
    inventoryId,
    personId,
    batchSource,
    batchStatus,
    countUnits,
    unitCost,
    inputDate,
    productionDate,
    expirationDate,
  ];

  @override
  InventoryBatchEntity copyWith({
    int? id,
    String? batchNumber,
    int? inventoryId,
    int? personId,
    BatchSource? batchSource,
    BatchStatus? batchStatus,
    double? countUnits,
    double? unitCost,
    DateTime? inputDate,
    DateTime? productionDate,
    DateTime? expirationDate,
  }) {
    return InventoryBatchEntity(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      inventoryId: inventoryId ?? this.inventoryId,
      personId: personId ?? this.personId,
      batchSource: batchSource ?? this.batchSource,
      batchStatus: batchStatus ?? this.batchStatus,
      countUnits: countUnits ?? this.countUnits,
      unitCost: unitCost ?? this.unitCost,
      inputDate: inputDate ?? this.inputDate,
      productionDate: productionDate ?? this.productionDate,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }
}
