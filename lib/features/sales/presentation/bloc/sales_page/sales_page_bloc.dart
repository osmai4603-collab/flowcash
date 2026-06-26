import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'package:flowcash/features/transactions/domain/usecases/post_bill_to_accounting_use_case.dart';
import 'package:flowcash/features/transactions/domain/usecases/post_bill_to_inventory_use_case.dart';
import 'package:flowcash/features/transactions/domain/usecases/post_bill_to_costing_use_case.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';
import 'package:flowcash/user_session.dart';
import 'sales_page_event.dart';
import 'sales_page_state.dart';

class SalesPageBloc extends Bloc<SalesPageEvent, SalesPageState> {
  final GetBillsWithCustomerUseCase _getBillsWithCustomerUseCase;
  final DeleteBillUseCase _deleteBillUseCase;
  final PostBillToAccountingUseCase _postBillToAccountingUseCase;
  final PostBillToInventoryUseCase _postBillToInventoryUseCase;
  final PostBillToCostingUseCase _postBillToCostingUseCase;
  final GetExchangePricesUseCase _getExchangePricesUseCase;
  final UserSession _userSession;
  final List<SalesDocument> _sales = [];

  SalesPageBloc({
    GetBillsWithCustomerUseCase? getBillsWithCustomerUseCase,
    DeleteBillUseCase? deleteBillUseCase,
    PostBillToAccountingUseCase? postBillToAccountingUseCase,
    PostBillToInventoryUseCase? postBillToInventoryUseCase,
    PostBillToCostingUseCase? postBillToCostingUseCase,
    GetExchangePricesUseCase? getExchangePricesUseCase,
    UserSession? userSession,
  }) : _getBillsWithCustomerUseCase = getBillsWithCustomerUseCase ??
           GetIt.instance<GetBillsWithCustomerUseCase>(),
       _deleteBillUseCase =
           deleteBillUseCase ?? GetIt.instance<DeleteBillUseCase>(),
       _postBillToAccountingUseCase = postBillToAccountingUseCase ??
           GetIt.instance<PostBillToAccountingUseCase>(),
       _postBillToInventoryUseCase = postBillToInventoryUseCase ??
           GetIt.instance<PostBillToInventoryUseCase>(),
       _postBillToCostingUseCase = postBillToCostingUseCase ??
           GetIt.instance<PostBillToCostingUseCase>(),
       _getExchangePricesUseCase = getExchangePricesUseCase ??
           GetIt.instance<GetExchangePricesUseCase>(),
       _userSession = userSession ?? GetIt.instance<UserSession>(),
       super(SalesPageInitial()) {
    on<LoadSalesPageEvent>(_onLoad);
    on<RefreshSalesPageEvent>(_onLoad);
    on<SearchSalesPageEvent>(_onSearch);
    on<AddSalesDocumentEvent>(_onAdd);
    on<UpdateSalesDocumentEvent>(_onUpdate);
    on<DeleteSalesDocumentEvent>(_onDelete);
    on<PostSalesDocumentToAccountingEvent>(_onPostToAccounting);
    on<PostSalesDocumentToInventoryEvent>(_onPostToInventory);
    on<PostSalesDocumentToCostingEvent>(_onPostToCosting);
  }

  Future<void> _onLoad(
    SalesPageEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    emit(SalesPageLoadInProgress());
    final result = await _getBillsWithCustomerUseCase();
    result.match(
      (failure) => emit(SalesPageOperationFailure(failure.message)),
      (billsData) {
        _sales.clear();
        for (final data in billsData) {
          final bill = _mapMapToBillEntity(data);
          if (_isSalesBill(bill)) {
            _sales.add(_mapToSalesDocument(bill, data['customerName'] as String?));
          }
        }
        emit(SalesPageLoadSuccess(List.of(_sales)));
      },
    );
  }

  BillEntity _mapMapToBillEntity(Map<String, dynamic> data) {
    // We need to use fromMap logic here or similar.
    // Since we don't have access to BillLocalDataSourceImpl.fromMap easily,
    // we can reconstruct it manually or use a helper.
    return BillEntity(
      id: data['bill_id'] as int,
      createdAt: DateTime.parse(data['create_at'] as String),
      createdBy: data['create_by'] as int,
      note: data['note'] as String?,
      offerAmount: (data['amount'] as num).toDouble(),
      currencyId: data['currency_id'] as String,
      billNumber: data['bill_number'] as int,
      warehouseId: data['warehouse_id'] as int,
      journalEntryId: data['journal_entry_id'] as int?,
      personId: data['person_id'] as int?,
      inventoryTransactionId: data['inventory_transaction_id'] as int?,
      isCash: (data['is_cash'] == 1 || data['is_cash'] == true),
      billType: InvoiceType.of(data['bill_type'] as String? ?? 'sales'),
      costGoodId: data['cost_good_id'] as int?,
      treasuryId: data['treasury_id'] as int?,
    );
  }

  static SalesDocument _mapToSalesDocument(BillEntity bill, String? customerName) {
    return SalesDocument(
      billId: bill.id,
      customerName: customerName ?? _customerNameFromBill(bill),
      totalAmount: bill.offerAmount,
      currencyId: bill.currencyId,
      createdAt: bill.createdAt,
      journalStatusId: bill.journalEntryId,
      costOfGoodId: bill.costGoodId,
      inventoryTransactionId: bill.inventoryTransactionId,
      billType: bill.billType,
      isCash: bill.isCash,
      billNumber: bill.billNumber,
      rawBill: bill,
    );
  }

  Future<void> _onSearch(
    SearchSalesPageEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    if (state is SalesPageLoadSuccess) {
      final query = event.query.trim().toLowerCase();
      final filtered = _sales.where((sale) {
        return sale.billHistory.toLowerCase().contains(query) ||
            sale.customerName.toLowerCase().contains(query);
      }).toList();
      emit(SalesPageLoadSuccess(filtered, query: event.query));
    }
  }

  Future<void> _onAdd(
    AddSalesDocumentEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    final newSale = _mapToSalesDocument(event.bill, null);
    _sales.insert(0, newSale);
    _emitUpdatedList(emit);
  }

  Future<void> _onUpdate(
    UpdateSalesDocumentEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    final index = _sales.indexWhere((sale) => sale.billId == event.bill.id);
    if (index != -1) {
      _sales[index] = _mapToSalesDocument(event.bill, null);
    }
    _emitUpdatedList(emit);
  }

  Future<void> _onDelete(
    DeleteSalesDocumentEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    final result = await _deleteBillUseCase(event.billId);
    result.fold((failure) => emit(SalesPageOperationFailure(failure.message)), (
      _,
    ) {
      _sales.removeWhere((sale) => sale.billId == event.billId);
      _emitUpdatedList(emit);
    });
  }

  Future<void> _onPostToAccounting(
    PostSalesDocumentToAccountingEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    if (event.doc.isJournalPosted) {
      emit(const SalesPageOperationFailure('هذه الفاتورة مرحلة محاسبياً بالفعل.'));
      return;
    }

    final exPricesResult = await _getExchangePricesUseCase();
    final exPrices = exPricesResult.fold((l) => null, (r) => r);
    if (exPrices == null) {
      emit(const SalesPageOperationFailure('فشل جلب أسعار الصرف.'));
      return;
    }

    final user = _userSession.currentUser;
    if (user == null) {
      emit(const SalesPageOperationFailure('لم يتم العثور على جلسة مستخدم.'));
      return;
    }

    final result = await _postBillToAccountingUseCase(
      bill: event.doc.rawBill,
      userId: user.id,
      currencyId: event.doc.rawBill.currencyId,
      exPrices: exPrices,
    );

    result.fold(
      (failure) => emit(SalesPageOperationFailure(failure.message)),
      (postedBill) {
        final index = _sales.indexWhere((sale) => sale.billId == postedBill.id);
        if (index != -1) {
          _sales[index] = _mapToSalesDocument(postedBill, event.doc.customerName);
        }
        _emitUpdatedList(emit);
        emit(const SalesPageOperationSuccess('تم الترحيل المحاسبي بنجاح.'));
      },
    );
  }

  Future<void> _onPostToInventory(
    PostSalesDocumentToInventoryEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    if (event.doc.isInventoryPosted) {
      emit(const SalesPageOperationFailure('هذه الفاتورة مرحلة مخزنياً بالفعل.'));
      return;
    }

    final user = _userSession.currentUser;
    if (user == null) {
      emit(const SalesPageOperationFailure('لم يتم العثور على جلسة مستخدم.'));
      return;
    }

    final result = await _postBillToInventoryUseCase(
      bill: event.doc.rawBill,
      userId: user.id,
    );

    result.fold(
      (failure) => emit(SalesPageOperationFailure(failure.message)),
      (postedBill) {
        final index = _sales.indexWhere((sale) => sale.billId == postedBill.id);
        if (index != -1) {
          _sales[index] = _mapToSalesDocument(postedBill, event.doc.customerName);
        }
        _emitUpdatedList(emit);
        emit(const SalesPageOperationSuccess('تم الترحيل المخزني بنجاح.'));
      },
    );
  }

  Future<void> _onPostToCosting(
    PostSalesDocumentToCostingEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    if (event.doc.isCostGoodPosted) {
      emit(const SalesPageOperationFailure('تكلفة هذه الفاتورة مرحلة بالفعل.'));
      return;
    }

    final user = _userSession.currentUser;
    if (user == null) {
      emit(const SalesPageOperationFailure('لم يتم العثور على جلسة مستخدم.'));
      return;
    }

    final result = await _postBillToCostingUseCase(
      bill: event.doc.rawBill,
      userId: user.id,
    );

    result.fold(
      (failure) => emit(SalesPageOperationFailure(failure.message)),
      (postedBill) {
        final index = _sales.indexWhere((sale) => sale.billId == postedBill.id);
        if (index != -1) {
          _sales[index] = _mapToSalesDocument(postedBill, event.doc.customerName);
        }
        _emitUpdatedList(emit);
        emit(const SalesPageOperationSuccess('تم ترحيل التكلفة بنجاح.'));
      },
    );
  }

  void _emitUpdatedList(Emitter<SalesPageState> emit) {
    final query = state is SalesPageLoadSuccess
        ? (state as SalesPageLoadSuccess).query
        : '';
    final filteredSales = query.trim().isNotEmpty
        ? _sales.where((sale) {
            return sale.billHistory.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                sale.customerName.toLowerCase().contains(query.toLowerCase());
          }).toList()
        : List.of(_sales);
    emit(SalesPageLoadSuccess(filteredSales, query: query));
  }

  static bool _isSalesBill(BillEntity bill) {
    return bill.billType == InvoiceType.sales;
  }

  static String _customerNameFromBill(BillEntity bill) {
    if (bill.personId != null) {
      return 'عميل ${bill.personId}';
    }
    final cleanNote = (bill.note ?? '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .trim();
    if (cleanNote.isNotEmpty) {
      return cleanNote;
    }
    return 'عميل غير محدد';
  }
}
