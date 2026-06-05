import 'package:equatable/equatable.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';

enum BillsStatus { initial, loading, success, error }

class BillsState extends Equatable {
  final List<BillEntity> bills;
  final List<BillOrderEntity> allOrders;
  final BillsStatus status;
  final String? errorMessage;
  final BillEntity? selectedBill;
  final List<BillOrderEntity> selectedBillOrders;

  const BillsState({
    this.bills = const [],
    this.allOrders = const [],
    this.status = BillsStatus.initial,
    this.errorMessage,
    this.selectedBill,
    this.selectedBillOrders = const [],
  });

  BillsState copyWith({
    List<BillEntity>? bills,
    List<BillOrderEntity>? allOrders,
    BillsStatus? status,
    String? errorMessage,
    BillEntity? selectedBill,
    List<BillOrderEntity>? selectedBillOrders,
  }) {
    return BillsState(
      bills: bills ?? this.bills,
      allOrders: allOrders ?? this.allOrders,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedBill: selectedBill ?? this.selectedBill,
      selectedBillOrders: selectedBillOrders ?? this.selectedBillOrders,
    );
  }

  BillsState addBill(BillEntity bill, List<BillOrderEntity> orders) {
    return copyWith(
      bills: [bill, ...bills],
      allOrders: [...orders, ...allOrders],
      status: BillsStatus.success,
    );
  }

  BillsState updateBill(BillEntity bill, List<BillOrderEntity> orders) {
    final updatedBills = bills.map((b) => b.id == bill.id ? bill : b).toList();
    final updatedOrders = allOrders.where((o) => o.billId != bill.id).toList()..addAll(orders);

    return copyWith(
      bills: updatedBills,
      allOrders: updatedOrders,
      selectedBill: selectedBill?.id == bill.id ? bill : selectedBill,
      selectedBillOrders: selectedBill?.id == bill.id ? orders : selectedBillOrders,
      status: BillsStatus.success,
    );
  }

  BillsState removeBill(int id) {
    final updatedBills = bills.where((b) => b.id != id).toList();
    final updatedOrders = allOrders.where((o) => o.billId != id).toList();

    return copyWith(
      bills: updatedBills,
      allOrders: updatedOrders,
      selectedBill: selectedBill?.id == id ? null : selectedBill,
      selectedBillOrders: selectedBill?.id == id ? const [] : selectedBillOrders,
      status: BillsStatus.success,
    );
  }

  BillsState toError(String message) {
    return copyWith(
      status: BillsStatus.error,
      errorMessage: message,
    );
  }

  BillsState toLoading() {
    return copyWith(
      status: BillsStatus.loading,
    );
  }

  @override
  List<Object?> get props => [
        bills,
        allOrders,
        status,
        errorMessage,
        selectedBill,
        selectedBillOrders,
      ];
}
