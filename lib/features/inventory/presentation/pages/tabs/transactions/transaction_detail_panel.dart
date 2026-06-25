import 'package:flutter/material.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class TransactionDetailPanel extends StatelessWidget {
  final InventoryTransactionEntity transaction;
  final List<InventoryTransactionOrderEntity> orders;
  final List<WarehouseEntity> warehouses;
  final List<InventoryEntity> inventoryItems;
  final List<CategoryEntity> categories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionDetailPanel({
    super.key,
    required this.transaction,
    required this.orders,
    required this.warehouses,
    required this.inventoryItems,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  String _getWarehouseName(int id) {
    try {
      return warehouses.firstWhere((w) => w.id == id).warehouseName;
    } catch (_) {
      return 'مستودع غير معروف (#$id)';
    }
  }

  String _getInventoryLabel(int? inventoryId) {
    if (inventoryId == null) return 'بند بدون صنف';
    try {
      final item = inventoryItems.firstWhere((i) => i.id == inventoryId);
      final catName = categories
          .firstWhere((c) => c.id == item.categoryId)
          .categoryName;
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

    final isReceipt =
        transaction.transactionType ==
        InventoryTransactionType.importInventory;

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
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withAlpha(240),
                  ]
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
                  backgroundColor: (isReceipt ? Colors.green : Colors.red)
                      .withAlpha(40),
                  radius: 28,
                  child: fluent.Icon(
                    isReceipt ? Icons.login_outlined : Icons.logout_outlined,
                    color: isReceipt ? Colors.green : Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fluent.Text(
                        'سند: #${transaction.billNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      fluent.Text(
                        'نوع الإذن: ${transaction.transactionType.displayName()}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isReceipt ? Colors.green : Colors.red,
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
            const fluent.Text(
              '📋 معلومات الحركة الأساسية',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.warehouse_outlined,
              'المستودع الرئيسي:',
              _getWarehouseName(transaction.warehouseId),
            ),
            _buildDetailRow(
              context,
              Icons.calendar_today_outlined,
              'تاريخ وتوقيت الإصدار:',
              _formatDate(transaction.createdAt),
            ),
            _buildDetailRow(
              context,
              Icons.person_outline,
              'الرقم التعريفي للمصدر:',
              'موظف #${transaction.createdBy}',
            ),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              _buildDetailRow(
                context,
                Icons.notes_outlined,
                'البيان/الملاحظات:',
                transaction.note!,
              ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // 2. Child Items (Orders) List Table
            const fluent.Text(
              '📦 تفصيل الأصناف والبنود المشمولة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withAlpha(50),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: orders.isEmpty
                    ? const Center(
                        child: fluent.Text(
                          'لا توجد أصناف في هذا الإذن ⚠️',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final o = orders[index];
                          return Card(
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainerHighest
                                .withAlpha(50),
                            child: ListTile(
                              title: fluent.Text(
                                _getInventoryLabel(o.inventoryId),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: fluent.Text(
                                'الكمية: ${o.countUnits}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),

            const Divider(height: 32),

            // 3. Edit / Delete buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: fluent.Icon(
                      Icons.edit,
                      color: theme.colorScheme.primary,
                    ),
                    label: fluent.Text(
                      'تعديل الإذن',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: fluent.FilledButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const fluent.Icon(Icons.delete),
                        const SizedBox(width: 8.0),
                        const fluent.Text(
                          'حذف الإذن بالكامل',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onPressed: onDelete,
                  ),
                ),
              ],
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
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fluent.Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary.withAlpha(180),
          ),
          const SizedBox(width: 10),
          fluent.Text(
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
              child: fluent.Text(
                value,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
