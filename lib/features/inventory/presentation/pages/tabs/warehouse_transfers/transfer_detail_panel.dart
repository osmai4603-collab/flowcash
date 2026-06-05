import 'package:flutter/material.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';

class TransferDetailPanel extends StatelessWidget {
  final InventoryTransactionEntity transaction;
  final List<InventoryTransactionEntity> allTransactions;
  final List<InventoryTransactionOrderEntity> orders;
  final List<WarehouseEntity> warehouses;
  final List<InventoryEntity> inventoryItems;
  final List<CategoryEntity> categories;
  final Function(int fromId, int toId) onDelete;

  const TransferDetailPanel({
    super.key,
    required this.transaction,
    required this.allTransactions,
    required this.orders,
    required this.warehouses,
    required this.inventoryItems,
    required this.categories,
    required this.onDelete,
  });

  String _getWarehouseName(int id) {
    try {
      return warehouses.firstWhere((w) => w.id == id).warehouseName;
    } catch (_) {
      return 'مستودع (#$id)';
    }
  }

  String _getInventoryLabel(int? inventoryId) {
    if (inventoryId == null) return 'بند بدون صنف';
    try {
      final item = inventoryItems.firstWhere((i) => i.id == inventoryId);
      final catName = categories.firstWhere((c) => c.id == item.categoryId).categoryName;
      return '$catName (${item.inventoryName})';
    } catch (_) {
      return 'صنف #$inventoryId';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Find counterpart transaction to show source/destination clearly
    InventoryTransactionEntity? counterpart;
    try {
      counterpart = allTransactions.firstWhere(
        (t) => t.billNumber == transaction.billNumber && t.id != transaction.id && 
               (t.note?.contains('تحويل مخزني') ?? false)
      );
    } catch (_) {
      counterpart = null;
    }

    final int fromWarehouseId = transaction.note?.contains('صادر') == true
        ? transaction.warehouseId
        : (counterpart?.warehouseId ?? transaction.warehouseId);
        
    final int toWarehouseId = transaction.note?.contains('وارد') == true
        ? transaction.warehouseId
        : (counterpart?.warehouseId ?? transaction.warehouseId);

    final fromWarehouseName = _getWarehouseName(fromWarehouseId);
    final toWarehouseName = _getWarehouseName(toWarehouseId);

    // List of child orders
    final childOrders = orders.where((o) => o.tranId == transaction.id).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [theme.colorScheme.surface, theme.colorScheme.surface.withAlpha(240)]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withAlpha(40),
                  radius: 28,
                  child: Icon(Icons.shopping_cart,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سند نقل: #${transaction.billNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'إذن تحويل مخزني ثنائي 🚚',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // 1. Transaction details
            const Text(
              '📋 تفاصيل عملية النقل',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.exit_to_app,
              'مستودع الصادر (من):',
              fromWarehouseName,
              valueColor: Colors.red,
            ),
            _buildDetailRow(
              context,
              Icons.input,
              'مستودع الوارد (إلى):',
              toWarehouseName,
              valueColor: Colors.green,
            ),
            _buildDetailRow(
              context,
              Icons.calendar_today,
              'تاريخ وتوقيت النقل:',
              _formatDate(transaction.createdAt),
            ),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              _buildDetailRow(
                context,
                Icons.note,
                'ملاحظات النقل:',
                transaction.note!,
              ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // 2. Child Items (Orders) List Table
            const Text(
              '📦 الأصناف والكميات المنقولة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: childOrders.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد أصناف منقولة في هذا السند ⚠️',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: childOrders.length,
                        itemBuilder: (context, index) {
                          final o = childOrders[index];
                          return Card(
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                            child: ListTile(
                              title: Text(
                                _getInventoryLabel(o.inventoryId),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              trailing: Text(
                                'الكمية: ${o.countUnits}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const Divider(height: 32),

            // 3. Revert/Delete Button
            ElevatedButton.icon(
              onPressed: () {
                final counterpartId = counterpart?.id ?? transaction.id;
                onDelete(transaction.id, counterpartId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text(
                'إلغاء وعكس عملية التحويل 🔄',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary.withAlpha(180),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: theme.colorScheme.onSurface.withAlpha(180),
            ),
          ),
          const Spacer(),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
