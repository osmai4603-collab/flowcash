import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';
import 'package:flowcash/core/enums/value_counter_type_enum.dart';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/usecases/person_repository_usecases.dart';
import 'package:flowcash/core/usecases/value_counter_repository_usecases.dart';
import 'package:flowcash/features/categories/domain/entities/simple_category_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'package:flowcash/features/transactions/domain/usecases/post_bill_to_accounting_use_case.dart';
import 'package:flowcash/user_session.dart';
import 'package:flutter/material.dart';

import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';

part 'bill_form_event.dart';
part 'bill_form_state.dart';

enum BillCashType {
  cash(typeName: 'نقدا'),
  future(typeName: 'اجل');

  final String typeName;
  const BillCashType({required this.typeName});

  bool get isCash => this == BillCashType.cash;
}

class BillFormBloc extends Bloc<BillFormEvent, BillFormState> {
  final GetCurrenciesUseCase getCurrencies;
  final GetExchangePricesUseCase getExchangePrices;
  final GetWarehousesUseCase getWarehouses;
  final GetValueCounterByCounterTypeUseCase getValueCounter;
  final GetPersonsUseCase getPersons;
  final InsertBillUseCase insertBill;
  final UpdateBillUseCase updateBill;
  final PostBillToAccountingUseCase postBillToAccounting;
  final UpdateValueCounterUseCase updateValueCounter;
  final GetCategoriesWhereContainsNameUseCase getCategoriesWhereContainsName;
  final UserSession userSession;

  List<WarehouseEntity> warehouses = [];
  List<CurrencyEntity> currencies = [];
  List<ExchangePriceEntity> exPrices = [];
  List<PersonEntity> treasuries = [];
  ValueCounterEntity? billCounter;

  BillFormBloc({
    required this.getCurrencies,
    required this.getExchangePrices,
    required this.getWarehouses,
    required this.getValueCounter,
    required this.getPersons,
    required this.insertBill,
    required this.updateBill,
    required this.postBillToAccounting,
    required this.updateValueCounter,
    required this.getCategoriesWhereContainsName,
    required this.userSession,
  }) : super(
         BillFormState(
           dateSelected: DateTime.now(),
           firstDate: DateTime.parse('2024-01-01'),
           billType: InvoiceType.sales,
         ),
       ) {
    on<BillFormInitRequested>(_onInitRequested);
    on<BillFormDateChanged>(_onDateChanged);
    on<BillFormCashTypeChanged>(_onCashTypeChanged);
    on<BillFormWarehouseChanged>(_onWarehouseChanged);
    on<BillFormPersonSelected>(_onPersonSelected);
    on<BillFormNoteChanged>(_onNoteChanged);
    on<BillFormRequestAdded>(_onRequestAdded);
    on<BillFormRequestRemoved>(_onRequestRemoved);
    on<BillFormCategorySelected>(_onCategorySelected);
    on<BillFormCountUnitsChanged>(_onCountUnitsChanged);
    on<BillFormUnitPriceChanged>(_onUnitPriceChanged);
    on<BillFormTotalPriceChanged>(_onTotalPriceChanged);
    on<BillFormCurrencyChanged>(_onCurrencyChanged);
    on<BillFormTreasurySelected>(_onTreasurySelected);
    on<BillFormSubmitRequested>(_onSubmitRequested);
  }

  Future<List<PersonEntity>> searchPersons(String value) async {
    final result = await getPersons.call();
    return result.fold(
      (l) => [],
      (r) => r.where((p) => p.personName.contains(value)).toList(),
    );
  }

  Future<List<SimpleCategoryEntity>> searchCategories(String value) async {
    final result = await getCategoriesWhereContainsName.call(value);
    return result.fold((l) => [], (r) => r);
  }

  Future<void> _onInitRequested(
    BillFormInitRequested event,
    Emitter<BillFormState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BillFormStatus.loading,
        billType: event.billType,
        initialBill: event.bill,
      ),
    );

    try {
      final period = userSession.currentPeriod;
      if (period == null) throw Exception('لا توجد فترة محاسبية مفتوحة.');

      final currenciesResult = await getCurrencies();
      currencies = currenciesResult.fold(
        (l) => <CurrencyEntity>[],
        (r) => r,
      );

      final exPricesResult = await getExchangePrices();
      exPrices = exPricesResult.fold(
        (l) => <ExchangePriceEntity>[],
        (r) => r,
      );

      final warehousesResult = await getWarehouses();
      warehouses = warehousesResult.fold(
        (l) => <WarehouseEntity>[],
        (r) => r,
      );

      final counterType = _getCounterType(event.billType);
      final counterResult = await getValueCounter(counterType);
      billCounter = counterResult.fold((l) => null, (r) => r);

      // Load cash treasuries (persons with type cash or bank)
      final personsResult = await getPersons();
      treasuries = personsResult.fold(
        (l) => <PersonEntity>[],
        (r) => r
            .where(
              (p) =>
                  p.personType == PersonType.cash ||
                  p.personType == PersonType.bank,
            )
            .toList(),
      );

      final currencyId = period.currencyId;
      final indexOfCurrency = currencies.indexWhere(
        (c) => c.id == currencyId || event.bill?.currencyId == c.id,
      );
      final currencySelected = indexOfCurrency > -1
          ? currencies[indexOfCurrency]
          : (currencies.isNotEmpty ? currencies.first : null);

      emit(
        state.copyWith(
          status: BillFormStatus.success,
          billNumber: billCounter?.count ?? 1,
          currencySelected: currencySelected,
          warehouseSelected: userSession.currentWarehouse,
          firstDate: period.dateOfStartPeriod,
          requests: [RequestModel()],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BillFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  ValueCounterType _getCounterType(InvoiceType billType) {
    switch (billType) {
      case InvoiceType.sales:
        return ValueCounterType.salesInvoiceNumber;
      case InvoiceType.buys:
        return ValueCounterType.purchaseInvoiceNumber;
      case InvoiceType.buysReturn:
        return ValueCounterType.purchaseReturnInvoiceNumber;
      case InvoiceType.salesReturn:
        return ValueCounterType.salesReturnInvoiceNumber;
      default:
        return ValueCounterType.salesInvoiceNumber;
    }
  }

  void _onDateChanged(BillFormDateChanged event, Emitter<BillFormState> emit) {
    emit(state.copyWith(dateSelected: event.date, isDataChanged: true));
  }

  void _onCashTypeChanged(
    BillFormCashTypeChanged event,
    Emitter<BillFormState> emit,
  ) {
    if (event.cashType == BillCashType.future) {
      // When switching to آجل, clear the treasury selection
      emit(state.copyWith(
        billCashType: event.cashType,
        isDataChanged: true,
        treasurySelected: const PersonEntity(id: 0, personType: PersonType.cash),
      ));
    } else {
      emit(state.copyWith(billCashType: event.cashType, isDataChanged: true));
    }
  }

  void _onWarehouseChanged(
    BillFormWarehouseChanged event,
    Emitter<BillFormState> emit,
  ) {
    emit(
      state.copyWith(warehouseSelected: event.warehouse, isDataChanged: true),
    );
  }

  void _onPersonSelected(
    BillFormPersonSelected event,
    Emitter<BillFormState> emit,
  ) {
    emit(state.copyWith(personSelected: event.person, isDataChanged: true));
  }

  void _onNoteChanged(BillFormNoteChanged event, Emitter<BillFormState> emit) {
    emit(state.copyWith(note: event.note, isDataChanged: true));
  }

  void _onRequestAdded(
    BillFormRequestAdded event,
    Emitter<BillFormState> emit,
  ) {
    final updatedRequests = List<RequestModel>.from(state.requests)
      ..add(RequestModel());
    emit(state.copyWith(requests: updatedRequests, isDataChanged: true));
  }

  void _onRequestRemoved(
    BillFormRequestRemoved event,
    Emitter<BillFormState> emit,
  ) {
    final updatedRequests = List<RequestModel>.from(state.requests);
    updatedRequests[event.index].dispose();
    updatedRequests.removeAt(event.index);
    emit(
      state.copyWith(
        requests: updatedRequests,
        isDataChanged: true,
        totalAmount: _calculateTotal(updatedRequests),
      ),
    );
  }

  void _onCurrencyChanged(
    BillFormCurrencyChanged event,
    Emitter<BillFormState> emit,
  ) {
    emit(state.copyWith(currencySelected: event.currency, isDataChanged: true));
  }

  void _onTreasurySelected(
    BillFormTreasurySelected event,
    Emitter<BillFormState> emit,
  ) {
    emit(state.copyWith(treasurySelected: event.treasury, isDataChanged: true));
  }

  void _onCategorySelected(
    BillFormCategorySelected event,
    Emitter<BillFormState> emit,
  ) {
    final updatedRequests = List<RequestModel>.from(state.requests);
    updatedRequests[event.index] = updatedRequests[event.index].copyWith(
      category: event.category,
    );
    emit(state.copyWith(requests: updatedRequests, isDataChanged: true));
  }

  void _onCountUnitsChanged(
    BillFormCountUnitsChanged event,
    Emitter<BillFormState> emit,
  ) {
    final updatedRequests = List<RequestModel>.from(state.requests);
    final request = updatedRequests[event.index];
    request.totalPriceController.text = AppMoneyFormatter.formatDouble(
      request.countUnits * request.unitPrice,
    );
    emit(
      state.copyWith(
        requests: updatedRequests,
        isDataChanged: true,
        totalAmount: _calculateTotal(updatedRequests),
      ),
    );
  }

  void _onUnitPriceChanged(
    BillFormUnitPriceChanged event,
    Emitter<BillFormState> emit,
  ) {
    final updatedRequests = List<RequestModel>.from(state.requests);
    final request = updatedRequests[event.index];
    request.totalPriceController.text = AppMoneyFormatter.formatDouble(
      request.countUnits * request.unitPrice,
    );
    emit(
      state.copyWith(
        requests: updatedRequests,
        isDataChanged: true,
        totalAmount: _calculateTotal(updatedRequests),
      ),
    );
  }

  void _onTotalPriceChanged(
    BillFormTotalPriceChanged event,
    Emitter<BillFormState> emit,
  ) {
    final updatedRequests = List<RequestModel>.from(state.requests);
    final request = updatedRequests[event.index];
    if (request.countUnits > 0) {
      request.unitPriceController.text = AppMoneyFormatter.formatDouble(
        request.totalPrice / request.countUnits,
      );
    }
    emit(
      state.copyWith(
        requests: updatedRequests,
        isDataChanged: true,
        totalAmount: _calculateTotal(updatedRequests),
      ),
    );
  }

  double _calculateTotal(List<RequestModel> requests) {
    return requests.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _onSubmitRequested(
    BillFormSubmitRequested event,
    Emitter<BillFormState> emit,
  ) async {
    if (state.totalAmount <= 0) {
      emit(
        state.copyWith(
          status: BillFormStatus.submitFailure,
          errorMessage: 'لا يمكن ان تكون اجمالي الفاتورة هو 0',
        ),
      );
      return;
    }

    // Validate treasury for cash bills
    if (state.billCashType.isCash &&
        (state.treasurySelected == null || state.treasurySelected!.id == 0)) {
      emit(
        state.copyWith(
          status: BillFormStatus.submitFailure,
          errorMessage: 'يجب اختيار الحساب النقدي للفاتورة النقدية',
        ),
      );
      return;
    }

    emit(state.copyWith(status: BillFormStatus.submitting));

    try {
      final bill = BillEntity(
        id: state.initialBill?.id ?? 0,
        createdAt: state.dateSelected,
        createdBy: userSession.currentUser!.id,
        note: state.note.trim().isEmpty ? null : state.note,
        offerAmount: state.totalAmount,
        currencyId: state.currencySelected!.id,
        billNumber: state.billNumber,
        warehouseId: state.warehouseSelected!.id,
        personId: state.personSelected!.id,
        isCash: state.billCashType.isCash,
        billType: state.billType,
        treasuryId: state.billCashType.isCash
            ? state.treasurySelected?.id
            : null,
        orders: state.requests
            .map(
              (r) => BillOrderEntity(
                id: 0,
                categoryId: r.category!.id,
                countUnits: r.countUnits,
                totalPrice: r.totalPrice,
                billId: 0,
              ),
            )
            .toList(),
      );

      final result = state.initialBill == null
          ? await insertBill(bill)
          : await updateBill(bill);

      await result.fold(
        (failure) async => emit(
          state.copyWith(
            status: BillFormStatus.submitFailure,
            errorMessage: failure.message,
          ),
        ),
        (bill) async {
          if (state.initialBill == null && billCounter != null) {
            await updateValueCounter(
              billCounter!.copyWith(
                count: (state.billNumber % billCounter!.counterMax) + 1,
              ),
            );
          }

          final postResult = await postBillToAccounting(
            bill: bill,
            userId: userSession.currentUser!.id,
            currencyId: state.currencySelected!.id,
            exPrices: exPrices,
          );

          final postedBill = postResult.fold((f) => bill, (b) => b);

          emit(
            state.copyWith(
              status: BillFormStatus.submitSuccess,
              initialBill: postedBill,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BillFormStatus.submitFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

class RequestModel {
  final TextEditingController unitPriceController;
  final TextEditingController totalPriceController;
  final TextEditingController countUnitsController;
  final TextEditingController categoryNameController;
  final FocusNode unitPriceFocusNode;
  final FocusNode totalPriceFocusNode;
  final FocusNode countUnitsFocusNode;
  final FocusNode categoryNameFocusNode;
  final SimpleCategoryEntity? category;

  double get unitPrice =>
      double.tryParse(unitPriceController.text.replaceAll(',', '')) ?? 0.0;
  double get totalPrice =>
      double.tryParse(totalPriceController.text.replaceAll(',', '')) ?? 0.0;
  double get countUnits =>
      double.tryParse(countUnitsController.text.replaceAll(',', '')) ?? 0.0;

  RequestModel({
    TextEditingController? unitPriceController,
    TextEditingController? totalPriceController,
    TextEditingController? countUnitsController,
    TextEditingController? categoryNameController,
    FocusNode? unitPriceFocusNode,
    FocusNode? totalPriceFocusNode,
    FocusNode? countUnitsFocusNode,
    FocusNode? categoryNameFocusNode,
    this.category,
  }) : unitPriceController = unitPriceController ?? TextEditingController(),
       totalPriceController = totalPriceController ?? TextEditingController(),
       countUnitsController = countUnitsController ?? TextEditingController(),
       categoryNameController =
           categoryNameController ?? TextEditingController(),
       unitPriceFocusNode = unitPriceFocusNode ?? FocusNode(),
       totalPriceFocusNode = totalPriceFocusNode ?? FocusNode(),
       countUnitsFocusNode = countUnitsFocusNode ?? FocusNode(),
       categoryNameFocusNode = categoryNameFocusNode ?? FocusNode();

  RequestModel copyWith({SimpleCategoryEntity? category}) {
    return RequestModel(
      category: category ?? this.category,
      unitPriceController: unitPriceController,
      totalPriceController: totalPriceController,
      countUnitsController: countUnitsController,
      categoryNameController: categoryNameController,
      unitPriceFocusNode: unitPriceFocusNode,
      totalPriceFocusNode: totalPriceFocusNode,
      countUnitsFocusNode: countUnitsFocusNode,
      categoryNameFocusNode: categoryNameFocusNode,
    );
  }

  void dispose() {
    categoryNameController.dispose();
    countUnitsController.dispose();
    unitPriceController.dispose();
    totalPriceController.dispose();
    unitPriceFocusNode.dispose();
    totalPriceFocusNode.dispose();
    countUnitsFocusNode.dispose();
    categoryNameFocusNode.dispose();
  }
}
