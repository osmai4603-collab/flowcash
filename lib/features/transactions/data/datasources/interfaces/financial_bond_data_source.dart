import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_bond_entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';

abstract interface class FinancialBondDataSource
    implements AppDataSource<int, FinancialBondEntity, Map<String, dynamic>> {
  @override
  Future<List<FinancialBondEntity>> get({
    Iterable<int>? ids,
    HistoriesGroup? historyGroup,
  });
}
