import 'package:flutter/material.dart';
import 'package:flowcash/features/inventory/domain/entities/goods_cost_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
class GoodsCostFormDialog extends StatefulWidget {
  final List<WarehouseEntity> warehouses;

  const GoodsCostFormDialog({
    super.key,
    required this.warehouses,
  });

  @override
  State<GoodsCostFormDialog> createState() => _GoodsCostFormDialogState();
}

class _GoodsCostFormDialogState extends State<GoodsCostFormDialog> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedWarehouseId;
  final _billNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCurrency = "SAR";

  @override
  void initState() {
    super.initState();
    _billNumberController.text = "0";
    _amountController.text = "0.0";
  }

  @override
  void dispose() {
    _billNumberController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWarehouseId == null) return;

    final billNum = int.tryParse(_billNumberController.text) ?? 0;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final cost = GoodsCostEntity(
      id: 0,
      createdAt: DateTime.now(),
      createdBy: 1,
      billNumber: billNum,
      warehouseId: _selectedWarehouseId!,
      offerAmount: amount,
      currencyId: _selectedCurrency,
      hintId: 0,
      note: _noteController.text.trim(),
      historyGroup: InventoryTransactionType.goodsCost,
    );

    Navigator.of(context).pop(cost);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return fluent.ContentDialog(
      content: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [theme.colorScheme.surface, theme.colorScheme.surface.withAlpha(240)]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(fluent.FluentIcons.receipt_check, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 8),
                  const fluent.Text('تسجيل تكلفة بضاعة جديدة 💰', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),

              // Warehouse
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'اختر المستودع الرئيسي',
                  prefixIcon: Icon(fluent.FluentIcons.store_logo16),
                ),
                initialValue: _selectedWarehouseId,
                items: widget.warehouses.map((w) {
                  return DropdownMenuItem<int>(
                    value: w.id,
                    child: fluent.Text(w.warehouseName),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedWarehouseId = val),
                validator: (val) => val == null ? 'المستودع مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // Bill Number & Currency Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _billNumberController,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'رقم السند/الفاتورة',
                        prefixIcon: Icon(fluent.FluentIcons.ticket),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'رقم السند مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'العملة',
                        prefixIcon: Icon(fluent.FluentIcons.currency),
                      ),
                      initialValue: _selectedCurrency,
                      items: const [
                        DropdownMenuItem(value: 'SAR', child: fluent.Text('SAR (ريال)')),
                        DropdownMenuItem(value: 'USD', child: fluent.Text('USD (دولار)')),
                      ],
                      onChanged: (val) => setState(() => _selectedCurrency = val ?? 'SAR'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'المبلغ الإجمالي لتكلفة البضاعة',
                  prefixIcon: Icon(fluent.FluentIcons.money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'المبلغ مطلوب';
                  final num = double.tryParse(val);
                  if (num == null || num <= 0) return 'المبلغ يجب أن يكون أكبر من صفر';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'بيان/ملاحظات الحركة',
                  prefixIcon: Icon(fluent.FluentIcons.note_pinned),
                ),
              ),

              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  fluent.Button(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const fluent.Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  fluent.FilledButton(
                    onPressed: _submit,
                    child: const fluent.Text('تسجيل التكلفة'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
