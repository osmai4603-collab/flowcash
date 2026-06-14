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
  SubAccountEntity? _selectedPropertyAccount;
  final _categoryController = TextEditingController();

  List<SubAccountEntity> get _inventorySubAccounts {
    return _subAccounts
        .where((a) => a.subAccountType == SubAccountType.inventory)
        .toList();
  }

  List<SubAccountEntity> get _revenueSubAccounts {
    return _subAccounts
        .where(
          (a) =>
              a.subAccountType.mainAccountType == MainAccountType.sales ||
              a.subAccountType.mainAccountType == MainAccountType.salesReturn ||
              a.subAccountType.mainAccountType ==
                  MainAccountType.servicesRevenues,
        )
        .toList();
  }

  List<SubAccountEntity> get _expenseSubAccounts {
    return _subAccounts
        .where(
          (a) =>
              a.subAccountType.mainAccountType == MainAccountType.costOfSales ||
              a.subAccountType.mainAccountType == MainAccountType.buys ||
              a.subAccountType.mainAccountType == MainAccountType.buysReturn,
        )
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

            final selectedProperty = _subAccounts.where(
              (a) => a.id == item.propertyAccountId,
            );
            if (selectedProperty.isNotEmpty) {
              _selectedPropertyAccount = selectedProperty.first;
            }

            final selectedRevenue = _subAccounts.where(
              (a) => a.id == item.revenueAccountId,
            );
            if (selectedRevenue.isNotEmpty) {
              _selectedRevenueAccount = selectedRevenue.first;
            }

            final selectedExpense = _subAccounts.where(
              (a) => a.id == item.expenseAccountId,
            );
            if (selectedExpense.isNotEmpty) {
              _selectedExpenseAccount = selectedExpense.first;
            }

            final selectedIncomeStock = _subAccounts.where(
              (a) => a.id == item.incomeStockId,
            );
            if (selectedIncomeStock.isNotEmpty) {
              _selectedIncomeStock = selectedIncomeStock.first;
            }

            final selectedOutcomeStock = _subAccounts.where(
              (a) => a.id == item.outcomeStockId,
            );
            if (selectedOutcomeStock.isNotEmpty) {
              _selectedOutcomeStock = selectedOutcomeStock.first;
            }
          }

          if (!_isEdit &&
              _selectedWarehouse == null &&
              _warehouses.length == 1) {
            _selectedWarehouse = _warehouses.first;
          }

          _isLoadingData = false;
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
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null ||
        _selectedWarehouse == null ||
        _selectedPropertyAccount == null ||
        _selectedRevenueAccount == null ||
        _selectedExpenseAccount == null ||
        _selectedIncomeStock == null ||
        _selectedOutcomeStock == null) {
      fluent.displayInfoBar(
        context,
        builder: (context, close) => fluent.InfoBar(
          title: const fluent.Text('تنبيه'),
          content: fluent.Text('الرجاء اختيار الصنف والمستودع وتحديد جميع الحسابات المالية'),
        ),
      );
      return;
    }

    final resultItem = InventoryItemEntity(
      id: _isEdit ? widget.item!.id : 0,
      categoryId: _selectedCategory!.id,
      storeId: _selectedWarehouse!.id,
      propertyAccountId: _selectedPropertyAccount!.id,
      revenueAccountId: _selectedRevenueAccount!.id,
      expenseAccountId: _selectedExpenseAccount!.id,
      incomeStockId: _selectedIncomeStock!.id,
      outcomeStockId: _selectedOutcomeStock!.id,
      inventoryName:
          _selectedCategory?.categoryName ?? widget.item?.inventoryName ?? '',
      countUnits: widget.item?.countUnits ?? 0.0,
      costTotal: widget.item?.costTotal ?? 0,
      userId: widget.item?.userId ?? 1,
    );

    Navigator.of(context).pop(resultItem);
  }

  Widget _buildResponsiveFieldRow({
    required Widget first,
    required Widget second,
    double spacing = 16,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              SizedBox(height: spacing),
              second,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            SizedBox(width: spacing),
            Expanded(child: second),
          ],
        );
      },
    );
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
        padding: Paddings.mediumAll,
        child: _isLoadingData
            ? _InventoryShimmer()
            : _buildInventoryForm(theme, context),
      ),
    );
  }

  Form _buildInventoryForm(ThemeData theme, BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Row(
              children: [
                fluent.Icon(
                  _isEdit
                      ? fluent.FluentIcons.edit_note
                      : fluent.FluentIcons.add,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                fluent.Text(
                  _isEdit
                      ? 'تعديل بيانات صنف المخزون'
                      : 'إضافة صنف جديد للمخزون',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                fluent.IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const fluent.Icon(fluent.FluentIcons.chrome_close),
                ),
              ],
            ),

            // Form Content
            Column(
              spacing: Spacings.small,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 8),
                // 1. Basic properties Row
                fluent.InfoLabel(
                  label: 'الصنف الأساسي',
                  child: ComboBoxForm<CategoryEntity>(
                    controller: _categoryController,
                    prefix: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: fluent.Icon(
                        fluent.FluentIcons.category_classification,
                        size: 16,
                      ),
                    ),
                    placeHolder: 'اختر الصنف الأساسي',
                    labelMenu: (category) => category.categoryName,
                    labelString: (category) => category.categoryName,
                    itemsBuilder: (value) {
                      final search = value.trim().toLowerCase();
                      return _categories.where((category) {
                        return category.categoryName.toLowerCase().contains(
                          search,
                        );
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
                    validator: (_) =>
                        _selectedCategory == null ? 'مطلوب اختيار الصنف' : null,
                  ),
                ),

                // 2. Warehouse & Count Units Row (costType removed)
                fluent.InfoLabel(
                  label: 'المستودع/المخزن',
                  child: fluent.ComboBox<WarehouseEntity>(
                    isExpanded: true,
                    value: _selectedWarehouse,
                    placeholder: const fluent.Text('اختر المستودع'),
                    items: _warehouses.map((w) {
                      return fluent.ComboBoxItem<WarehouseEntity>(
                        value: w,
                        child: fluent.Text(w.warehouseName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedWarehouse = val;
                      });
                    },
                  ),
                ),

                const Divider(height: 8),
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

                fluent.InfoLabel(
                  label: 'حساب البضاعة (الأصول)',
                  child: fluent.ComboBox<SubAccountEntity>(
                    isExpanded: true,
                    value: _selectedPropertyAccount,
                    placeholder: const fluent.Text('اختر حساب البضاعة/الأصول'),
                    disabledPlaceholder: const fluent.Text(
                      'لا يوجد حسابات متاحة',
                    ),
                    icon: const fluent.Icon(fluent.FluentIcons.chevron_down),
                    items: _inventorySubAccounts.map((a) {
                      return fluent.ComboBoxItem<SubAccountEntity>(
                        value: a,
                        child: fluent.Text(
                          '${a.accountName} (${a.accountNumber})',
                        ),
                      );
                    }).toList(),
                    onChanged: _inventorySubAccounts.isEmpty
                        ? null
                        : (val) => setState(() {
                              _selectedPropertyAccount = val;
                            }),
                  ),
                ),

                // 3. Accounts Selection Grid
                _buildResponsiveFieldRow(
                  first: fluent.InfoLabel(
                    label: 'حساب الإيرادات',
                    child: fluent.ComboBox<SubAccountEntity>(
                      isExpanded: true,
                      value: _selectedRevenueAccount,
                      placeholder: const fluent.Text('اختر حساب الإيرادات'),
                      disabledPlaceholder: const fluent.Text(
                        'لا يوجد حسابات متاحة',
                      ),
                      icon: const fluent.Icon(fluent.FluentIcons.chevron_down),
                      items: _revenueSubAccounts.map((a) {
                        return fluent.ComboBoxItem<SubAccountEntity>(
                          value: a,
                          child: fluent.Text(
                            '${a.accountName} (${a.accountNumber})',
                          ),
                        );
                      }).toList(),
                      onChanged: _revenueSubAccounts.isEmpty
                          ? null
                          : (val) => setState(() {
                              _selectedRevenueAccount = val;
                            }),
                    ),
                  ),
                  second: fluent.InfoLabel(
                    label: 'حساب المصروفات',
                    child: fluent.ComboBox<SubAccountEntity>(
                      isExpanded: true,
                      value: _selectedExpenseAccount,
                      placeholder: const fluent.Text('اختر حساب المصروفات'),
                      disabledPlaceholder: const fluent.Text(
                        'لا يوجد حسابات متاحة',
                      ),
                      icon: const fluent.Icon(fluent.FluentIcons.chevron_down),
                      items: _expenseSubAccounts.map((a) {
                        return fluent.ComboBoxItem<SubAccountEntity>(
                          value: a,
                          child: fluent.Text(
                            '${a.accountName} (${a.accountNumber})',
                          ),
                        );
                      }).toList(),
                      onChanged: _expenseSubAccounts.isEmpty
                          ? null
                          : (val) => setState(() {
                              _selectedExpenseAccount = val;
                            }),
                    ),
                  ),
                ),

                _buildResponsiveFieldRow(
                  first: fluent.InfoLabel(
                    label: 'حساب مخزون الوارد',
                    child: fluent.ComboBox<SubAccountEntity>(
                      isExpanded: true,
                      value: _selectedIncomeStock,
                      placeholder: const fluent.Text('اختر حساب مخزون الوارد'),
                      disabledPlaceholder: const fluent.Text(
                        'لا يوجد حسابات متاحة',
                      ),
                      icon: const fluent.Icon(fluent.FluentIcons.chevron_down),
                      items: _inventorySubAccounts.map((a) {
                        return fluent.ComboBoxItem<SubAccountEntity>(
                          value: a,
                          child: fluent.Text(
                            '${a.accountName} (${a.accountNumber})',
                          ),
                        );
                      }).toList(),
                      onChanged: _inventorySubAccounts.isEmpty
                          ? null
                          : (val) => setState(() {
                              _selectedIncomeStock = val;
                            }),
                    ),
                  ),
                  second: fluent.InfoLabel(
                    label: 'حساب مخزون الصادر',
                    child: fluent.ComboBox<SubAccountEntity>(
                      isExpanded: true,
                      value: _selectedOutcomeStock,
                      placeholder: const fluent.Text('اختر حساب مخزون الصادر'),
                      disabledPlaceholder: const fluent.Text(
                        'لا يوجد حسابات متاحة',
                      ),
                      icon: const fluent.Icon(fluent.FluentIcons.chevron_down),
                      items: _inventorySubAccounts.map((a) {
                        return fluent.ComboBoxItem<SubAccountEntity>(
                          value: a,
                          child: fluent.Text(
                            '${a.accountName} (${a.accountNumber})',
                          ),
                        );
                      }).toList(),
                      onChanged: _inventorySubAccounts.isEmpty
                          ? null
                          : (val) => setState(() {
                              _selectedOutcomeStock = val;
                            }),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 16),
            // Action buttons
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const fluent.Icon(fluent.FluentIcons.save, size: 16),
                      const SizedBox(width: 8),
                      fluent.Text(_isEdit ? 'حفظ التعديلات' : 'إضافة الصنف'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
          spacing: Spacings.small,
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
