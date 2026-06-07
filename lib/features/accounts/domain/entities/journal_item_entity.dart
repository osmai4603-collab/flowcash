import 'package:flowcash/core/entities/entity.dart';

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
    );
  }
}
