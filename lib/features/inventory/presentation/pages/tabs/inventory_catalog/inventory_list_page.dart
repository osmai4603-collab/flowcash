import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
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
import 'package:flowcash/features/inventory/presentation/pages/inventory_dashboard.dart';
import 'inventory_item_form_dialog.dart';
import 'inventory_subcategory_form_dialog.dart';
import 'inventory_main_category_form_dialog.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class InventoryListPage extends StatefulWidget {
  const InventoryListPage({super.key});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
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

  Map<int, TableWidgetColumnWidth> _getInventoryTableWidths() {
    return {
      0: const FixedTableWidgetColumnWidth(40, alignment: Alignment.center),
      1: const FlexTableWidgetColumnWidth(
        0.20,
        alignment: .centerStart,
      ), // الصنف
      2: const FlexTableWidgetColumnWidth(
        0.12,
        alignment: Alignment.center,
      ), // المستودع
      3: const FixedTableWidgetColumnWidth(
        55,
        alignment: Alignment.center,
      ), // الوحدات
      4: const FlexTableWidgetColumnWidth(
        0.15,
        alignment: AlignmentDirectional.centerEnd,
      ), // حساب البضاعة
      5: const FlexTableWidgetColumnWidth(
        0.15,
        alignment: AlignmentDirectional.centerEnd,
      ), // حساب الإيرادات
      6: const FlexTableWidgetColumnWidth(
        0.15,
        alignment: AlignmentDirectional.centerEnd,
      ), // حساب المصروفات
      7: const FlexTableWidgetColumnWidth(
        0.15,
        alignment: AlignmentDirectional.centerEnd,
      ), // حساب مخزون الوارد
      8: const FlexTableWidgetColumnWidth(
        0.15,
        alignment: AlignmentDirectional.centerEnd,
      ), // حساب مخزون الصادر
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
                              await fluent.showDialog<List<InventoryEntity>>(
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
                              await fluent.showDialog<List<InventoryEntity>>(
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
                          final result = await fluent.showDialog<InventoryEntity>(
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
                  child: filteredItems.isEmpty
                      ? _buildEmptyInventory(textTheme)
                      : TableWidget<InventoryEntity>(
                          columns: _getInventoryTableWidths(),
                          header: const [
                            'No',
                            'الصنف',
                            'المستودع الرئيسي',
                            'الكمية',
                            'حساب البضاعة',
                            'حساب الإيرادات',
                            'حساب المصروفات',
                            'حساب مخزون الوارد',
                            'حساب مخزون الصادر',
                          ],
                          items: filteredItems,
                          rowColor: colors.primaryContainer.withAlpha(15),
                          paintRowColorWhen: (item, index) => index.isEven,
                          onTapRow: (item) {
                            context
                                .read<InventoryTabNotifier>()
                                .navigateToHistories(item.id);
                          },
                          builder: (context, item, index) => [
                            Text('${index + 1}', style: textTheme.bodySmall),
                            Text(
                              _getCategoryName(item.categoryId),
                              style: textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _getWarehouseName(item.storeId),
                              style: textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppMoneyFormatter.formatDouble(item.countUnits),
                              style: textTheme.bodySmall,
                            ),
                            Text(
                              _getAccountName(item.propertyAccountId),
                              style: textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              _getAccountName(item.revenueAccountId),
                              style: textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              _getAccountName(item.expenseAccountId),
                              style: textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              _getAccountName(item.incomeStockId),
                              style: textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              _getAccountName(item.outcomeStockId),
                              style: textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
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
}
