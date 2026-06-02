import 'package:flutter/material.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/combo_box_form.dart';

class TransactionOrderForm extends StatefulWidget {
  final List<InventoryBatchEntity> batches;
  final List<InventoryEntity> inventoryItems;

  const TransactionOrderForm({
    super.key,
    required this.batches,
    required this.inventoryItems,
  });

  @override
  State<TransactionOrderForm> createState() => _TransactionOrderFormState();
}

class _TransactionOrderFormState extends State<TransactionOrderForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _batchController = TextEditingController();
  int? _selectedBatchId;
  final _quantityController = TextEditingController();

  List<CategoryEntity> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _quantityController.text = "1.0";
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final res = await sl<GetAllCategoriesUseCase>().call();
    if (mounted) {
      setState(() {
        res.fold((_) => null, (list) => _categories = list);
        _isLoading = false;
      });
    }
  }

  String _getBatchLabel(InventoryBatchEntity b) {
    try {
      final item = widget.inventoryItems.firstWhere((i) => i.id == b.inventoryId);
      final catName = _categories.firstWhere((c) => c.id == item.categoryId).categoryName;
      return '$catName (دفعة: ${b.batchNumber} - متاح: ${b.countUnits})';
    } catch (_) {
      return 'دفعة: ${b.batchNumber}';
    }
  }

  @override
  void dispose() {
    _batchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBatchId == null) return;

    final quantity = double.tryParse(_quantityController.text) ?? 1.0;

    final order = InventoryTransactionOrderEntity(
      id: 0,
      inventoryBatchId: _selectedBatchId,
      countUnits: quantity,
    );

    Navigator.of(context).pop(order);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.add_shopping_cart_outlined, color: theme.colorScheme.primary),
          SizedBox(width: 8),
          Text('إضافة بند جديد للحركة 📦', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: _isLoading
          ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Select Batch
                  ComboBoxForm<InventoryBatchEntity>(
                    controller: _batchController,
                    decoration: const InputDecoration(
                      labelText: 'اختر دفعة الصنف',
                      prefixIcon: Icon(Icons.tag_outlined),
                    ),
                    labelMenu: (batch) => _getBatchLabel(batch),
                    labelString: (batch) => _getBatchLabel(batch),
                    itemsBuilder: (value) {
                      final search = value.trim().toLowerCase();
                      return widget.batches.where((batch) {
                        return _getBatchLabel(batch).toLowerCase().contains(search);
                      }).toList();
                    },
                    onSelectedItem: (batch) {
                      setState(() {
                        _selectedBatchId = batch.id;
                      });
                    },
                    onChanged: (value) {
                      if (_selectedBatchId != null &&
                          _batchController.text !=
                              _getBatchLabel(widget.batches.firstWhere((batch) => batch.id == _selectedBatchId!))) {
                        setState(() {
                          _selectedBatchId = null;
                        });
                      }
                    },
                    validator: (_) => _selectedBatchId == null ? 'الرجاء اختيار الدفعة' : null,
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  TextFormField(
                    controller: _quantityController,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'الكمية المطلوبة',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'الرجاء إدخال الكمية';
                      final q = double.tryParse(val);
                      if (q == null || q <= 0) return 'الكمية يجب أن تكون أكبر من الصفر';
                      return null;
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('إضافة البند'),
        ),
      ],
    );
  }
}
