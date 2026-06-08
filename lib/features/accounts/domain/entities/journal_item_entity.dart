import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';

/// كيان يمثل سطرًا في بند قيد يومية.
class JournalItemEntity extends Entity {
  final int id;
  final int entryId;
  final int accountId;
  final double debit;
  final double credit;
  final String? lineDescription;
  final String currencyId;
  final double exPrice;
  final double expriceMain;
  final JournalStatus journalStatus;

  const JournalItemEntity({
    required this.id,
    required this.entryId,
    required this.accountId,
    required this.debit,
    required this.credit,
    this.lineDescription,
    required this.currencyId,
    required this.exPrice,
    required this.expriceMain,
    required this.journalStatus,
  });

  @override
  List<Object?> get props => [
        id,
        entryId,
        accountId,
        debit,
        credit,
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
    double? debit,
    double? credit,
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
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      lineDescription: lineDescription ?? this.lineDescription,
      currencyId: currencyId ?? this.currencyId,
      exPrice: exPrice ?? this.exPrice,
      expriceMain: expriceMain ?? this.expriceMain,
      journalStatus: journalStatus ?? this.journalStatus,
    );
  }
}
