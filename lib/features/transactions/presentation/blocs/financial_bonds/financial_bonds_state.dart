import 'package:equatable/equatable.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_bond_entity.dart';

enum FinancialBondsStatus { initial, loading, success, error }

class FinancialBondsState extends Equatable {
  final List<FinancialBondEntity> bonds;
  final FinancialBondsStatus status;
  final String? errorMessage;
  final FinancialBondEntity? selectedBond;

  const FinancialBondsState({
    this.bonds = const [],
    this.status = FinancialBondsStatus.initial,
    this.errorMessage,
    this.selectedBond,
  });

  FinancialBondsState copyWith({
    List<FinancialBondEntity>? bonds,
    FinancialBondsStatus? status,
    String? errorMessage,
    FinancialBondEntity? selectedBond,
  }) {
    return FinancialBondsState(
      bonds: bonds ?? this.bonds,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedBond: selectedBond ?? this.selectedBond,
    );
  }

  FinancialBondsState addBond(FinancialBondEntity bond) {
    return copyWith(
      bonds: [bond, ...bonds],
      status: FinancialBondsStatus.success,
    );
  }

  FinancialBondsState updateBond(FinancialBondEntity bond) {
    final updatedList = bonds.map((b) => b.id == bond.id ? bond : b).toList();
    return copyWith(
      bonds: updatedList,
      selectedBond: selectedBond?.id == bond.id ? bond : selectedBond,
      status: FinancialBondsStatus.success,
    );
  }

  FinancialBondsState removeBond(int id) {
    final updatedList = bonds.where((b) => b.id != id).toList();
    return copyWith(
      bonds: updatedList,
      selectedBond: selectedBond?.id == id ? null : selectedBond,
      status: FinancialBondsStatus.success,
    );
  }

  FinancialBondsState toError(String message) {
    return copyWith(status: FinancialBondsStatus.error, errorMessage: message);
  }

  FinancialBondsState toLoading() {
    return copyWith(status: FinancialBondsStatus.loading);
  }

  @override
  List<Object?> get props => [bonds, status, errorMessage, selectedBond];
}
