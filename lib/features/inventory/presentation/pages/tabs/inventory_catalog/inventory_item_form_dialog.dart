import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flutter/material.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:flowcash/core/enums/inventory_cost_type_enum.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/widgets/combo_box_form.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';

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
  InventoryCostType _selectedCostType = InventoryCostType.fifo;
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
        .where((a) => a.subAccountType == SubAccountType.revenues)
        .toList();
  }

  List<SubAccountEntity> get _expenseSubAccounts {
    return _subAccounts
        .where((a) => a.subAccountType == SubAccountType.expenses)
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
      _selectedCostType = item.costType;
      _countUnitsController.text = item.countUnits.toString();
    } else {
      _countUnitsController.text = "1.0";
    }
    _loadFormData();
  }

  Future<void> _loadFormData() async {
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

          if (!_isEdit && _selectedWarehouse == null && _warehouses.length == 1) {
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
    _countUnitsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الصنف والمستودع')),
      );
      return;
    }

    final countUnits = double.tryParse(_countUnitsController.text) ?? 1.0;

    final resultItem = InventoryItemEntity(
      id: _isEdit ? widget.item!.id : 0,
      categoryId: _selectedCategory!.id,
      storeId: _selectedWarehouse!.id,
      costType: _selectedCostType,
      revenueAccountId: _selectedRevenueAccount?.id,
      expenseAccountId: _selectedExpenseAccount?.id,
      incomeStockId: _selectedIncomeStock?.id,
      outcomeStockId: _selectedOutcomeStock?.id,
      countUnits: countUnits,
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
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 24,
      child: Container(
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
        child: _isLoadingData
            ? const AppShimmer(
                child: SizedBox(
                  height: 340,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ShimmerPlaceholder(height: 48),
                        SizedBox(height: 16),
                        ShimmerPlaceholder(height: 48),
                        SizedBox(height: 16),
                        ShimmerPlaceholder(height: 48),
                        SizedBox(height: 16),
                        ShimmerPlaceholder(height: 48),
                        SizedBox(height: 16),
                        ShimmerPlaceholder(height: 48),
                      ],
                    ),
                  ),
                ),
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
                          _isEdit ? Icons.edit_note : Icons.add_box_outlined,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isEdit
                              ? 'تعديل بيانات صنف المخزون'
                              : 'إضافة صنف جديد للمخزون',
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
                                  child: ComboBoxForm<CategoryEntity>(
                                    
                                    controller: _categoryController,
                                    decoration: const InputDecoration(
                                      labelText: 'الصنف الأساسي',
                                      prefixIcon: Icon(Icons.category),
                                    ),
                                    labelMenu: (category) =>
                                        category.categoryName,
                                    labelString: (category) =>
                                        category.categoryName,
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
                                          _selectedCategory!.categoryName !=
                                              value) {
                                        setState(() {
                                          _selectedCategory = null;
                                        });
                                      }
                                    },
                                    validator: (_) =>
                                        _selectedCategory == null
                                            ? 'مطلوب اختيار الصنف'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    autovalidateMode: AutovalidateMode.always,
                                    textDirection: TextDirection.ltr,
                                    controller: _countUnitsController,
                                    decoration: InputDecoration(
                                      labelText: 'عدد الوحدات الافتراضية',
                                      prefixIcon: const Icon(Icons.format_list_numbered),
                                      suffixIcon: Text(
                                        _selectedCategory?.categoryUnit?.unitName ?? 'وحدة',
                                      ),
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
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
                              ],
                            ),

                            // 2. Cost Type & Count Units Row
                            _buildResponsiveFieldRow(
                              second: DropdownButtonFormField<InventoryCostType>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'طريقة تسعير التكلفة',
                                  prefixIcon: Icon(Icons.calculate),
                                ),
                                initialValue: _selectedCostType,
                                items: InventoryCostType.values.map((type) {
                                  String label = "";
                                  switch (type) {
                                    case InventoryCostType.fifo:
                                      label =
                                          "الوارِد أولاً صادِر أولاً (FIFO)";
                                      break;
                                    case InventoryCostType.lifo:
                                      label =
                                          "الوارِد أخيراً صادِر أولاً (LIFO)";
                                      break;
                                    case InventoryCostType.costAVG:
                                      label = "متوسط التكلفة (Average)";
                                      break;
                                    case InventoryCostType.manually:
                                      label = "تحديد يدوي (Manually)";
                                      break;
                                    default:
                                      label =
                                          "الوارِد أولاً صادِر أولاً (FIFO)";
                                      break;
                                  }
                                  return DropdownMenuItem<InventoryCostType>(
                                    value: type,
                                    child: Text(
                                      label,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedCostType = val;
                                    });
                                  }
                                },
                              ),
                              first: DropdownButtonFormField<int>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'المستودع/المخزن',
                                  prefixIcon: Icon(Icons.store),
                                ),
                                initialValue: _selectedWarehouse?.id,
                                items: _warehouses.map((w) {
                                  return DropdownMenuItem<int>(
                                    value: w.id,
                                    child: Text(w.warehouseName),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedWarehouse = val == null
                                        ? null
                                        : _warehouses.firstWhere(
                                            (w) => w.id == val,
                                          );
                                  });
                                },
                                validator: (val) => val == null
                                    ? 'مطلوب اختيار المستودع'
                                    : null,
                              ),
                            ),

                            const Divider(height: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الحسابات المالية المرتبطة بالمخزون',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'اختر الحسابات المالية الدفترية المناسبة لتوجيه حركات المخزون تلقائياً:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            // 3. Accounts Selection Grid
                            _buildResponsiveFieldRow(
                              first: DropdownButtonFormField<int>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'حساب الإيرادات',
                                  
                                  prefixIcon: Icon(Icons.trending_up),
                                ),
                                initialValue: _selectedRevenueAccount?.id,
                                items: _revenueSubAccounts.map((a) {
                                  return DropdownMenuItem<int>(
                                    value: a.id,
                                    child: Text(
                                      '${a.accountName} (${a.accountNumber})',
                                      style: const TextStyle(fontSize: 12),
                                    ),
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
                                        }),
                                disabledHint: const Text('لا يوجد حسابات متاحة'),
                              ),
                              second: DropdownButtonFormField<int>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'حساب المصروفات',
                                  
                                  prefixIcon: Icon(Icons.trending_down),
                                ),
                                initialValue: _selectedExpenseAccount?.id,
                                items: _expenseSubAccounts.map((a) {
                                  return DropdownMenuItem<int>(
                                    value: a.id,
                                    child: Text(
                                      '${a.accountName} (${a.accountNumber})',
                                      style: const TextStyle(fontSize: 12),
                                    ),
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
                                        }),
                                disabledHint: const Text('لا يوجد حسابات متاحة'),
                              ),
                            ),

                            _buildResponsiveFieldRow(
                              first: DropdownButtonFormField<int>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'حساب مخزون الوارد',
                                  
                                  prefixIcon: Icon(Icons.move_to_inbox),
                                ),
                                initialValue: _selectedIncomeStock?.id,
                                items: _inventorySubAccounts.map((a) {
                                  return DropdownMenuItem<int>(
                                    value: a.id,
                                    child: Text(
                                      '${a.accountName} (${a.accountNumber})',
                                      style: const TextStyle(fontSize: 12),
                                    ),
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
                                        }),
                                disabledHint: const Text('لا يوجد حسابات متاحة'),
                              ),
                              second: DropdownButtonFormField<int>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'حساب مخزون الصادر',
                                  
                                  prefixIcon: Icon(Icons.outbox),
                                ),
                                initialValue: _selectedOutcomeStock?.id,
                                items: _inventorySubAccounts.map((a) {
                                  return DropdownMenuItem<int>(
                                    value: a.id,
                                    child: Text(
                                      '${a.accountName} (${a.accountNumber})',
                                      style: const TextStyle(fontSize: 12),
                                    ),
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
                                        }),
                                disabledHint: const Text('لا يوجد حسابات متاحة'),
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
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('إلغاء'),
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
                          icon: const Icon(Icons.save_outlined),
                          label: Text(
                            _isEdit ? 'حفظ التعديلات' : 'إضافة الصنف',
                          ),
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
