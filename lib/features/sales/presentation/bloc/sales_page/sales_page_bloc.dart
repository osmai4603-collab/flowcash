import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'sales_page_event.dart';
import 'sales_page_state.dart';

class SalesPageBloc extends Bloc<SalesPageEvent, SalesPageState> {
  final GetBillsUseCase _getBillsUseCase;
  final DeleteBillUseCase _deleteBillUseCase;
  final List<SalesDocument> _sales = [];

  SalesPageBloc({
    GetBillsUseCase? getBillsUseCase,
    DeleteBillUseCase? deleteBillUseCase,
  }) : _getBillsUseCase = getBillsUseCase ?? GetIt.instance<GetBillsUseCase>(),
       _deleteBillUseCase =
           deleteBillUseCase ?? GetIt.instance<DeleteBillUseCase>(),
       super(SalesPageInitial()) {
    on<LoadSalesPageEvent>(_onLoad);
    on<RefreshSalesPageEvent>(_onLoad);
    on<SearchSalesPageEvent>(_onSearch);
    on<AddSalesDocumentEvent>(_onAdd);
    on<UpdateSalesDocumentEvent>(_onUpdate);
    on<DeleteSalesDocumentEvent>(_onDelete);
  }

  Future<void> _onLoad(
    SalesPageEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    emit(SalesPageLoadInProgress());
    final result = await _getBillsUseCase();
    result.match(
      (failure) => emit(SalesPageOperationFailure(failure.message)),
      (bills) {
        _sales
          ..clear()
          ..addAll(bills.where(_isSalesBill).map(_billToSalesDocument));
        emit(SalesPageLoadSuccess(List.of(_sales)));
      },
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
    final newSale = _billToSalesDocument(event.bill);
    _sales.insert(0, newSale);
    _emitUpdatedList(emit);
  }

  Future<void> _onUpdate(
    UpdateSalesDocumentEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    final index = _sales.indexWhere((sale) => sale.id == event.bill.id);
    if (index != -1) {
      _sales[index] = _billToSalesDocument(event.bill);
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
      _sales.removeWhere((sale) => sale.id == event.billId);
      _emitUpdatedList(emit);
    });
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

  static SalesDocument _billToSalesDocument(BillEntity bill) {
    return SalesDocument(
      id: bill.id,
      billHistory: bill.billHistory,
      customerName: _customerNameFromBill(bill),
      amount: bill.offerAmount,
      currencySymbol: bill.currencyId, // _getCurrencySymbol(bill.currencyId),
      date: bill.createdAt,
      isJournalPosted: bill.journalEntryId != null,
      isInventoryPosted: bill.inventoryTransactionId != null,
      isCostGoodPosted: bill.costGoodId != null,
      rawBill: bill,
    );
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
