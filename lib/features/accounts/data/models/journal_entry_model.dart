import 'package:flowcash/core/tables/journal_entries_table.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/data/models/journal_item_model.dart';
import 'package:flowcash/core/models/model.dart';

final class JournalEntryModel extends JournalEntryEntity implements Model {
  const JournalEntryModel({
    required super.id,
    required super.referenceNumber,
    super.description,
    required super.createdAt,
    required super.createdBy,
    required super.currencyId,
    required super.baseAmount,
    super.warehouseId,
    super.items = const [],
  });

  factory JournalEntryModel.fromMap(Map<String, dynamic> map, {List<JournalItemEntity> items = const []}) {
    return JournalEntryModel(
      id: map[JournalEntriesTable().id] as int,
      referenceNumber: (map[JournalEntriesTable().referenceNumber] as String?) ?? '',
      description: map[JournalEntriesTable().description] as String?,
      createdAt: DateTime.parse(map[JournalEntriesTable().createdAt] as String),
      createdBy: map[JournalEntriesTable().userId] as int,
      currencyId: map[JournalEntriesTable().currencyId] as String,
      baseAmount: ((map[JournalEntriesTable().amount]) as num).toDouble(),
      warehouseId: map[JournalEntriesTable().warehouseId] as int?,
      items: items,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id > 0) JournalEntriesTable().id: id,
      JournalEntriesTable().referenceNumber: referenceNumber,
      JournalEntriesTable().description: description,
      JournalEntriesTable().createdAt: createdAt.toIso8601String(),
      JournalEntriesTable().userId: createdBy,
      JournalEntriesTable().currencyId: currencyId,
      JournalEntriesTable().amount: baseAmount,
      JournalEntriesTable().warehouseId: warehouseId,
    };
  }

  @override
  JournalEntryModel copyWith({
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
    return JournalEntryModel(
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
