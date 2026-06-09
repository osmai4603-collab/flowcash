import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'sales_page_event.dart';
import 'sales_page_state.dart';

class SalesPageBloc extends Bloc<SalesPageEvent, SalesPageState> {
  final GetBillsUseCase _getBillsUseCase;
  final List<SalesDocument> _sales = [];

  SalesPageBloc({GetBillsUseCase? getBillsUseCase})
      : _getBillsUseCase = getBillsUseCase ?? GetIt.instance<GetBillsUseCase>(),
        super(SalesPageInitial()) {
    on<LoadSalesPageEvent>(_onLoad);
    on<RefreshSalesPageEvent>(_onLoad);
    on<SearchSalesPageEvent>(_onSearch);
    on<AddSalesDocumentEvent>(_onAdd);
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
        return sale.invoiceNumber.toLowerCase().contains(query) ||
            sale.customerName.toLowerCase().contains(query) ||
            sale.status.toLowerCase().contains(query);
      }).toList();
      emit(SalesPageLoadSuccess(filtered, query: event.query));
    }
  }

  Future<void> _onAdd(
    AddSalesDocumentEvent event,
    Emitter<SalesPageState> emit,
  ) async {
    final newSale = SalesDocument(
      id: _sales.isEmpty ? 1 : _sales.first.id + 1,
      invoiceNumber: 'S-${DateTime.now().millisecondsSinceEpoch}',
      customerName: 'عميل جديد',
      amount: 0.0,
      status: 'جديد',
      date: DateTime.now(),
    );
    _sales.insert(0, newSale);
    final filteredSales = state is SalesPageLoadSuccess
        ? (state as SalesPageLoadSuccess)
            .sales
            .where((sale) => sale.invoiceNumber
                .toLowerCase()
                .contains((state as SalesPageLoadSuccess).query.toLowerCase()))
            .toList()
        : List.of(_sales);
    emit(SalesPageLoadSuccess(filteredSales,
        query: state is SalesPageLoadSuccess ? (state as SalesPageLoadSuccess).query : ''));
  }

  static bool _isSalesBill(BillEntity bill) {
    return bill.billType == InvoiceType.sales;
  }

  static SalesDocument _billToSalesDocument(BillEntity bill) {
    return SalesDocument(
      id: bill.id,
      invoiceNumber: bill.billNumber.toString(),
      customerName: _customerNameFromBill(bill),
      amount: bill.offerAmount,
      status: bill.note?.contains('مرتجع') == true
          ? 'مرتجع'
          : (bill.isCash ? 'نقدي' : 'آجل'),
      date: bill.createdAt,
    );
  }

  static String _customerNameFromBill(BillEntity bill) {
    if (bill.personId != null) {
      return 'عميل ${bill.personId}';
    }
    final cleanNote = (bill.note ?? '').replaceAll(RegExp(r'\[.*?\]'), '').trim();
    if (cleanNote.isNotEmpty) {
      return cleanNote;
    }
    return 'عميل غير محدد';
  }
}
