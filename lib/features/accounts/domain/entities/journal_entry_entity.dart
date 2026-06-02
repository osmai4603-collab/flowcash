import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';

/// كيان يمثل قيد يومية واحد.
class JournalEntryEntity extends Entity {
  final int id;
  final String referenceNumber;
  final String? description;
  final DateTime createdAt;
  final int createdBy;
  final String currencyId;
  final double exPrice;
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
    required this.exPrice,
    required this.baseAmount,
    this.warehouseId,
    this.items = const [],
  });

  @override
  List<Object?> get props => [
    id,
    referenceNumber,
    description,
    createdAt,
    createdBy,
    currencyId,
    exPrice,
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
    double? exPrice,
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
      exPrice: exPrice ?? this.exPrice,
      baseAmount: baseAmount ?? this.baseAmount,
      warehouseId: warehouseId ?? this.warehouseId,
      items: items ?? this.items,
    );
  }
}
