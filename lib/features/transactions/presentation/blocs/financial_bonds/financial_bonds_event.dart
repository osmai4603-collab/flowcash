import 'package:equatable/equatable.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_bond_entity.dart';

abstract class FinancialBondsEvent extends Equatable {
  const FinancialBondsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFinancialBondsEvent extends FinancialBondsEvent {}

class AddFinancialBondEvent extends FinancialBondsEvent {
  final FinancialBondEntity bond;

  const AddFinancialBondEvent(this.bond);

  @override
  List<Object?> get props => [bond];
}

class UpdateFinancialBondEvent extends FinancialBondsEvent {
  final FinancialBondEntity bond;

  const UpdateFinancialBondEvent(this.bond);

  @override
  List<Object?> get props => [bond];
}

class DeleteFinancialBondEvent extends FinancialBondsEvent {
  final int id;

  const DeleteFinancialBondEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectFinancialBondEvent extends FinancialBondsEvent {
  final FinancialBondEntity? bond;

  const SelectFinancialBondEvent(this.bond);

  @override
  List<Object?> get props => [bond];
}
