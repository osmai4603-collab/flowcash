import 'package:flutter/material.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
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
  String? _selectedCurrencyId;
  final _quantityController = TextEditingController();
  final _costTotalController = TextEditingController();

  List<CategoryEntity> _categories = [];
  List<CurrencyEntity> _currencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _quantityController.text = "1.0";
    _costTotalController.text = "0.0";
    _loadData();
  }

  Future<void> _loadData() async {
    final categoriesRes = await sl<GetAllCategoriesUseCase>().call();
    final currenciesRes = await sl<GetCurrenciesUseCase>().call();

    if (!mounted) return;

    setState(() {
      categoriesRes.fold((_) => null, (list) => _categories = list);
      currenciesRes.fold((_) => null, (list) => _currencies = list);
      _isLoading = false;
    });
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

  String _getCurrencyLabel(CurrencyEntity item) {
    return '${item.name} (${item.symbol})';
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
      currencyId: _selectedCurrencyId!,
    );

    Navigator.of(context).pop(entity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return fluent.ContentDialog(
      constraints: BoxConstraints(maxWidth: 500),
      content: _isLoading
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
                  fluent.InfoLabel(
                    label: 'اختر صنف المخزون',
                    child: ComboBoxForm<InventoryEntity>(
                      placeHolder: 'ادخل اسم الصنف',
                      controller: _inventoryItemController,
                      prefix: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: fluent.Icon(fluent.FluentIcons.product),
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
                  ),
                  const SizedBox(height: 16),

                  // Currency
                  fluent.ComboboxFormField<CurrencyEntity>(
                    items: _currencies
                        .map(
                          (currency) => fluent.ComboBoxItem<CurrencyEntity>(
                            value: currency,
                            child: fluent.Text(_getCurrencyLabel(currency)),
                          ),
                        )
                        .toList(),
                    value: _selectedCurrencyId == null || _currencies.isEmpty
                        ? null
                        : _currencies.firstWhere(
                            (item) => item.id == _selectedCurrencyId,
                            orElse: () => _currencies.first,
                          ),
                    placeholder: const fluent.Text('اختر العملة'),
                    isExpanded: true,
                    validator: (value) {
                      if (value == null) return 'العملة مطلوبة';
                      return null;
                    },
                    onChanged: (currency) {
                      setState(() {
                        _selectedCurrencyId = currency?.id;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quantity & Total Cost
                  Row(
                    children: [
                      Expanded(
                        child: fluent.InfoLabel(
                          label: 'الكمية الافتتاحية',
                          child: fluent.TextFormBox(
                            controller: _quantityController,
                            textDirection: TextDirection.ltr,
                            placeholder: 'ادخل الكمية الافتتاحية',
                            prefix: const fluent.Padding(
                              padding: EdgeInsets.all(8.0),
                              child: fluent.Icon(
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: fluent.InfoLabel(
                          label: 'إجمالي التكلفة الدفترية',
                          child: fluent.TextFormBox(
                            controller: _costTotalController,
                            textDirection: TextDirection.ltr,
                            placeholder: 'إجمالي التكلفة الدفترية',
                            prefix: const fluent.Icon(fluent.FluentIcons.money),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'التكلفة مطلوبة'
                                : null,
                          ),
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
    );
  }
}
