import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/inventory/presentation/blocs/inventory_catalog/inventory_catalog_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/inventory_catalog/inventory_catalog_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/inventory_catalog/inventory_catalog_state.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/widgets/my_text_widget.dart';

import 'inventory_item_form_dialog.dart';
import 'inventory_subcategory_form_dialog.dart';
import 'inventory_main_category_form_dialog.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class InventoryCatalogPage extends StatefulWidget {
  const InventoryCatalogPage({super.key});

  @override
  State<InventoryCatalogPage> createState() => _InventoryCatalogPageState();
}

class _InventoryCatalogPageState extends State<InventoryCatalogPage> {
  String _searchQuery = "";
  int? _filterWarehouseId;

  List<CategoryEntity> _categories = [];
  List<WarehouseEntity> _warehouses = [];
  List<SubAccountEntity> _subAccounts = [];
  bool _isLoadingMetaData = true;

  @override
  void initState() {
    super.initState();
    _loadMetaData();
  }

  Future<void> _loadMetaData() async {
    try {
      final categoriesRes = await sl<GetAllCategoriesUseCase>().call();
      final warehousesRes = await sl<GetWarehousesUseCase>().call();
      final subAccountsRes = await sl<GetSubAccountsUseCase>().call();

      if (mounted) {
        setState(() {
          categoriesRes.fold((_) => null, (list) => _categories = list);
          warehousesRes.fold((_) => null, (list) => _warehouses = list);
          subAccountsRes.fold((_) => null, (list) => _subAccounts = list);
          _isLoadingMetaData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMetaData = false;
        });
      }
    }
  }

  String _getCategoryName(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id).categoryName;
    } catch (_) {
      return 'صنف (#$id)';
    }
  }

  String _getWarehouseName(int id) {
    try {
      return _warehouses.firstWhere((w) => w.id == id).warehouseName;
    } catch (_) {
      return 'مستودع (#$id)';
    }
  }

  String _getAccountName(int? id) {
    if (id == null) return 'غير معرف';
    try {
      final account = _subAccounts.firstWhere((a) => a.id == id);
      return '${account.accountName} (${account.accountNumber})';
    } catch (_) {
      return 'حساب غير معروف (#$id)';
    }
  }

  Map<int, TableColumnWidth> _getInventoryTableWidths() {
    return {
      0: const FixedColumnWidth(40),
      1: const FlexColumnWidth(0.18), // الصنف
      2: const FlexColumnWidth(0.12), // المستودع
      3: const FixedColumnWidth(55), // الوحدات
      4: const FlexColumnWidth(0.15), // حساب البضاعة
      5: const FlexColumnWidth(0.15), // حساب الإيرادات
      6: const FlexColumnWidth(0.15), // حساب المصروفات
      7: const FlexColumnWidth(0.15), // حساب مخزون الوارد
      8: const FlexColumnWidth(0.15), // حساب مخزون الصادر
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocProvider<InventoryCatalogBloc>(
      create: (context) =>
          sl<InventoryCatalogBloc>()..add(const LoadInventoryCatalogEvent()),
      child: BlocConsumer<InventoryCatalogBloc, InventoryCatalogState>(
        listener: (context, state) {
          if (state.status == CatalogStatus.error &&
              state.errorMessage != null) {
            fluent.displayInfoBar(
              context,
              builder: (context, close) => fluent.InfoBar(
                title: const fluent.Text('تنبيه'),
                content: fluent.Text(state.errorMessage!),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CatalogStatus.loading || _isLoadingMetaData) {
            return const Center(child: fluent.ProgressRing());
          }

          final filteredItems = state.items.where((item) {
            final categoryName = _getCategoryName(
              item.categoryId,
            ).toLowerCase();
            final matchesSearch = categoryName.contains(
              _searchQuery.toLowerCase(),
            );
            final matchesWarehouse =
                _filterWarehouseId == null ||
                item.storeId == _filterWarehouseId;
            return matchesSearch && matchesWarehouse;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: Paddings.smallAll,
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: fluent.TextBox(
                          placeholder: 'البحث عن صنف مخزون...',
                          prefix: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const fluent.Icon(fluent.FluentIcons.search),
                          ),

                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 40,
                          child: MenuBar(
                            children: [
                              SubmenuButton(
                                menuChildren: [
                                  MenuItemButton(
                                    onPressed: () {
                                      setState(() {
                                        _filterWarehouseId = null;
                                      });
                                    },
                                    child: const fluent.Text('كل المخازن'),
                                  ),
                                  ..._warehouses.map(
                                    (warehouse) => MenuItemButton(
                                      onPressed: () {
                                        setState(() {
                                          _filterWarehouseId = warehouse.id;
                                        });
                                      },
                                      child: fluent.Text(
                                        warehouse.warehouseName,
                                      ),
                                    ),
                                  ),
                                ],
                                child: fluent.Text(
                                  _filterWarehouseId == null
                                      ? 'كل المخازن'
                                      : _warehouses
                                            .where(
                                              (w) => w.id == _filterWarehouseId,
                                            )
                                            .isEmpty
                                      ? 'كل المخازن'
                                      : _warehouses
                                            .where(
                                              (w) => w.id == _filterWarehouseId,
                                            )
                                            .first
                                            .warehouseName,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      fluent.FilledButton(
                        onPressed: () async {
                          final result =
                              await showDialog<List<InventoryEntity>>(
                                context: context,
                                builder: (context) =>
                                    const InventorySubcategoryFormDialog(),
                              );
                          if (result != null &&
                              result.isNotEmpty &&
                              context.mounted) {
                            context.read<InventoryCatalogBloc>().add(
                              AddMultipleInventoryItemsEvent(result),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            fluent.Icon(
                              fluent.FluentIcons.add,
                              color: colors.onSecondary,
                            ),
                            const SizedBox(width: 10),
                            fluent.Text(
                              'إضافة كتالوج مخزون',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      fluent.FilledButton(
                        onPressed: () async {
                          final result =
                              await showDialog<List<InventoryEntity>>(
                                context: context,
                                builder: (context) =>
                                    const InventoryMainCategoryFormDialog(),
                              );
                          if (result != null &&
                              result.isNotEmpty &&
                              context.mounted) {
                            context.read<InventoryCatalogBloc>().add(
                              AddMultipleInventoryItemsEvent(result),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            fluent.Icon(
                              fluent.FluentIcons.add,
                              color: colors.onSecondary,
                            ),
                            const SizedBox(width: 10),
                            fluent.Text(
                              'إضافة مخزون رئيسي',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      fluent.FilledButton(
                        onPressed: () async {
                          final result = await showDialog<InventoryEntity>(
                            context: context,
                            builder: (context) =>
                                const InventoryItemFormDialog(),
                          );
                          if (result != null && context.mounted) {
                            context.read<InventoryCatalogBloc>().add(
                              AddInventoryItemEvent(result),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            fluent.Icon(fluent.FluentIcons.add),
                            const SizedBox(width: 10),
                            const fluent.Text(
                              'إضافة مخزون جديد',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: Paddings.smallAll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      fluent.Table(
                        border: fluent.TableBorder.all(
                          width: 0.50,
                          color: colors.outline,
                        ),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        columnWidths: _getInventoryTableWidths(),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: colors.primaryContainer.withAlpha(50),
                            ),
                            children: [
                              TextWidget(
                                text: 'No',
                                textAlign: TextAlign.center,
                                padding: const EdgeInsets.all(8),
                                style: textTheme.bodySmall,
                              ),
                              TextWidget(
                                text: 'الصنف',
                                textAlign: TextAlign.center,
                                padding: const EdgeInsets.all(8),
                                style: textTheme.bodySmall,
                              ),
                              TextWidget(
                                text: 'المستودع الرئيسي',
                                textAlign: TextAlign.center,
                                padding: const EdgeInsets.all(8),
                                style: textTheme.bodySmall,
                              ),
                              TextWidget(
                                text: 'الكمية',
                                textAlign: TextAlign.center,
                                padding: const EdgeInsets.all(8),
                                style: textTheme.bodySmall,
                              ),
                              TextWidget(
                                text: 'حساب البضاعة',
                                textAlign: TextAlign.center,
                                padding: const EdgeInsets.all(8),
                                style: textTheme.bodySmall,
                              ),
                              TextWidget(
                                text: 'حساب الإيرادات',
                                textAlign: TextAlign.center,
                                padding: const EdgeInsets.all(8),
                                style: textTheme.bodySmall,
                              ),
                              TextWidget(
                                text: 'حساب المصروفات',
                                textAlign: TextAlign.center,
                                padding: const EdgeInsets.all(8),
                                style: textTheme.bodySmall,
                              ),
                              TextWidget(
                                text: 'حساب مخزون الوارد',
                                textAlign: TextAlign.center,
                                padding: const EdgeInsets.all(8),
                                style: textTheme.bodySmall,
                              ),
                              TextWidget(
                                text: 'حساب مخزون الصادر',
                                textAlign: TextAlign.center,
                                padding: const EdgeInsets.all(8),
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: filteredItems.isEmpty
                            ? _buildEmptyInventory(textTheme)
                            : _buildTable(filteredItems, colors, textTheme),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Center _buildEmptyInventory(TextTheme textTheme) {
    return Center(
      child: fluent.Text(
        'لا توجد أصناف تطابق معايير البحث ⚠️',
        style: textTheme.bodyLarge?.copyWith(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTable(
    List<InventoryEntity> filteredItems,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Material(
      child: ListView.builder(
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => InventoryItemFormDialog(item: item),
              );
            },
            child: fluent.Table(
              border: fluent.TableBorder.all(
                width: 0.50,
                color: colors.outline,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: _getInventoryTableWidths(),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? colors.primaryContainer.withAlpha(15)
                        : null,
                  ),
                  children: [
                    TextWidget(
                      text: '${index + 1}',
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      style: textTheme.bodySmall,
                    ),
                    TextWidget(
                      text: _getCategoryName(item.categoryId),
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextWidget(
                      text: _getWarehouseName(item.storeId),
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextWidget(
                      text: AppMoneyFormatter.formatDouble(item.countUnits),
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall,
                    ),
                    TextWidget(
                      text: _getAccountName(item.propertyAccountId),
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.rtl,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextWidget(
                      text: _getAccountName(item.revenueAccountId),
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.rtl,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextWidget(
                      text: _getAccountName(item.expenseAccountId),
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.rtl,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextWidget(
                      text: _getAccountName(item.incomeStockId),
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.rtl,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextWidget(
                      text: _getAccountName(item.outcomeStockId),
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.rtl,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
