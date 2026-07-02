import 'package:flutter/material.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/combo_box_form.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class TransactionOrderForm extends StatefulWidget {
  final List<InventoryEntity> inventoryItems;

  const TransactionOrderForm({super.key, required this.inventoryItems});

  @override
  State<TransactionOrderForm> createState() => _TransactionOrderFormState();
}

class _TransactionOrderFormState extends State<TransactionOrderForm> {
  final _formKey = GlobalKey<FormState>();

  final _itemController = TextEditingController();
  int? _selectedInventoryId;
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

  String _getInventoryLabel(InventoryEntity i) {
    try {
      final catName = _categories
          .firstWhere((c) => c.id == i.categoryId)
          .categoryName;
      return '$catName (صنف: ${i.inventoryName})';
    } catch (_) {
      return '${i.inventoryName}';
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInventoryId == null) return;

    final quantity = double.tryParse(_quantityController.text) ?? 1.0;

    final order = InventoryTransactionOrderEntity(
      id: 0,
      inventoryId: _selectedInventoryId,
      countUnits: quantity,
    );

    Navigator.of(context).pop(order);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return fluent.ContentDialog(
      title: Row(
        children: [
          fluent.Icon(
            fluent.FluentIcons.shopping_cart,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 8),
          fluent.Text(
            'إضافة بند جديد للحركة 📦',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 150,
              child: Center(child: fluent.ProgressRing()),
            )
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Select Inventory Item
                  ComboBoxForm<InventoryEntity>(
                    placeHolder: 'اختر الصنف',
                    prefix: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: fluent.Icon(fluent.FluentIcons.product),
                    ),
                    controller: _itemController,
                    decoration: const WidgetStatePropertyAll(
                      BoxDecoration(
                        border: Border.fromBorderSide(BorderSide.none),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    labelMenu: (item) => _getInventoryLabel(item),
                    labelString: (item) => _getInventoryLabel(item),
                    itemsBuilder: (value) {
                      final search = value.trim().toLowerCase();
                      return widget.inventoryItems.where((item) {
                        return _getInventoryLabel(
                          item,
                        ).toLowerCase().contains(search);
                      }).toList();
                    },
                    onSelectedItem: (item) {
                      setState(() {
                        _selectedInventoryId = item.id;
                      });
                    },
                    onChanged: (value) {
                      if (_selectedInventoryId != null &&
                          _itemController.text !=
                              _getInventoryLabel(
                                widget.inventoryItems.firstWhere(
                                  (it) => it.id == _selectedInventoryId!,
                                ),
                              )) {
                        setState(() {
                          _selectedInventoryId = null;
                        });
                      }
                    },
                    validator: (_) => _selectedInventoryId == null
                        ? 'الرجاء اختيار الصنف'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  fluent.TextFormBox(
                    controller: _quantityController,
                    textDirection: TextDirection.ltr,
                    decoration: const WidgetStatePropertyAll(
                      BoxDecoration(
                        border: Border.fromBorderSide(BorderSide.none),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'الرجاء إدخال الكمية';
                      }
                      final q = double.tryParse(val);
                      if (q == null || q <= 0) {
                        return 'الكمية يجب أن تكون أكبر من الصفر';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
      actions: [
        fluent.Button(
          onPressed: () => Navigator.of(context).pop(),
          child: const fluent.Text('إلغاء'),
        ),
        fluent.FilledButton(
          onPressed: _submit,
          child: const fluent.Text('إضافة البند'),
        ),
      ],
    );
  }
}
