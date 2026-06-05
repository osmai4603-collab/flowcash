import 'package:flutter/material.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/injection_container.dart';

import 'transaction_order_form.dart';

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, InfoBar, ProgressRing, displayInfoBar;
class TransactionFormDialog extends StatefulWidget {
  final InventoryTransactionEntity? transaction;
  final List<InventoryTransactionOrderEntity>? initialOrders;
  final List<WarehouseEntity> warehouses;
  final List<InventoryEntity> inventoryItems;

  const TransactionFormDialog({
    super.key,
    this.transaction,
    this.initialOrders,
    required this.warehouses,
    required this.inventoryItems,
  });

  @override
  State<TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends State<TransactionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEdit;

  // Header fields
  int? _selectedWarehouseId;
  InventoryTransactionType _selectedType = InventoryTransactionType.inventoryReceipt;
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
    _isEdit = widget.transaction != null;
    _loadCategories();

    if (_isEdit) {
      final t = widget.transaction!;
      _selectedWarehouseId = t.warehouseId;
      _selectedType = t.transactionType;
      _billNumberController.text = t.billNumber.toString();
      _noteController.text = t.note ?? '';
      _orders = List.from(widget.initialOrders ?? []);
    } else {
      _billNumberController.text = "0";
    }
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
      final catName = _categories.firstWhere((c) => c.id == item.categoryId).categoryName;
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
    if (_selectedWarehouseId == null) {
      displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text('الرجاء اختيار مستودع الحركة')));
      return;
    }
    if (_orders.isEmpty) {
      displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text('يجب إضافة بند واحد على الأقل للحركة')));
      return;
    }

    final billNum = int.tryParse(_billNumberController.text) ?? 0;

    final resultTransaction = InventoryTransactionEntity(
      id: _isEdit ? widget.transaction!.id : 0,
      createdAt: _isEdit ? widget.transaction!.createdAt : DateTime.now(),
      createdBy: _isEdit ? widget.transaction!.createdBy : 1,
      warehouseId: _selectedWarehouseId!,
      billNumber: billNum,
      transactionType: _selectedType,
      note: _noteController.text.trim(),
    );

    Navigator.of(context).pop({
      'transaction': resultTransaction,
      'orders': _orders.map((o) => o.copyWith(transactionType: _selectedType)).toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ContentDialog(
      constraints: BoxConstraints(
        maxWidth: 700,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      content: _isLoadingCategories
          ? const SizedBox(
              height: 300,
              child: Center(child: const ProgressRing()),
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
                      Icon(
                        _isEdit ? Icons.edit_note_outlined : Icons.post_add_outlined,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isEdit ? 'تعديل إذن/حركة المخزن' : 'إنشاء إذن/حركة مخزنية جديدة',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
      
                  // Header inputs
                  Row(
                    children: [
                      // Transaction Type
                      Expanded(
                        child: DropdownButtonFormField<InventoryTransactionType>(
                          decoration: const InputDecoration(
                            labelText: 'نوع الحركة',
                            prefixIcon: Icon(Icons.transform),
                          ),
                          initialValue: _selectedType,
                          items: InventoryTransactionType.values.map((type) {
                            return DropdownMenuItem<InventoryTransactionType>(
                              value: type,
                              child: Text(type.displayName()),
                            );
                          }).toList(),
                          onChanged: _isEdit
                              ? null // Disable type change on edit to preserve database structure
                              : (val) {
                                  if (val != null) {
                                    setState(() => _selectedType = val);
                                  }
                                },
                        ),
                      ),
                      const SizedBox(width: 16),
      
                      // Warehouse
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'المستودع الرئيسي',
                            prefixIcon: Icon(Icons.store),
                          ),
                          initialValue: _selectedWarehouseId,
                          items: widget.warehouses.map((w) {
                            return DropdownMenuItem<int>(
                              value: w.id,
                              child: Text(w.warehouseName),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedWarehouseId = val),
                          validator: (val) => val == null ? 'الرجاء تحديد المستودع' : null,
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
                            labelText: 'رقم الفاتورة/السند الدفتري',
                            prefixIcon: Icon(Icons.event_available),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'رقم السند مطلوب' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
      
                      // Notes
                      Expanded(
                        child: TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'بيان/ملاحظات الحركة',
                            prefixIcon: Icon(Icons.note),
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
                      const Text(
                        '📦 بنود الحركة المخزنية (الأصناف والدفعات)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await showDialog<InventoryTransactionOrderEntity>(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                        ),
                        icon: const Icon(Icons.playlist_add, size: 16),
                        label: const Text('إضافة بند'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
      
                  // Items Grid / List
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _orders.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد أصناف مضافة في هذا الإذن حتى الآن. 📥',
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
                                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                                  child: ListTile(
                                    title: Text(
                                      _getInventoryLabel(order.inventoryId),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'الكمية: ${order.countUnits}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 16),
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.red),
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
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('إلغاء'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.save),
                        label: Text(_isEdit ? 'حفظ إذن الحركة' : 'حفظ وإصدار الإذن'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
