import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/transactions/domain/entities/cost_good_bill_entity.dart';

abstract interface class CostGoodBillDataSource
    implements AppDataSource<int, CostGoodBillEntity, Map<String, dynamic>> {}
