import 'package:flowcash/core/entities/entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';

/// كينونة الحركة المالية (FinancialTransactionEntity) التي تمثل الحركات المالية المتنوعة (مبيعات، مشتريات، مرتجعات وغيرها).
class FinancialTransactionEntity extends Entity {
  final int id;
  final DateTime createdAt;
  final int createdBy;
  final String? note;
  final double offerAmount;
  final String currencyId;
  final int billNumber;
  final int warehouseId;
  final int? journalEntryId;
  final int hintId;
  final HistoriesGroup historyGroup;

  const FinancialTransactionEntity({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    this.note,
    required this.offerAmount,
    required this.currencyId,
    required this.billNumber,
    required this.warehouseId,
    this.journalEntryId,
    required this.hintId,
    required this.historyGroup,
  });

  /// تنسيق رقم الفاتورة/الحركة بـ 5 أرقام (مثال: 00001)
  String get billNumberFormat => billNumber.toString().padLeft(5, '0');

  @override
  List<Object?> get props => [
    id,
    createdAt,
    createdBy,
    note,
    offerAmount,
    currencyId,
    billNumber,
    warehouseId,
    journalEntryId,
    hintId,
    historyGroup,
  ];

  @override
  FinancialTransactionEntity copyWith({
    int? id,
    DateTime? createdAt,
    int? createdBy,
    String? note,
    double? offerAmount,
    String? currencyId,
    int? billNumber,
    int? warehouseId,
    int? journalEntryId,
    int? hintId,
    HistoriesGroup? historyGroup,
  }) {
    return FinancialTransactionEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      note: note ?? this.note,
      offerAmount: offerAmount ?? this.offerAmount,
      currencyId: currencyId ?? this.currencyId,
      billNumber: billNumber ?? this.billNumber,
      warehouseId: warehouseId ?? this.warehouseId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      hintId: hintId ?? this.hintId,
      historyGroup: historyGroup ?? this.historyGroup,
    );
  }
}
