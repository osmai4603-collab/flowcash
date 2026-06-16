import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';

/// كيان يمثل سطرًا في بند قيد يومية.
class JournalItemEntity extends Entity {
  final int id;
  final int entryId;
  final int accountId;
  final double amount;
  final String? lineDescription;
  final String currencyId;
  final double exPrice;
  final double expriceMain;
  final JournalStatus journalStatus;

  const JournalItemEntity({
    required this.id,
    required this.entryId,
    required this.accountId,
    required this.amount,
    this.lineDescription,
    required this.currencyId,
    required this.exPrice,
    required this.expriceMain,
    required this.journalStatus,
  });

  factory JournalItemEntity.fromOpeningQuantity({
    required OpeningQuantityEntity openingQuantity,
    required int accountId,
    required int journalEntryId,
    required String lineDescription,
    required double exPrice,
    required double exPriceMain,
  }) {
    return JournalItemEntity(
      id: 0,
      entryId: journalEntryId,
      accountId: accountId,
      amount: openingQuantity.costTotal,
      lineDescription: lineDescription,
      currencyId: openingQuantity.currencyId,
      exPrice: exPrice,
      expriceMain: exPriceMain,
      journalStatus: JournalStatus.increment,
    );
  }

  @override
  List<Object?> get props => [
    id,
    entryId,
    accountId,
    amount,
    lineDescription,
    currencyId,
    exPrice,
    expriceMain,
    journalStatus,
  ];

  @override
  JournalItemEntity copyWith({
    int? id,
    int? entryId,
    int? accountId,
    double? amount,
    String? lineDescription,
    String? currencyId,
    double? exPrice,
    double? expriceMain,
    JournalStatus? journalStatus,
  }) {
    return JournalItemEntity(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      lineDescription: lineDescription ?? this.lineDescription,
      currencyId: currencyId ?? this.currencyId,
      exPrice: exPrice ?? this.exPrice,
      expriceMain: expriceMain ?? this.expriceMain,
      journalStatus: journalStatus ?? this.journalStatus,
    );
  }

  double get historyAmount {
    return journalStatus == JournalStatus.increment ? amount : amount * -1;
  }
}
