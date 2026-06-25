part of 'bill_form_bloc.dart';

enum BillFormStatus { initial, loading, success, failure, submitting, submitSuccess, submitFailure }

class BillFormState extends Equatable {
  final BillFormStatus status;
  final List<RequestModel> requests;
  final BillCashType billCashType;
  final WarehouseEntity? warehouseSelected;
  final PersonEntity? personSelected;
  final CurrencyEntity? currencySelected;
  final DateTime dateSelected;
  final DateTime firstDate;
  final int billNumber;
  final String note;
  final double totalAmount;
  final bool isDataChanged;
  final String? errorMessage;
  final InvoiceType billType;
  final BillEntity? initialBill;
  final PersonEntity? treasurySelected;

  const BillFormState({
    this.status = BillFormStatus.initial,
    this.requests = const [],
    this.billCashType = BillCashType.cash,
    this.warehouseSelected,
    this.personSelected,
    this.currencySelected,
    required this.dateSelected,
    required this.firstDate,
    this.billNumber = 1,
    this.note = '',
    this.totalAmount = 0.0,
    this.isDataChanged = false,
    this.errorMessage,
    required this.billType,
    this.initialBill,
    this.treasurySelected,
  });

  BillFormState copyWith({
    BillFormStatus? status,
    List<RequestModel>? requests,
    BillCashType? billCashType,
    WarehouseEntity? warehouseSelected,
    PersonEntity? personSelected,
    CurrencyEntity? currencySelected,
    DateTime? dateSelected,
    DateTime? firstDate,
    int? billNumber,
    String? note,
    double? totalAmount,
    bool? isDataChanged,
    String? errorMessage,
    InvoiceType? billType,
    BillEntity? initialBill,
    PersonEntity? treasurySelected,
  }) {
    return BillFormState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      billCashType: billCashType ?? this.billCashType,
      warehouseSelected: warehouseSelected ?? this.warehouseSelected,
      personSelected: personSelected ?? this.personSelected,
      currencySelected: currencySelected ?? this.currencySelected,
      dateSelected: dateSelected ?? this.dateSelected,
      firstDate: firstDate ?? this.firstDate,
      billNumber: billNumber ?? this.billNumber,
      note: note ?? this.note,
      totalAmount: totalAmount ?? this.totalAmount,
      isDataChanged: isDataChanged ?? this.isDataChanged,
      errorMessage: errorMessage ?? this.errorMessage,
      billType: billType ?? this.billType,
      initialBill: initialBill ?? this.initialBill,
      treasurySelected: treasurySelected ?? this.treasurySelected,
    );
  }

  @override
  List<Object?> get props => [
        status,
        requests,
        billCashType,
        warehouseSelected,
        personSelected,
        currencySelected,
        dateSelected,
        firstDate,
        billNumber,
        note,
        totalAmount,
        isDataChanged,
        errorMessage,
        billType,
        initialBill,
        treasurySelected,
      ];
}
