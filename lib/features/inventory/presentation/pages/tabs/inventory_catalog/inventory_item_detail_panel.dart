import 'package:flutter/material.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class InventoryItemDetailPanel extends StatelessWidget {
  final InventoryEntity item;
  final List<CategoryEntity> categories;
  final List<WarehouseEntity> warehouses;
  final List<SubAccountEntity> subAccounts;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InventoryItemDetailPanel({
    super.key,
    required this.item,
    required this.categories,
    required this.warehouses,
    required this.subAccounts,
    required this.onEdit,
    required this.onDelete,
  });

  String _getCategoryName(int id) {
    try {
      return categories.firstWhere((c) => c.id == id).categoryName;
    } catch (_) {
      return 'صنف غير معروف (#$id)';
    }
  }

  String _getWarehouseName(int id) {
    try {
      return warehouses.firstWhere((w) => w.id == id).warehouseName;
    } catch (_) {
      return 'مستودع غير معروف (#$id)';
    }
  }

  String _getAccountName(int? id) {
    if (id == null) return 'غير مرتبِط ⚠️';
    try {
      final acc = subAccounts.firstWhere((a) => a.id == id);
      return '${acc.accountName} (${acc.accountNumber})';
    } catch (_) {
      return 'حساب غير معروف (#$id)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Icon + Name
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withAlpha(40),
                    radius: 28,
                    child: fluent.Icon(
                      Icons.production_quantity_limits,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  fluent.Text(
                    _getCategoryName(item.categoryId),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  fluent.Text(
                    'المعرف الرقمي: #${item.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // 1. Details Section
              const fluent.Text(
                '📦 تفاصيل البطاقة التعريفية',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                Icons.production_quantity_limits,
                'المستودع الرئيسي:',
                _getWarehouseName(item.storeId),
              ),
              // costType removed from inventory card
              _buildDetailRow(
                context,
                Icons.label,
                'عدد الوحدات:',
                item.countUnits.toString(),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // 2. Linked Financial Accounts Section
              const fluent.Text(
                '💼 الحسابات المالية المرتبطة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildAccountRow(
                context,
                Icons.arrow_circle_up,
                'حساب الإيرادات (المبيعات):',
                _getAccountName(item.revenueAccountId),
                Colors.green,
              ),
              _buildAccountRow(
                context,
                Icons.arrow_circle_down,
                'حساب المصروفات (المشتريات):',
                _getAccountName(item.expenseAccountId),
                Colors.red,
              ),
              _buildAccountRow(
                context,
                Icons.login,
                'حساب مخزون الوارد:',
                _getAccountName(item.incomeStockId),
                Colors.blue,
              ),
              _buildAccountRow(
                context,
                Icons.logout,
                'حساب مخزون الصادر:',
                _getAccountName(item.outcomeStockId),
                Colors.orange,
              ),

              const SizedBox(height: 24),
              const Divider(height: 32),

              // 3. Action Buttons (Edit / Delete)
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
                        'تعديل الصنف',
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
    const fluent.Icon(Icons.delete_forever),
    const SizedBox(width: 8.0),
    const fluent.Text(
                        'حذف البطاقة',
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
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          fluent.Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary.withAlpha(180),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: fluent.Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withAlpha(180),
              ),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: fluent.Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              fluent.Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 8),
              fluent.Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: fluent.Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
