import 'package:flutter/material.dart';
import 'package:flowcash/core/enums/batch_status_enum.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';

class BatchDetailPanel extends StatelessWidget {
  final InventoryBatchEntity batch;
  final List<InventoryEntity> inventoryItems;
  final List<CategoryEntity> categories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BatchDetailPanel({
    super.key,
    required this.batch,
    required this.inventoryItems,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  String _getInventoryItemName(int id) {
    try {
      final item = inventoryItems.firstWhere((i) => i.id == id);
      return categories.firstWhere((c) => c.id == item.categoryId).categoryName;
    } catch (_) {
      return 'صنف غير معروف (#$id)';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد ──';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalCost = batch.countUnits * batch.unitCost;

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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.secondary.withAlpha(40),
                          radius: 28,
                          child: Icon(
                            Icons.all_inbox_outlined,
                            color: theme.colorScheme.secondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'دفعة: ${batch.batchNumber}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'اسم الصنف: ${_getInventoryItemName(batch.inventoryId)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface.withAlpha(150),
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

                    // 1. Quantity & Pricing
                    const Text(
                      '📊 بيانات الكميات والتكلفة',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.tag_outlined,
                      'الكمية المتوفرة بالدفعة:',
                      '${batch.countUnits} وحدة',
                    ),
                    _buildDetailRow(
                      context,
                      Icons.price_change_outlined,
                      'تكلفة الوحدة الواحدة:',
                      '${batch.unitCost.toStringAsFixed(2)} SAR',
                    ),
                    _buildDetailRow(
                      context,
                      Icons.calculate_outlined,
                      'إجمالي تكلفة الدفعة:',
                      '${totalCost.toStringAsFixed(2)} SAR',
                      valueColor: theme.colorScheme.primary,
                      isBoldValue: true,
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // 2. Source, Status, Dates
                    const Text(
                      '⚙️ الحالة والتواريخ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.login_outlined,
                      'مصدر الدفعة:',
                      batch.batchSource.displayName(),
                    ),
                    _buildDetailRow(
                      context,
                      Icons.check_circle_outline,
                      'الحالة الحالية:',
                      batch.batchStatus.displayName(),
                      valueColor: batch.batchStatus == BatchStatus.available
                          ? Colors.green
                          : Colors.red,
                      isBoldValue: true,
                    ),
                    _buildDetailRow(
                      context,
                      Icons.date_range_outlined,
                      'تاريخ الإدخال:',
                      _formatDate(batch.inputDate),
                    ),
                    _buildDetailRow(
                      context,
                      Icons.date_range_outlined,
                      'تاريخ الإنتاج:',
                      _formatDate(batch.productionDate),
                    ),
                    _buildDetailRow(
                      context,
                      Icons.date_range_outlined,
                      'تاريخ انتهاء الصلاحية:',
                      _formatDate(batch.expirationDate),
                      valueColor:
                          batch.expirationDate != null &&
                              batch.expirationDate!.isBefore(DateTime.now())
                          ? Colors.red
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),

            // 3. Action Buttons
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
                    icon: Icon(
                      Icons.edit_calendar_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      'تعديل الدفعة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text(
                      'حذف الدفعة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
    String value, {
    Color? valueColor,
    bool isBoldValue = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.secondary.withAlpha(180),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withAlpha(180),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
