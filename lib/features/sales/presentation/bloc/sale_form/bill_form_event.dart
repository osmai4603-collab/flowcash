part of 'bill_form_bloc.dart';

abstract class BillFormEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BillFormInitRequested extends BillFormEvent {
  final BillEntity? bill;
  final InvoiceType billType;

  BillFormInitRequested({this.bill, required this.billType});

  @override
  List<Object?> get props => [bill, billType];
}

class BillFormDateChanged extends BillFormEvent {
  final DateTime date;
  BillFormDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class BillFormCashTypeChanged extends BillFormEvent {
  final BillCashType cashType;
  BillFormCashTypeChanged(this.cashType);

  @override
  List<Object?> get props => [cashType];
}

class BillFormWarehouseChanged extends BillFormEvent {
  final WarehouseEntity warehouse;
  BillFormWarehouseChanged(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

class BillFormPersonSelected extends BillFormEvent {
  final PersonEntity? person;
  BillFormPersonSelected(this.person);

  @override
  List<Object?> get props => [person];
}

class BillFormNoteChanged extends BillFormEvent {
  final String note;
  BillFormNoteChanged(this.note);

  @override
  List<Object?> get props => [note];
}

class BillFormRequestAdded extends BillFormEvent {}

class BillFormRequestRemoved extends BillFormEvent {
  final int index;
  BillFormRequestRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class BillFormCategorySelected extends BillFormEvent {
  final int index;
  final SimpleCategoryEntity? category;
  BillFormCategorySelected(this.index, this.category);

  @override
  List<Object?> get props => [index, category];
}

class BillFormCountUnitsChanged extends BillFormEvent {
  final int index;
  final String value;
  BillFormCountUnitsChanged(this.index, this.value);

  @override
  List<Object?> get props => [index, value];
}

class BillFormUnitPriceChanged extends BillFormEvent {
  final int index;
  final String value;
  BillFormUnitPriceChanged(this.index, this.value);

  @override
  List<Object?> get props => [index, value];
}

class BillFormTotalPriceChanged extends BillFormEvent {
  final int index;
  final String value;
  BillFormTotalPriceChanged(this.index, this.value);

  @override
  List<Object?> get props => [index, value];
}

class BillFormCurrencyChanged extends BillFormEvent {
  final CurrencyEntity currency;
  BillFormCurrencyChanged(this.currency);

  @override
  List<Object?> get props => [currency];
}

class BillFormTreasurySelected extends BillFormEvent {
  final PersonEntity? treasury;
  BillFormTreasurySelected(this.treasury);

  @override
  List<Object?> get props => [treasury];
}

class BillFormSubmitRequested extends BillFormEvent {}

class BillFormPostToAccountingRequested extends BillFormEvent {}

class BillFormPostToInventoryRequested extends BillFormEvent {}

class BillFormPostToCostingRequested extends BillFormEvent {}
