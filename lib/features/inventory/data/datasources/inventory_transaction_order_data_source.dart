import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';

abstract interface class InventoryTransactionOrderDataSource
    implements
        AppDataSource<
          int,
          InventoryTransactionOrderEntity,
          Map<String, dynamic>
        > {}
