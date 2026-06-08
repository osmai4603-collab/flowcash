import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_transaction_entity.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';

abstract interface class FinancialTransactionDataSource
    implements
        AppDataSource<int, FinancialTransactionEntity, Map<String, dynamic>> {
  @override
  Future<List<FinancialTransactionEntity>> get({
    Iterable<int>? ids,
    HistoriesGroup? historyGroup,
  });
}
