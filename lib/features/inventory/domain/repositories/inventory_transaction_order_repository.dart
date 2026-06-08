import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/core/repositories/repository.dart';

abstract interface class InventoryTransactionOrderRepository
    implements RepositoryDB<InventoryTransactionOrderEntity> {}
