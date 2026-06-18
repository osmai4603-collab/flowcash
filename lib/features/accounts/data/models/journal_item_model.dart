import 'package:flowcash/core/tables/journal_items_table.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';

final class JournalItemModel extends JournalItemEntity {
  const JournalItemModel({
    required super.id,
    required super.entryId,
    required super.accountId,
    required super.amount,
    super.lineDescription,
    required super.currencyId,
    required super.exPrice,
    required super.exPriceMain,
    required super.journalStatus,
  });

  factory JournalItemModel.fromMap(Map<String, dynamic> map) {
    return JournalItemModel(
      id: map[JournalItemsTable.itemId] as int,
      entryId: map[JournalItemsTable.entryId] as int,
      accountId: map[JournalItemsTable.accountId] as int,
      amount: ((map[JournalItemsTable.amount]) as num).toDouble(),
      lineDescription: map[JournalItemsTable.lineDescription] as String?,
      currencyId: map[JournalItemsTable.currencyId] as String,
      exPrice: ((map[JournalItemsTable.exPrice]) as num).toDouble(),
      exPriceMain: ((map[JournalItemsTable.exPriceMain]) as num).toDouble(),
      journalStatus: JournalStatus.of(map[JournalItemsTable.journalStatus] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) JournalItemsTable.itemId: id,
      JournalItemsTable.entryId: entryId,
      JournalItemsTable.accountId: accountId,
      JournalItemsTable.amount: amount,
      JournalItemsTable.lineDescription: lineDescription,
      JournalItemsTable.currencyId: currencyId,
      JournalItemsTable.exPrice: exPrice,
      JournalItemsTable.exPriceMain: exPriceMain,
      JournalItemsTable.journalStatus: journalStatus.name,
    };
  }

  @override
  JournalItemModel copyWith({
    int? id,
    int? entryId,
    int? accountId,
    double? amount,
    String? lineDescription,
    String? currencyId,
    double? exPrice,
    double? exPriceMain,
    JournalStatus? journalStatus,
  }) {
    return JournalItemModel(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      lineDescription: lineDescription ?? this.lineDescription,
      currencyId: currencyId ?? this.currencyId,
      exPrice: exPrice ?? this.exPrice,
      exPriceMain: exPriceMain ?? this.exPriceMain,
      journalStatus: journalStatus ?? this.journalStatus,
    );
  }
}
