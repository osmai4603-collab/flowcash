import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
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
import 'package:flowcash/user_session.dart';
import 'package:flutter/material.dart';

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
  final UpdateValueCounterUseCase updateValueCounter;
  final UserSession userSession;

  BillFormBloc({
    required this.getCurrencies,
    required this.getExchangePrices,
    required this.getWarehouses,
    required this.getValueCounter,
    required this.getPersons,
    required this.insertBill,
    required this.updateBill,
    required this.updateValueCounter,
    required this.userSession,
  }) : super(BillFormState(
          dateSelected: DateTime.now(),
          firstDate: DateTime.parse('2024-01-01'),
          billType: InvoiceType.sales,
        )) {
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
    on<BillFormSubmitRequested>(_onSubmitRequested);
  }

  Future<void> _onInitRequested(
    BillFormInitRequested event,
    Emitter<BillFormState> emit,
  ) async {
    emit(state.copyWith(status: BillFormStatus.loading, billType: event.billType, initialBill: event.bill));

    try {
      final period = userSession.currentPeriod;
      if (period == null) throw Exception('لا توجد فترة محاسبية مفتوحة.');

      final currenciesResult = await getCurrencies();
      final currencies = currenciesResult.fold((l) => <CurrencyEntity>[], (r) => r);

      final exPricesResult = await getExchangePrices();
      final exPrices = exPricesResult.fold((l) => <ExchangePriceEntity>[], (r) => r);

      final warehousesResult = await getWarehouses();
      final warehouses = warehousesResult.fold((l) => <WarehouseEntity>[], (r) => r);

      final counterType = _getCounterType(event.billType);
      final counterResult = await getValueCounter(counterType);
      final billCounter = counterResult.fold((l) => null, (r) => r);

      final currencyId = period.currencyId;
      final indexOfCurrency = currencies.indexWhere(
        (c) => c.id == currencyId || event.bill?.currencyId == c.id,
      );
      final currencySelected = indexOfCurrency > -1 ? currencies[indexOfCurrency] : (currencies.isNotEmpty ? currencies.first : null);

      emit(state.copyWith(
        status: BillFormStatus.success,
        currencies: currencies,
        exPrices: exPrices,
        warehouses: warehouses,
        billCounter: billCounter,
        billNumber: billCounter?.count ?? 1,
        currencySelected: currencySelected,
        warehouseSelected: userSession.currentWarehouse,
        firstDate: period.dateOfStartPeriod,
        requests: [RequestModel()],
      ));
    } catch (e) {
      emit(state.copyWith(status: BillFormStatus.failure, errorMessage: e.toString()));
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

  void _onCashTypeChanged(BillFormCashTypeChanged event, Emitter<BillFormState> emit) {
    emit(state.copyWith(billCashType: event.cashType, isDataChanged: true));
  }

  void _onWarehouseChanged(BillFormWarehouseChanged event, Emitter<BillFormState> emit) {
    emit(state.copyWith(warehouseSelected: event.warehouse, isDataChanged: true));
  }

  void _onPersonSelected(BillFormPersonSelected event, Emitter<BillFormState> emit) {
    emit(state.copyWith(personSelected: event.person, isDataChanged: true));
  }

  void _onNoteChanged(BillFormNoteChanged event, Emitter<BillFormState> emit) {
    emit(state.copyWith(note: event.note, isDataChanged: true));
  }

  void _onRequestAdded(BillFormRequestAdded event, Emitter<BillFormState> emit) {
    final updatedRequests = List<RequestModel>.from(state.requests)..add(RequestModel());
    emit(state.copyWith(requests: updatedRequests, isDataChanged: true));
  }

  void _onRequestRemoved(BillFormRequestRemoved event, Emitter<BillFormState> emit) {
    final updatedRequests = List<RequestModel>.from(state.requests);
    updatedRequests[event.index].dispose();
    updatedRequests.removeAt(event.index);
    emit(state.copyWith(requests: updatedRequests, isDataChanged: true, totalAmount: _calculateTotal(updatedRequests)));
  }

  void _onCategorySelected(BillFormCategorySelected event, Emitter<BillFormState> emit) {
    final updatedRequests = List<RequestModel>.from(state.requests);
    final request = updatedRequests[event.index];
    request.category = event.category;
    request.categoryNameController.text = event.category?.categoryName ?? '';
    emit(state.copyWith(requests: updatedRequests, isDataChanged: true));
  }

  void _onCountUnitsChanged(BillFormCountUnitsChanged event, Emitter<BillFormState> emit) {
    final updatedRequests = List<RequestModel>.from(state.requests);
    final request = updatedRequests[event.index];
    request.countUnitsController.text = event.value;
    request.totalPriceController.text = AppMoneyFormatter.formatDouble(request.countUnits * request.unitPrice);
    emit(state.copyWith(requests: updatedRequests, isDataChanged: true, totalAmount: _calculateTotal(updatedRequests)));
  }

  void _onUnitPriceChanged(BillFormUnitPriceChanged event, Emitter<BillFormState> emit) {
    final updatedRequests = List<RequestModel>.from(state.requests);
    final request = updatedRequests[event.index];
    request.unitPriceController.text = event.value;
    request.totalPriceController.text = AppMoneyFormatter.formatDouble(request.countUnits * request.unitPrice);
    emit(state.copyWith(requests: updatedRequests, isDataChanged: true, totalAmount: _calculateTotal(updatedRequests)));
  }

  void _onTotalPriceChanged(BillFormTotalPriceChanged event, Emitter<BillFormState> emit) {
    final updatedRequests = List<RequestModel>.from(state.requests);
    final request = updatedRequests[event.index];
    request.totalPriceController.text = event.value;
    if (request.countUnits > 0) {
      request.unitPriceController.text = AppMoneyFormatter.formatDouble(request.totalPrice / request.countUnits);
    }
    emit(state.copyWith(requests: updatedRequests, isDataChanged: true, totalAmount: _calculateTotal(updatedRequests)));
  }

  double _calculateTotal(List<RequestModel> requests) {
    return requests.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _onSubmitRequested(
    BillFormSubmitRequested event,
    Emitter<BillFormState> emit,
  ) async {
    if (state.totalAmount <= 0) {
      emit(state.copyWith(status: BillFormStatus.submitFailure, errorMessage: 'لا يمكن ان تكون اجمالي الفاتورة هو 0'));
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
        orders: state.requests.map((r) => BillOrderEntity(
          id: 0,
          categoryId: r.category!.id,
          countUnits: r.countUnits,
          totalPrice: r.totalPrice,
          billId: 0,
        )).toList(),
      );

      final result = state.initialBill == null ? await insertBill(bill) : await updateBill(bill);
      
      await result.fold(
        (failure) async => emit(state.copyWith(status: BillFormStatus.submitFailure, errorMessage: failure.message)),
        (bill) async {
          if (state.initialBill == null && state.billCounter != null) {
            await updateValueCounter(state.billCounter!.copyWith(
              count: (state.billNumber % state.billCounter!.counterMax) + 1,
            ));
          }
          emit(state.copyWith(status: BillFormStatus.submitSuccess, initialBill: bill));
        },
      );
    } catch (e) {
      emit(state.copyWith(status: BillFormStatus.submitFailure, errorMessage: e.toString()));
    }
  }
}

class RequestModel {
  final unitPriceController = TextEditingController();
  final totalPriceController = TextEditingController();
  final countUnitsController = TextEditingController();
  final categoryNameController = TextEditingController();
  final unitPriceFocusNode = FocusNode();
  final totalPriceFocusNode = FocusNode();
  final countUnitsFocusNode = FocusNode();
  final categoryNameFocusNode = FocusNode();
  SimpleCategoryEntity? category;

  double get unitPrice => double.tryParse(unitPriceController.text.replaceAll(',', '')) ?? 0.0;
  double get totalPrice => double.tryParse(totalPriceController.text.replaceAll(',', '')) ?? 0.0;
  double get countUnits => double.tryParse(countUnitsController.text.replaceAll(',', '')) ?? 0.0;

  RequestModel();

  void dispose() {
    categoryNameController.dispose();
    countUnitsController.dispose();
    unitPriceController.dispose();
    totalPriceController.dispose();
    countUnitsFocusNode.dispose();
    categoryNameFocusNode.dispose();
  }
}
