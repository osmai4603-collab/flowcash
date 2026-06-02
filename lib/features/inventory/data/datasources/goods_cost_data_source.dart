import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/inventory/domain/entities/goods_cost_entity.dart';

abstract interface class GoodsCostDataSource
    implements AppDataSource<int, GoodsCostEntity, Map<String, dynamic>> {}
