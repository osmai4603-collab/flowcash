part of 'bill_form_bloc.dart';

abstract class BillFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BillFormInitial extends BillFormState {}

class BillFormLoading extends BillFormState {}

class BillFormSuccess extends BillFormState {
  final BillEntity bill;
  BillFormSuccess({required this.bill});

  @override
  List<Object?> get props => [bill];
}

class BillFormFailure extends BillFormState {
  final String message;
  BillFormFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
