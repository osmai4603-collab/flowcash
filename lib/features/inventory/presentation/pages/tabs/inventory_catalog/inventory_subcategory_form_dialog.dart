import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flutter/material.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/widgets/combo_box_form.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class InventorySubcategoryFormDialog extends StatefulWidget {
  const InventorySubcategoryFormDialog({super.key});

  @override
  State<InventorySubcategoryFormDialog> createState() =>
      _InventorySubcategoryFormDialogState();
}

class _InventorySubcategoryFormDialogState
    extends State<InventorySubcategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  SubcategoryEntity? _selectedSubcategory;
  WarehouseEntity? _selectedWarehouse;
  SubAccountEntity? _selectedRevenueAccount;
  SubAccountEntity? _selectedExpenseAccount;
  SubAccountEntity? _selectedIncomeStock;
  SubAccountEntity? _selectedOutcomeStock;
  SubAccountEntity? _selectedPropertyAccount;
  final _subcategoryController = TextEditingController();

  List<SubAccountEntity> get _inventorySubAccounts {
    return _subAccounts
        .where(
          (a) => a.subAccountType.mainAccountType == MainAccountType.inventory,
        )
        .toList();
  }

  List<SubAccountEntity> get _propertySubAccounts {
    return _subAccounts
        .where(
          (a) =>
              a.subAccountType.mainAccountType.accountType ==
              MainAccountGroup.propertyRights,
        )
        .toList();
  }

  List<SubAccountEntity> get _revenueSubAccounts {
    return _subAccounts
        .where(
          (a) =>
              a.subAccountType.mainAccountType.accountType ==
              MainAccountGroup.revenues,
        )
        .toList();
  }

  List<SubAccountEntity> get _expenseSubAccounts {
    return _subAccounts
        .where(
          (a) =>
              a.subAccountType.mainAccountType.accountType ==
              MainAccountGroup.expenses,
        )
        .toList();
  }

  // Loaded data lists
  List<SubcategoryEntity> _subcategories = [];
  List<CategoryEntity> _categories = [];
  List<CategoryEntity> _resolvedCategories = [];
  List<WarehouseEntity> _warehouses = [];
  List<SubAccountEntity> _subAccounts = [];
  List<InventoryEntity> _existingInventoryItems = [];
  bool _isLoadingData = true;
  bool _isResolvingCategories = false;

  List<CategoryEntity> get _filteredResolvedCategories {
    if (_selectedWarehouse == null) return _resolvedCategories;
    return _resolvedCategories.where((cat) {
      final exists = _existingInventoryItems.any((item) => 
          item.categoryId == cat.id && item.storeId == _selectedWarehouse!.id);
      return !exists;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final subcategoriesRes = await sl<GetAllSubcategoriesUseCase>().call();
      final categoriesRes = await sl<GetAllCategoriesUseCase>().call();
      final warehousesRes = await sl<GetWarehousesUseCase>().call();
      final subAccountsRes = await sl<GetSubAccountsUseCase>().call();
      final inventoryRes = await sl<GetInventorysUseCase>().call();

      if (mounted) {
        setState(() {
          subcategoriesRes.fold((_) => null, (list) => _subcategories = list);
          categoriesRes.fold((_) => null, (list) => _categories = list);
          warehousesRes.fold((_) => null, (list) => _warehouses = list);
          subAccountsRes.fold((_) => null, (list) => _subAccounts = list);
          inventoryRes.fold((_) => null, (list) => _existingInventoryItems = list);

          if (_selectedWarehouse == null && _warehouses.length == 1) {
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

  Future<void> _onSubcategorySelected(SubcategoryEntity? subcategory) async {
    if (subcategory == null) {
      setState(() {
        _selectedSubcategory = null;
        _resolvedCategories = [];
      });
      return;
    }

    setState(() {
      _selectedSubcategory = subcategory;
      _isResolvingCategories = true;
    });

    try {
      final resolved = _categories
          .where((c) => c.subcategoryId == subcategory.id)
          .toList();

      setState(() {
        _resolvedCategories = resolved;
        _isResolvingCategories = false;
      });
    } catch (_) {
      setState(() {
        _resolvedCategories = [];
        _isResolvingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _subcategoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubcategory == null ||
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
          content: const fluent.Text(
            'الرجاء اختيار الصنف الفرعي والمستودع وتحديد جميع الحسابات المالية',
          ),
        ),
      );
      return;
    }

    if (_filteredResolvedCategories.isEmpty) {
      fluent.displayInfoBar(
        context,
        builder: (context, close) => fluent.InfoBar(
          title: const fluent.Text('تنبيه'),
          content: const fluent.Text(
            'جميع الأصناف التابعة لهذا الصنف الفرعي موجودة مسبقاً في هذا المستودع.',
          ),
        ),
      );
      return;
    }

    final resultItems = _filteredResolvedCategories.map((category) {
      return InventoryItemEntity(
        id: 0,
        categoryId: category.id,
        storeId: _selectedWarehouse!.id,
        propertyAccountId: _selectedPropertyAccount!.id,
        revenueAccountId: _selectedRevenueAccount!.id,
        expenseAccountId: _selectedExpenseAccount!.id,
        incomeStockId: _selectedIncomeStock!.id,
        outcomeStockId: _selectedOutcomeStock!.id,
        inventoryName: category.categoryName,
        countUnits: 0.0,
        costTotal: 0,
        userId: 1,
      );
    }).toList();

    Navigator.of(context).pop(resultItems);
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
            ? const _InventoryShimmer()
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
                  fluent.FluentIcons.add,
                  color: theme.colorScheme.secondary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const fluent.Text(
                  'إضافة كتالوج مخزون جديد (بالصنف الفرعي)',
                  style: TextStyle(
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
                // 1. Basic properties Row (Subcategory Selection)
                fluent.InfoLabel(
                  label: 'الصنف الفرعي (الكتالوج)',
                  child: ComboBoxForm<SubcategoryEntity>(
                    controller: _subcategoryController,
                    prefix: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: fluent.Icon(
                        fluent.FluentIcons.all_apps,
                        size: 16,
                      ),
                    ),
                    placeHolder: 'اختر الصنف الفرعي',
                    labelMenu: (subcategory) => subcategory.catalogName,
                    labelString: (subcategory) => subcategory.catalogName,
                    itemsBuilder: (value) {
                      final search = value.trim().toLowerCase();
                      return _subcategories.where((subcategory) {
                        return subcategory.catalogName.toLowerCase().contains(
                          search,
                        );
                      }).toList();
                    },
                    onSelectedItem: (subcategory) {
                      _onSubcategorySelected(subcategory);
                    },
                    onChanged: (value) {
                      if (_selectedSubcategory != null &&
                          _selectedSubcategory!.catalogName != value) {
                        _onSubcategorySelected(null);
                      }
                    },
                    validator: (_) =>
                        _selectedSubcategory == null ? 'مطلوب اختيار الصنف الفرعي' : null,
                  ),
                ),

                if (_isResolvingCategories)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: fluent.ProgressRing(),
                    ),
                  )
                else if (_selectedSubcategory != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: fluent.Text(
                      'سيتم إنشاء ${_filteredResolvedCategories.length} سطر مخزون جديد تلقائياً عند الحفظ',
                      style: const TextStyle(
                        color: fluent.Colors.successPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // 2. Warehouse
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
                  label: 'حساب البضاعة (رأس المال)',
                  child: fluent.ComboBox<SubAccountEntity>(
                    isExpanded: true,
                    value: _selectedPropertyAccount,
                    placeholder: const fluent.Text('اختر حساب راس المال'),
                    disabledPlaceholder: const fluent.Text(
                      'لا يوجد حسابات متاحة',
                    ),
                    icon: const fluent.Icon(fluent.FluentIcons.chevron_down),
                    items: _propertySubAccounts.map((a) {
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      fluent.Icon(fluent.FluentIcons.save, size: 16),
                      SizedBox(width: 8),
                      fluent.Text('إضافة الكتالوج'),
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
                const SizedBox(height: Spacings.medium),
                const Divider(height: 0),
                const SizedBox(height: Spacings.large),
              ],
            ),
            Row(
              children: [
                const Expanded(flex: 4, child: ShimmerPlaceholder()),
                const SizedBox(width: Spacings.large),
                const Expanded(flex: 2, child: ShimmerPlaceholder()),
              ],
            ),
            Row(
              children: [
                const Expanded(child: ShimmerPlaceholder()),
                const SizedBox(width: Spacings.large),
                const Expanded(child: ShimmerPlaceholder()),
              ],
            ),
            const Divider(height: 24),
            ShimmerPlaceholder(height: 50),
            Row(
              children: [
                const Expanded(child: ShimmerPlaceholder()),
                const SizedBox(width: Spacings.large),
                const Expanded(child: ShimmerPlaceholder()),
              ],
            ),
            Row(
              children: [
                const Expanded(child: ShimmerPlaceholder()),
                const SizedBox(width: Spacings.large),
                const Expanded(child: ShimmerPlaceholder()),
              ],
            ),
            Column(
              children: [
                const Divider(height: 0),
                const SizedBox(height: Spacings.xsmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const ShimmerPlaceholder(width: 50, height: 35),
                    const SizedBox(width: Spacings.small),
                    const ShimmerPlaceholder(width: 160, height: 35),
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
