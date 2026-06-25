import 'package:flutter/material.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/injection_container.dart';
import '../transactions/transaction_order_form.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class TransferFormDialog extends StatefulWidget {
  final List<WarehouseEntity> warehouses;
  final List<InventoryEntity> inventoryItems;

  const TransferFormDialog({
    super.key,
    required this.warehouses,
    required this.inventoryItems,
  });

  @override
  State<TransferFormDialog> createState() => _TransferFormDialogState();
}

class _TransferFormDialogState extends State<TransferFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Transfer header
  int? _selectedFromWarehouseId;
  int? _selectedToWarehouseId;
  final _billNumberController = TextEditingController();
  final _noteController = TextEditingController();

  // Child items (orders) list
  List<InventoryTransactionOrderEntity> _orders = [];

  // Local meta reference
  List<CategoryEntity> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _billNumberController.text = "0";
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final res = await sl<GetAllCategoriesUseCase>().call();
    if (mounted) {
      setState(() {
        res.fold((_) => null, (list) => _categories = list);
        _isLoadingCategories = false;
      });
    }
  }

  String _getInventoryLabel(int? inventoryId) {
    if (inventoryId == null) return 'بند بدون صنف';
    try {
      final item = widget.inventoryItems.firstWhere((i) => i.id == inventoryId);
      final catName = _categories
          .firstWhere((c) => c.id == item.categoryId)
          .categoryName;
      return '$catName (${item.inventoryName})';
    } catch (_) {
      return 'صنف #$inventoryId';
    }
  }

  @override
  void dispose() {
    _billNumberController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFromWarehouseId == null || _selectedToWarehouseId == null) {
      fluent.displayInfoBar(
        context,
        builder: (context, close) => fluent.InfoBar(
          title: const fluent.Text('تنبيه'),
          content: fluent.Text('الرجاء اختيار مستودع الصادر ومستودع الوارد'),
        ),
      );
      return;
    }
    if (_selectedFromWarehouseId == _selectedToWarehouseId) {
      fluent.displayInfoBar(
        context,
        builder: (context, close) => fluent.InfoBar(
          title: const fluent.Text('تنبيه'),
          content: fluent.Text('مستودع الصادر ومستودع الوارد متطابقين!'),
        ),
      );
      return;
    }
    if (_orders.isEmpty) {
      fluent.displayInfoBar(
        context,
        builder: (context, close) => fluent.InfoBar(
          title: const fluent.Text('تنبيه'),
          content: fluent.Text('يجب إضافة صنف واحد على الأقل للنقل'),
        ),
      );
      return;
    }

    final billNum = int.tryParse(_billNumberController.text) ?? 0;
    final now = DateTime.now();

    // 1. From transaction (Outward / Delivery)
    final fromTransaction = InventoryTransactionEntity(
      id: 0,
      createdAt: now,
      createdBy: 1,
      warehouseId: _selectedFromWarehouseId!,
      billNumber: billNum,
      transactionType: InventoryTransactionType.exportInventory,
      note:
          'تحويل مخزني صادر إلى مستودع ${_selectedToWarehouseId}: ${_noteController.text}'
              .trim(),
    );

    // 2. To transaction (Inward / Receipt)
    final toTransaction = InventoryTransactionEntity(
      id: 0,
      createdAt: now,
      createdBy: 1,
      warehouseId: _selectedToWarehouseId!,
      billNumber: billNum,
      transactionType: InventoryTransactionType.importInventory,
      note:
          'تحويل مخزني وارد من مستودع ${_selectedFromWarehouseId}: ${_noteController.text}'
              .trim(),
    );

    Navigator.of(context).pop({
      'fromTransaction': fromTransaction,
      'toTransaction': toTransaction,
      'items': _orders,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return fluent.ContentDialog(
      constraints: BoxConstraints(
        maxWidth: 700,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withAlpha(240),
                  ]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: _isLoadingCategories
            ? const SizedBox(
                height: 300,
                child: Center(child: fluent.ProgressRing()),
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Row(
                      children: [
                        fluent.Icon(
                          fluent.FluentIcons.shopping_cart,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const fluent.Text(
                          'إنشاء إذن نقل/تحويل بين المخازن 🚚',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        fluent.IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const fluent.Icon(
                            fluent.FluentIcons.chrome_close,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Warehouse selectors (From and To)
                    Row(
                      children: [
                        // From Warehouse
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'من مستودع (الصادر)',
                              prefixIcon: fluent.Icon(
                                fluent.FluentIcons.store_logo16,
                              ),
                            ),
                            initialValue: _selectedFromWarehouseId,
                            items: widget.warehouses.map((w) {
                              return DropdownMenuItem<int>(
                                value: w.id,
                                child: fluent.Text(w.warehouseName),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedFromWarehouseId = val),
                            validator: (val) => val == null
                                ? 'الرجاء تحديد مستودع الصادر'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // To Warehouse
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'إلى مستودع (الوارد)',
                              prefixIcon: fluent.Icon(
                                fluent.FluentIcons.store_logo16,
                              ),
                            ),
                            initialValue: _selectedToWarehouseId,
                            items: widget.warehouses.map((w) {
                              return DropdownMenuItem<int>(
                                value: w.id,
                                child: fluent.Text(w.warehouseName),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedToWarehouseId = val),
                            validator: (val) => val == null
                                ? 'الرجاء تحديد مستودع الوارد'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // Bill number
                        Expanded(
                          child: TextFormField(
                            controller: _billNumberController,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              labelText: 'رقم السند/الإذن الدفتري',
                              prefixIcon: fluent.Icon(
                                fluent.FluentIcons.ticket,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty
                                ? 'رقم السند مطلوب'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Notes
                        Expanded(
                          child: TextFormField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: 'ملاحظات وتفاصيل عملية النقل',
                              prefixIcon: fluent.Icon(
                                fluent.FluentIcons.note_pinned,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Items list title & Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const fluent.Text(
                          '📦 الأصناف المنقولة والكميات المراد تحويلها',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        fluent.FilledButton(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const fluent.Icon(
                                fluent.FluentIcons.shopping_cart,
                                size: 16,
                              ),
                              const SizedBox(width: 8.0),
                              const fluent.Text('إضافة بند'),
                            ],
                          ),
                          onPressed: () async {
                            final result =
                                await showDialog<
                                  InventoryTransactionOrderEntity
                                >(
                                  context: context,
                                  builder: (context) => TransactionOrderForm(
                                    inventoryItems: widget.inventoryItems,
                                  ),
                                );
                            if (result != null) {
                              setState(() {
                                _orders.add(result);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Items list container
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline.withAlpha(50),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _orders.isEmpty
                            ? const Center(
                                child: fluent.Text(
                                  'لا توجد أصناف مضافة لعملية التحويل حتى الآن. 🚚',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  return Card(
                                    elevation: 0,
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withAlpha(80),
                                    child: ListTile(
                                      title: fluent.Text(
                                        _getInventoryLabel(order.inventoryId),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          fluent.Text(
                                            'الكمية: ${order.countUnits}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          fluent.IconButton(
                                            icon: const fluent.Icon(
                                              fluent.FluentIcons.remove_link,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _orders.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    const Divider(height: 24),
                    // Actions buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        fluent.Button(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const fluent.Text('إلغاء'),
                        ),
                        const SizedBox(width: 12),
                        fluent.FilledButton(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const fluent.Icon(fluent.FluentIcons.save),
                              const SizedBox(width: 8.0),
                              const fluent.Text('إصدار وإتمام التحويل'),
                            ],
                          ),
                          onPressed: _submit,
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
