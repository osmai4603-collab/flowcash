part of 'bill_form_bloc.dart';

abstract class BillFormEvent {}

class SubmitBillEvent extends BillFormEvent {
  final BillEntity bill;
  final List<BillOrderEntity> orders;

  SubmitBillEvent({required this.bill, required this.orders});
}

class UpdateBillEvent extends BillFormEvent {
  final BillEntity bill;
  final List<BillOrderEntity> orders;

  UpdateBillEvent({required this.bill, required this.orders});
}


class InitBillFormEvent extends BillFormEvent {
  final BillEntity? saleBill;
   InitBillFormEvent({this.saleBill});

   List<BillEntity?> get props => [saleBill];
}
