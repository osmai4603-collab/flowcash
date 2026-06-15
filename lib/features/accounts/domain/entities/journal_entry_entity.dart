import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';

/// كيان يمثل قيد يومية واحد.
class JournalEntryEntity extends Entity {
  final int id;
  final String referenceNumber;
  final String? description;
  final DateTime createdAt;
  final int createdBy;
  final String currencyId;
  final double baseAmount;
  final int? warehouseId;
  final List<JournalItemEntity> items;

  const JournalEntryEntity({
    required this.id,
    required this.referenceNumber,
    this.description,
    required this.createdAt,
    required this.createdBy,
    required this.currencyId,
    required this.baseAmount,
    this.warehouseId,
    this.items = const [],
  });

  factory JournalEntryEntity.fromOpeningQuantity({
    required OpeningQuantityEntity openingQuantity,
    required int warehouseId,
    required int userId,
  }) {
    return JournalEntryEntity(
      id: 0,
      referenceNumber: 'INVCAT-${openingQuantity.inventoryId}',
      description: 'قيد تلقائي لتهيئة المخزون رقم ${openingQuantity.inventoryId}',
      createdAt: openingQuantity.createdAt,
      createdBy: userId,
      currencyId: openingQuantity.currencyId ?? 'YER',
      baseAmount: openingQuantity.costTotal,
      warehouseId: warehouseId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    referenceNumber,
    description,
    createdAt,
    createdBy,
    currencyId,
    baseAmount,
    warehouseId,
    items,
  ];

  @override
  JournalEntryEntity copyWith({
    int? id,
    String? referenceNumber,
    String? description,
    DateTime? createdAt,
    int? createdBy,
    String? currencyId,
    double? baseAmount,
    int? warehouseId,
    List<JournalItemEntity>? items,
  }) {
    return JournalEntryEntity(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      currencyId: currencyId ?? this.currencyId,
      baseAmount: baseAmount ?? this.baseAmount,
      warehouseId: warehouseId ?? this.warehouseId,
      items: items ?? this.items,
    );
  }
}
