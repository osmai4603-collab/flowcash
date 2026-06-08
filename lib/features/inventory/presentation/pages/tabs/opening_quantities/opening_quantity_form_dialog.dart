import 'package:flutter/material.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/combo_box_form.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class OpeningQuantityFormDialog extends StatefulWidget {
  final List<InventoryEntity> inventoryItems;

  const OpeningQuantityFormDialog({super.key, required this.inventoryItems});

  @override
  State<OpeningQuantityFormDialog> createState() =>
      _OpeningQuantityFormDialogState();
}

class _OpeningQuantityFormDialogState extends State<OpeningQuantityFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _inventoryItemController = TextEditingController();
  int? _selectedInventoryId;
  final _quantityController = TextEditingController();
  final _costTotalController = TextEditingController();

  List<CategoryEntity> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _quantityController.text = "1.0";
    _costTotalController.text = "0.0";
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

  String _getInventoryLabel(InventoryEntity item) {
    try {
      return _categories
          .firstWhere((c) => c.id == item.categoryId)
          .categoryName;
    } catch (_) {
      return 'صنف مخزون (#${item.id})';
    }
  }

  @override
  void dispose() {
    _inventoryItemController.dispose();
    _quantityController.dispose();
    _costTotalController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInventoryId == null) return;

    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final totalCost = double.tryParse(_costTotalController.text) ?? 0.0;

    final entity = OpeningQuantityEntity(
      id: 0,
      inventoryId: _selectedInventoryId!,
      countUnits: quantity,
      costTotal: totalCost,
      createdAt: DateTime.now(),
      periodId: 1, // Standard accounting period
    );

    Navigator.of(context).pop(entity);
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
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withAlpha(240),
                  ]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 200,
                child: Center(child: fluent.ProgressRing()),
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        fluent.Icon(
                          fluent.FluentIcons.page_checked_out,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        const fluent.Text(
                          'إضافة رصيد افتتاحي 📊',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Inventory Item
                    ComboBoxForm<InventoryEntity>(
                      controller: _inventoryItemController,
                      decoration: const InputDecoration(
                        labelText: 'اختر صنف المخزون',
                        prefixIcon: fluent.Icon(fluent.FluentIcons.product),
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
                            _inventoryItemController.text !=
                                _getInventoryLabel(
                                  widget.inventoryItems.firstWhere(
                                    (item) => item.id == _selectedInventoryId!,
                                  ),
                                )) {
                          setState(() {
                            _selectedInventoryId = null;
                          });
                        }
                      },
                      validator: (_) =>
                          _selectedInventoryId == null ? 'الصنف مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    // Quantity & Total Cost
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              labelText: 'الكمية الافتتاحية',
                              prefixIcon: fluent.Icon(
                                fluent.FluentIcons.numbered_list_number,
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'الكمية مطلوبة'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _costTotalController,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              labelText: 'إجمالي التكلفة الدفترية',
                              prefixIcon: fluent.Icon(fluent.FluentIcons.money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'التكلفة مطلوبة'
                                : null,
                          ),
                        ),
                      ],
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
                          child: const fluent.Text('حفظ الرصيد الافتتاحي'),
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
