import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';
import 'package:flowcash/core/enums/counter_type_enum.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';

abstract interface class ValueCounterDataSource implements AppDataSource<int, ValueCounterEntity, Map<String, dynamic>> {
  Future<ValueCounterEntity> getCounter(CounterType counterType);
  Future<int> getNewCounter(CounterType counterType, {bool shouldUpdate = true});
  Future<int> getNewCounterOfWithdraws({bool shouldUpdate = true});
  Future<int> getNewCounterOfBuysBills({bool shouldUpdate = true});
  Future<int> getNewCounterOfSalesBills({bool shouldUpdate = true});
  Future<int> getNewCounterOfOpeningEntries({bool shouldUpdate = true});
  Future<int> getNewCounterOfClosingEntries({bool shouldUpdate = true});
  Future<int> getNewCounterOfPaids({bool shouldUpdate = true});
  Future<int> getNewCounterOfProceeds({bool shouldUpdate = true});
  Future<bool> updateCounter({required int counter, required int id});
  Future<int> getNewCounterOfExpenses({bool shouldUpdate = true});
  Future<int> getNewCounterOfRevenues({bool shouldUpdate = true});
  Future<List<int>> getNewCountersOfExpenses({required int length});
  Future<List<int>> getNewCountersOfRevenues({required int length});
  Future<int> getNextCounter(int valueGroupId);

  Future<int> getNextCounterByGroup(HistoriesGroup historyGroup);
}
