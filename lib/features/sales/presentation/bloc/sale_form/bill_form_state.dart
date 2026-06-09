part of 'bill_form_bloc.dart';

enum BillFormStatus { initial, loading, success, failure, submitting, submitSuccess, submitFailure }

class BillFormState extends Equatable {
  final BillFormStatus status;
  final List<WarehouseEntity> warehouses;
  final List<CurrencyEntity> currencies;
  final List<ExchangePriceEntity> exPrices;
  final List<RequestModel> requests;
  final BillCashType billCashType;
  final WarehouseEntity? warehouseSelected;
  final PersonEntity? personSelected;
  final CurrencyEntity? currencySelected;
  final DateTime dateSelected;
  final DateTime firstDate;
  final ValueCounterEntity? billCounter;
  final int billNumber;
  final String note;
  final double totalAmount;
  final bool isDataChanged;
  final String? errorMessage;
  final InvoiceType billType;
  final BillEntity? initialBill;

  const BillFormState({
    this.status = BillFormStatus.initial,
    this.warehouses = const [],
    this.currencies = const [],
    this.exPrices = const [],
    this.requests = const [],
    this.billCashType = BillCashType.cash,
    this.warehouseSelected,
    this.personSelected,
    this.currencySelected,
    required this.dateSelected,
    required this.firstDate,
    this.billCounter,
    this.billNumber = 1,
    this.note = '',
    this.totalAmount = 0.0,
    this.isDataChanged = false,
    this.errorMessage,
    required this.billType,
    this.initialBill,
  });

  BillFormState copyWith({
    BillFormStatus? status,
    List<WarehouseEntity>? warehouses,
    List<CurrencyEntity>? currencies,
    List<ExchangePriceEntity>? exPrices,
    List<RequestModel>? requests,
    BillCashType? billCashType,
    WarehouseEntity? warehouseSelected,
    PersonEntity? personSelected,
    CurrencyEntity? currencySelected,
    DateTime? dateSelected,
    DateTime? firstDate,
    ValueCounterEntity? billCounter,
    int? billNumber,
    String? note,
    double? totalAmount,
    bool? isDataChanged,
    String? errorMessage,
    InvoiceType? billType,
    BillEntity? initialBill,
  }) {
    return BillFormState(
      status: status ?? this.status,
      warehouses: warehouses ?? this.warehouses,
      currencies: currencies ?? this.currencies,
      exPrices: exPrices ?? this.exPrices,
      requests: requests ?? this.requests,
      billCashType: billCashType ?? this.billCashType,
      warehouseSelected: warehouseSelected ?? this.warehouseSelected,
      personSelected: personSelected ?? this.personSelected,
      currencySelected: currencySelected ?? this.currencySelected,
      dateSelected: dateSelected ?? this.dateSelected,
      firstDate: firstDate ?? this.firstDate,
      billCounter: billCounter ?? this.billCounter,
      billNumber: billNumber ?? this.billNumber,
      note: note ?? this.note,
      totalAmount: totalAmount ?? this.totalAmount,
      isDataChanged: isDataChanged ?? this.isDataChanged,
      errorMessage: errorMessage ?? this.errorMessage,
      billType: billType ?? this.billType,
      initialBill: initialBill ?? this.initialBill,
    );
  }

  @override
  List<Object?> get props => [
        status,
        warehouses,
        currencies,
        exPrices,
        requests,
        billCashType,
        warehouseSelected,
        personSelected,
        currencySelected,
        dateSelected,
        firstDate,
        billCounter,
        billNumber,
        note,
        totalAmount,
        isDataChanged,
        errorMessage,
        billType,
        initialBill,
      ];
}
