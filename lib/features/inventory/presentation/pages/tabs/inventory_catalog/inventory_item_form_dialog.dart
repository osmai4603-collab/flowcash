import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flutter/material.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
// Inventory cost type removed
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/widgets/combo_box_form.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
class InventoryItemFormDialog extends StatefulWidget {
  final InventoryEntity? item;

  const InventoryItemFormDialog({super.key, this.item});

  @override
  State<InventoryItemFormDialog> createState() =>
      _InventoryItemFormDialogState();
}

class _InventoryItemFormDialogState extends State<InventoryItemFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late bool _isEdit;

  // Form fields
  CategoryEntity? _selectedCategory;
  WarehouseEntity? _selectedWarehouse;
  // costType removed
  SubAccountEntity? _selectedRevenueAccount;
  SubAccountEntity? _selectedExpenseAccount;
  SubAccountEntity? _selectedIncomeStock;
  SubAccountEntity? _selectedOutcomeStock;
  final _categoryController = TextEditingController();
  final _countUnitsController = TextEditingController();

  List<SubAccountEntity> get _inventorySubAccounts {
    return _subAccounts
        .where((a) => a.subAccountType == SubAccountType.inventory)
        .toList();
  }

  List<SubAccountEntity> get _revenueSubAccounts {
    return _subAccounts
        .where((a) => a.subAccountType.mainAccountType == MainAccountType.sales || 
            a.subAccountType.mainAccountType == MainAccountType.salesReturn || 
            a.subAccountType.mainAccountType == MainAccountType.servicesRevenues)
        .toList();
  }
    List<SubAccountEntity> get _expenseSubAccounts {
    return _subAccounts
      .where((a) => a.subAccountType.mainAccountType == MainAccountType.costOfSales ||
        a.subAccountType.mainAccountType == MainAccountType.buys || 
        a.subAccountType.mainAccountType == MainAccountType.buysReturn)
      .toList();
    }

  // Loaded data lists
  List<CategoryEntity> _categories = [];
  List<WarehouseEntity> _warehouses = [];
  List<SubAccountEntity> _subAccounts = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.item != null;
    if (_isEdit) {
      final item = widget.item!;
      _countUnitsController.text = item.countUnits.toString();
    } else {
      _countUnitsController.text = "1.0";
    }
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading delay
    try {
      final categoriesRes = await sl<GetAllCategoriesUseCase>().call();
      final warehousesRes = await sl<GetWarehousesUseCase>().call();
      final subAccountsRes = await sl<GetSubAccountsUseCase>().call();

      if (mounted) {
        setState(() {
          categoriesRes.fold((_) => null, (list) => _categories = list);
          warehousesRes.fold((_) => null, (list) => _warehouses = list);
          subAccountsRes.fold((_) => null, (list) => _subAccounts = list);
          if (_isEdit && widget.item != null) {
            final item = widget.item!;
            final selectedCategory = _categories.where(
              (c) => c.id == item.categoryId,
            );
            if (selectedCategory.isNotEmpty) {
              _selectedCategory = selectedCategory.first;
              _categoryController.text = _selectedCategory!.categoryName;
            }

            final selectedWarehouse = _warehouses.where(
              (w) => w.id == item.storeId,
            );
            if (selectedWarehouse.isNotEmpty) {
              _selectedWarehouse = selectedWarehouse.first;
            }

            if (item.revenueAccountId != null) {
              final selectedRevenue = _subAccounts.where(
                (a) => a.id == item.revenueAccountId,
              );
              if (selectedRevenue.isNotEmpty) {
                _selectedRevenueAccount = selectedRevenue.first;
              }
            }

            if (item.expenseAccountId != null) {
              final selectedExpense = _subAccounts.where(
                (a) => a.id == item.expenseAccountId,
              );
              if (selectedExpense.isNotEmpty) {
                _selectedExpenseAccount = selectedExpense.first;
              }
            }

            if (item.incomeStockId != null) {
              final selectedIncomeStock = _subAccounts.where(
                (a) => a.id == item.incomeStockId,
              );
              if (selectedIncomeStock.isNotEmpty) {
                _selectedIncomeStock = selectedIncomeStock.first;
              }
            }

            if (item.outcomeStockId != null) {
              final selectedOutcomeStock = _subAccounts.where(
                (a) => a.id == item.outcomeStockId,
              );
              if (selectedOutcomeStock.isNotEmpty) {
                _selectedOutcomeStock = selectedOutcomeStock.first;
              }
            }
          }

          if (!_isEdit &&
              _selectedWarehouse == null &&
              _warehouses.length == 1) {
            _selectedWarehouse = _warehouses.first;
          }

                        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _countUnitsController.dispose();
    super.dispose();
  }

  Widget _buildResponsiveFieldRow({required Widget first, Widget? second}) {
    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second ?? const SizedBox.shrink()),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedWarehouse == null) {
      fluent.displayInfoBar(context, builder: (context, close) => fluent.InfoBar(title: const fluent.Text('تنبيه'), content: fluent.Text('الرجاء اختيار الصنف والمستودع')));
      return;
    }

    final countUnits = double.tryParse(_countUnitsController.text) ?? 1.0;
                        
    final resultItem = InventoryItemEntity(
      id: _isEdit ? widget.item!.id : 0,
      categoryId: _selectedCategory!.id,
      storeId: _selectedWarehouse!.id,
      revenueAccountId: _selectedRevenueAccount?.id,
      expenseAccountId: _selectedExpenseAccount?.id,
      incomeStockId: _selectedIncomeStock?.id,
      outcomeStockId: _selectedOutcomeStock?.id,
      inventoryName: _selectedCategory?.categoryName ?? widget.item?.inventoryName ?? '',
      countUnits: countUnits,
      unitCost: widget.item?.unitCost ?? 0,
    );

    Navigator.of(context).pop(resultItem);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return fluent.ContentDialog(
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      content: Padding(
        padding: Paddings.largeAll,
        child: _isLoadingData
            ? _InventoryShimmer()
            : _buildInventoryForm(theme, context),
      ),
    );
  }

  Form _buildInventoryForm(ThemeData theme, BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _isEdit ? fluent.FluentIcons.edit_note : fluent.FluentIcons.add,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 10),
              fluent.Text(
                _isEdit ? 'تعديل بيانات صنف المخزون' : 'إضافة صنف جديد للمخزون',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const fluent.Icon(fluent.FluentIcons.chrome_close),
              ),
            ],
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                spacing: Spacings.large,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 24),
                  // 1. Basic properties Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: fluent.InfoLabel(
                          label: 'الصنف الأساسي',
                          child: ComboBoxForm<CategoryEntity>(
                            controller: _categoryController,
                            decoration: InputDecoration(
                              labelText: 'الصنف الأساسي',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: fluent.Icon(fluent.FluentIcons.category_classification),
                              ),
                            ),
                            labelMenu: (category) => category.categoryName,
                            labelString: (category) => category.categoryName,
                            itemsBuilder: (value) {
                              final search = value.trim().toLowerCase();
                              return _categories.where((category) {
                                return category.categoryName
                                    .toLowerCase()
                                    .contains(search);
                              }).toList();
                            },
                            onSelectedItem: (category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            onChanged: (value) {
                              if (_selectedCategory != null &&
                                  _selectedCategory!.categoryName != value) {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              }
                            },
                            validator: (_) => _selectedCategory == null
                                ? 'مطلوب اختيار الصنف'
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: fluent.InfoLabel(
                          label: 'عدد الوحدات الافتراضية',
                          child: fluent.TextFormBox(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            textDirection: TextDirection.ltr,
                            controller: _countUnitsController,
                            
                            prefix: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: fluent.Icon(fluent.FluentIcons.numbered_list_number),
                            ),
                            suffix: fluent.Text(
                              _selectedCategory?.categoryUnit?.unitName ?? 'وحدة',
                            ),
                            suffixMode: fluent.OverlayVisibilityMode.always,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'مطلوب';
                              }
                              if (double.tryParse(val) == null) {
                                return 'قيمة غير صالحة';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. Warehouse & Count Units Row (costType removed)
                  _buildResponsiveFieldRow(
                    second: const SizedBox.shrink(),
                    first: FormField<int>(
                      key: ValueKey(_selectedWarehouse?.id),
                      initialValue: _selectedWarehouse?.id,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          value == null ? 'مطلوب اختيار المستودع' : null,
                      builder: (field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            fluent.InfoLabel(
                              label: 'المستودع/المخزن',
                              child: fluent.ComboBox<int>(
                                value: _selectedWarehouse?.id,
                                placeholder: const fluent.Text('اختر المستودع'),
                                isExpanded: true,
                                icon: const fluent.Icon(
                                  fluent.FluentIcons.chevron_down,
                                ),
                                items: _warehouses.map((w) {
                                  return fluent.ComboBoxItem<int>(
                                    value: w.id,
                                    child: fluent.Text(w.warehouseName),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedWarehouse = val == null
                                        ? null
                                        : _warehouses.firstWhere(
                                            (w) => w.id == val);
                                    field.didChange(val);
                                  });
                                },
                              ),
                            ),
                            if (field.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: fluent.Text(
                                  field.errorText!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  const Divider(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const fluent.Text(
                        'الحسابات المالية المرتبطة بالمخزون',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const fluent.Text(
                        'اختر الحسابات المالية الدفترية المناسبة لتوجيه حركات المخزون تلقائياً:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),

                  // 3. Accounts Selection Grid
                  _buildResponsiveFieldRow(
                    first: FormField<int>(
                      key: ValueKey(_selectedRevenueAccount?.id),
                      initialValue: _selectedRevenueAccount?.id,
                      builder: (field) {
                        return fluent.InfoLabel(
                          label: 'حساب الإيرادات',
                          child: fluent.ComboBox<int>(
                            value: _selectedRevenueAccount?.id,
                            placeholder:
                                const fluent.Text('اختر حساب الإيرادات'),
                            disabledPlaceholder:
                                const fluent.Text('لا يوجد حسابات متاحة'),
                            isExpanded: true,
                            icon: const fluent.Icon(
                              fluent.FluentIcons.chevron_down,
                            ),
                            items: _revenueSubAccounts.map((a) {
                              return fluent.ComboBoxItem<int>(
                                value: a.id,
                                child: fluent.Text('${a.accountName} (${a.accountNumber})'),
                              );
                            }).toList(),
                            onChanged: _revenueSubAccounts.isEmpty
                                ? null
                                : (val) => setState(() {
                                    _selectedRevenueAccount = val == null
                                        ? null
                                        : _revenueSubAccounts.firstWhere(
                                            (a) => a.id == val,
                                          );
                                    field.didChange(val);
                                  }),
                          ),
                        );
                      },
                    ),
                    second: FormField<int>(
                      key: ValueKey(_selectedExpenseAccount?.id),
                      initialValue: _selectedExpenseAccount?.id,
                      builder: (field) {
                        return fluent.InfoLabel(
                          label: 'حساب المصروفات',
                          child: fluent.ComboBox<int>(
                            value: _selectedExpenseAccount?.id,
                            placeholder:
                                const fluent.Text('اختر حساب المصروفات'),
                            disabledPlaceholder:
                                const fluent.Text('لا يوجد حسابات متاحة'),
                            isExpanded: true,
                            icon: const fluent.Icon(
                              fluent.FluentIcons.chevron_down,
                            ),
                            items: _expenseSubAccounts.map((a) {
                              return fluent.ComboBoxItem<int>(
                                value: a.id,
                                child: fluent.Text('${a.accountName} (${a.accountNumber})'),
                              );
                            }).toList(),
                            onChanged: _expenseSubAccounts.isEmpty
                                ? null
                                : (val) => setState(() {
                                    _selectedExpenseAccount = val == null
                                        ? null
                                        : _expenseSubAccounts.firstWhere(
                                            (a) => a.id == val,
                                          );
                                    field.didChange(val);
                                  }),
                          ),
                        );
                      },
                    ),
                  ),

                  _buildResponsiveFieldRow(
                    first: FormField<int>(
                      key: ValueKey(_selectedIncomeStock?.id),
                      initialValue: _selectedIncomeStock?.id,
                      builder: (field) {
                        return fluent.InfoLabel(
                          label: 'حساب مخزون الوارد',
                          child: fluent.ComboBox<int>(
                            value: _selectedIncomeStock?.id,
                            placeholder:
                                const fluent.Text('اختر حساب مخزون الوارد'),
                            disabledPlaceholder:
                                const fluent.Text('لا يوجد حسابات متاحة'),
                            isExpanded: true,
                            icon: const fluent.Icon(
                              fluent.FluentIcons.chevron_down,
                            ),
                            items: _inventorySubAccounts.map((a) {
                              return fluent.ComboBoxItem<int>(
                                value: a.id,
                                child: fluent.Text('${a.accountName} (${a.accountNumber})'),
                              );
                            }).toList(),
                            onChanged: _inventorySubAccounts.isEmpty
                                ? null
                                : (val) => setState(() {
                                    _selectedIncomeStock = val == null
                                        ? null
                                        : _inventorySubAccounts.firstWhere(
                                            (a) => a.id == val,
                                          );
                                    field.didChange(val);
                                  }),
                          ),
                        );
                      },
                    ),
                    second: FormField<int>(
                      key: ValueKey(_selectedOutcomeStock?.id),
                      initialValue: _selectedOutcomeStock?.id,
                      builder: (field) {
                        return fluent.InfoLabel(
                          label: 'حساب مخزون الصارد',
                          child: fluent.ComboBox<int>(
                            value: _selectedOutcomeStock?.id,
                            placeholder:
                                const fluent.Text('اختر حساب مخزون الصادر'),
                            disabledPlaceholder:
                                const fluent.Text('لا يوجد حسابات متاحة'),
                            isExpanded: true,
                            icon: const fluent.Icon(
                              fluent.FluentIcons.chevron_down,
                            ),
                            items: _inventorySubAccounts.map((a) {
                              return fluent.ComboBoxItem<int>(
                                value: a.id,
                                child: fluent.Text('${a.accountName} (${a.accountNumber})'),
                              );
                            }).toList(),
                            onChanged: _inventorySubAccounts.isEmpty
                                ? null
                                : (val) => setState(() {
                                    _selectedOutcomeStock = val == null
                                        ? null
                                        : _inventorySubAccounts.firstWhere(
                                            (a) => a.id == val,
                                          );
                                    field.didChange(val);
                                  }),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const Divider(height: 24),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              fluent.Button(
                onPressed: () => Navigator.of(context).pop(),
                child: const fluent.Text('إلغاء'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: fluent.Icon(fluent.FluentIcons.save),
                label: fluent.Text(_isEdit ? 'حفظ التعديلات' : 'إضافة الصنف'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InventoryShimmer extends StatelessWidget {
  const _InventoryShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        child: Column(
          spacing: Spacings.large,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                ShimmerPlaceholder(height: 50),
                SizedBox(height: Spacings.medium),
                Divider(height: 0),
                SizedBox(height: Spacings.large),
              ],
            ),
            Row(
              children: [
                Expanded(flex: 4, child: ShimmerPlaceholder()),
                SizedBox(width: Spacings.large),
                Expanded(flex: 2, child: ShimmerPlaceholder()),
              ],
            ),
            Row(
              children: [
                Expanded(child: ShimmerPlaceholder()),
                SizedBox(width: Spacings.large),
                Expanded(child: ShimmerPlaceholder()),
              ],
            ),

            Divider(height: 24),
            ShimmerPlaceholder(height: 50),
            Row(
              children: [
                Expanded(child: ShimmerPlaceholder()),
                SizedBox(width: Spacings.large),
                Expanded(child: ShimmerPlaceholder()),
              ],
            ),
            Row(
              children: [
                Expanded(child: ShimmerPlaceholder()),
                SizedBox(width: Spacings.large),
                Expanded(child: ShimmerPlaceholder()),
              ],
            ),
            Column(
              children: [
                Divider(height: 0),
                SizedBox(height: Spacings.xsmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShimmerPlaceholder(width: 50, height: 35),
                    SizedBox(width: Spacings.small),
                    ShimmerPlaceholder(width: 160, height: 35),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
