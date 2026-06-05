import 'package:equatable/equatable.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';

abstract class BillsEvent extends Equatable {
  const BillsEvent();

  @override
  List<Object?> get props => [];
}

class LoadBillsEvent extends BillsEvent {}

class AddBillEvent extends BillsEvent {
  final BillEntity bill;
  final List<BillOrderEntity> orders;

  const AddBillEvent({required this.bill, required this.orders});

  @override
  List<Object?> get props => [bill, orders];
}

class UpdateBillEvent extends BillsEvent {
  final BillEntity bill;
  final List<BillOrderEntity> orders;

  const UpdateBillEvent({required this.bill, required this.orders});

  @override
  List<Object?> get props => [bill, orders];
}

class DeleteBillEvent extends BillsEvent {
  final int id;

  const DeleteBillEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectBillEvent extends BillsEvent {
  final BillEntity? bill;

  const SelectBillEvent(this.bill);

  @override
  List<Object?> get props => [bill];
}
