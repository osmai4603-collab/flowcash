import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'sales_returns_page_event.dart';
import 'sales_returns_page_state.dart';

class SalesReturnsPageBloc
    extends Bloc<SalesReturnsPageEvent, SalesReturnsPageState> {
  final GetBillsUseCase _getBillsUseCase;
  final List<SalesReturnDocument> _returns = [];

  SalesReturnsPageBloc({GetBillsUseCase? getBillsUseCase})
      : _getBillsUseCase = getBillsUseCase ?? GetIt.instance<GetBillsUseCase>(),
        super(SalesReturnsPageInitial()) {
    on<LoadSalesReturnsPageEvent>(_onLoad);
    on<RefreshSalesReturnsPageEvent>(_onLoad);
    on<SearchSalesReturnsPageEvent>(_onSearch);
    on<AddSalesReturnDocumentEvent>(_onAdd);
  }

  Future<void> _onLoad(
    SalesReturnsPageEvent event,
    Emitter<SalesReturnsPageState> emit,
  ) async {
    emit(SalesReturnsPageLoadInProgress());
    final result = await _getBillsUseCase();
    result.match(
      (failure) => emit(SalesReturnsPageOperationFailure(failure.message)),
      (bills) {
        _returns
          ..clear()
          ..addAll(bills.where(_isSalesReturnBill).map(_billToSalesReturnDocument));
        emit(SalesReturnsPageLoadSuccess(List.of(_returns)));
      },
    );
  }

  Future<void> _onSearch(
    SearchSalesReturnsPageEvent event,
    Emitter<SalesReturnsPageState> emit,
  ) async {
    if (state is SalesReturnsPageLoadSuccess) {
      final query = event.query.trim().toLowerCase();
      final filtered = _returns.where((item) {
        return item.returnNumber.toLowerCase().contains(query) ||
            item.customerName.toLowerCase().contains(query) ||
            item.status.toLowerCase().contains(query);
      }).toList();
      emit(SalesReturnsPageLoadSuccess(filtered, query: event.query));
    }
  }

  Future<void> _onAdd(
    AddSalesReturnDocumentEvent event,
    Emitter<SalesReturnsPageState> emit,
  ) async {
    final newReturn = SalesReturnDocument(
      id: _returns.isEmpty ? 1 : _returns.first.id + 1,
      returnNumber: 'R-${DateTime.now().millisecondsSinceEpoch}',
      customerName: 'عميل جديد',
      amount: 0.0,
      status: 'جديد',
      date: DateTime.now(),
    );
    _returns.insert(0, newReturn);
    final filtered = state is SalesReturnsPageLoadSuccess
        ? (state as SalesReturnsPageLoadSuccess)
            .returns
            .where((item) => item.returnNumber
                .toLowerCase()
                .contains((state as SalesReturnsPageLoadSuccess).query.toLowerCase()))
            .toList()
        : List.of(_returns);
    emit(SalesReturnsPageLoadSuccess(filtered,
        query: state is SalesReturnsPageLoadSuccess
            ? (state as SalesReturnsPageLoadSuccess).query
            : ''));
  }

  static bool _isSalesReturnBill(BillEntity bill) {
    return bill.billType == InvoiceType.salesReturn;
  }

  static SalesReturnDocument _billToSalesReturnDocument(BillEntity bill) {
    return SalesReturnDocument(
      id: bill.id,
      returnNumber: bill.billNumber.toString(),
      customerName: _customerNameFromBill(bill),
      amount: bill.offerAmount,
      status: 'مرتجع',
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
