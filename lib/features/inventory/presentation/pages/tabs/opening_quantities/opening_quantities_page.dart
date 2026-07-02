import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_state.dart';
import 'opening_quantity_form_dialog.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class OpeningQuantitiesPage extends StatefulWidget {
  const OpeningQuantitiesPage({super.key});

  @override
  State<OpeningQuantitiesPage> createState() => _OpeningQuantitiesPageState();
}

class _OpeningQuantitiesPageState extends State<OpeningQuantitiesPage> {
  String _searchQuery = "";
  int? _filterWarehouseId;

  final bool _isLoadingMetaData = false;

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  String _getInventoryName(int inventoryId, List<InventoryEntity> items) {
    try {
      final item = items.firstWhere((i) => i.id == inventoryId);
      return item.inventoryName;
    } catch (_) {
      return 'صنف (#$inventoryId)';
    }
  }

  int? _getInventoryWarehouseId(int inventoryId, List<InventoryEntity> items) {
    try {
      return items.firstWhere((i) => i.id == inventoryId).storeId;
    } catch (_) {
      return null;
    }
  }

  String _getWarehouseName(
    int inventoryId,
    List<InventoryEntity> items,
    List<dynamic> warehouses,
  ) {
    try {
      final inventory = items.firstWhere((i) => i.id == inventoryId);
      return warehouses
          .firstWhere((w) => w.id == inventory.storeId)
          .warehouseName;
    } catch (_) {
      return 'غير معرف';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<OpeningQuantitiesBloc>(
      create: (context) =>
          sl<OpeningQuantitiesBloc>()..add(const LoadOpeningQuantitiesEvent()),
      child: BlocConsumer<OpeningQuantitiesBloc, OpeningQuantitiesState>(
        listener: (context, state) {
          if (state.status == OpeningQuantitiesStatus.error &&
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
          final bloc = context.read<OpeningQuantitiesBloc>();

          if (state.status == OpeningQuantitiesStatus.loading ||
              _isLoadingMetaData) {
            return const Center(child: fluent.ProgressRing());
          }

          // Apply client filters
          final filteredItems = state.items.where((i) {
            final nameLower = _getInventoryName(
              i.inventoryId,
              state.inventoryItems,
            ).toLowerCase();
            final matchesSearch = nameLower.contains(
              _searchQuery.toLowerCase(),
            );
            final matchesWarehouse =
                _filterWarehouseId == null ||
                _getInventoryWarehouseId(i.inventoryId, state.inventoryItems) ==
                    _filterWarehouseId;
            return matchesSearch && matchesWarehouse;
          }).toList();

          final double grandTotalCost = filteredItems.fold(
            0.0,
            (sum, item) => sum + item.costTotal,
          );

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Filter bar
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'البحث باسم صنف المخزون... 🔍',
                              prefixIcon: const fluent.Icon(
                                fluent.FluentIcons.search,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: MenuBar(
                              children: [
                                SubmenuButton(
                                  menuChildren: [
                                    MenuItemButton(
                                      onPressed: () => setState(
                                        () => _filterWarehouseId = null,
                                      ),
                                      child: const fluent.Text('كل المخازن 🏢'),
                                    ),
                                    ...state.warehouses.map(
                                      (w) => MenuItemButton(
                                        onPressed: () => setState(
                                          () => _filterWarehouseId = w.id,
                                        ),
                                        child: fluent.Text(w.warehouseName),
                                      ),
                                    ),
                                  ],
                                  child: fluent.Text(
                                    _filterWarehouseId == null
                                        ? 'كل المخازن 🏢'
                                        : state.warehouses
                                              .where(
                                                (w) =>
                                                    w.id == _filterWarehouseId,
                                              )
                                              .isEmpty
                                        ? 'كل المخازن 🏢'
                                        : state.warehouses
                                              .where(
                                                (w) =>
                                                    w.id == _filterWarehouseId,
                                              )
                                              .first
                                              .warehouseName,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        fluent.FilledButton(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const fluent.Icon(fluent.FluentIcons.add),
                              const SizedBox(width: 8.0),
                              const fluent.Text(
                                'رصيد جديد',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            if (state.inventoryItems.isEmpty) {
                              fluent.displayInfoBar(
                                context,
                                builder: (context, close) => fluent.InfoBar(
                                  title: const fluent.Text('تنبيه'),
                                  content: fluent.Text(
                                    'الرجاء إنشاء أصناف مخزون أولاً',
                                  ),
                                ),
                              );
                              return;
                            }
                            final result =
                                await fluent.showDialog<OpeningQuantityEntity>(
                                  context: context,
                                  builder: (context) =>
                                      OpeningQuantityFormDialog(
                                        inventoryItems: state.inventoryItems,
                                      ),
                                );
                            if (result != null) {
                              bloc.add(AddOpeningQuantityEvent(result));
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: fluent.Text(
                                'لا توجد أرصدة افتتاحية مسجلة ⚠️',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : listView(filteredItems, state),
                    ),
                    const Divider(height: 24),

                    // Sum Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(80),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const fluent.Text(
                            'إجمالي قيمة الأرصدة الافتتاحية للمخزون:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          fluent.Text(
                            '${grandTotalCost.toStringAsFixed(2)} SAR',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget listView(
    List<OpeningQuantityEntity> items,
    OpeningQuantitiesState state,
  ) {
    final style = AppStyle.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: style.outline, width: 0.5),
      ),
      child: TableWidget<OpeningQuantityEntity>(
        columns: {
          0: FixedTableWidgetColumnWidth(
            isDesktop ? 60.0 : 50.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
          ),
          1: const FlexTableWidgetColumnWidth(
            0.35,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8.0),
          ),
          2: const FlexTableWidgetColumnWidth(
            0.25,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8.0),
          ),
          3: FixedTableWidgetColumnWidth(
            isDesktop ? 110.0 : 90.0,
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
          ),
          4: FixedTableWidgetColumnWidth(
            isDesktop ? 130.0 : 110.0,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(8.0),
          ),
          5: FixedTableWidgetColumnWidth(
            isDesktop ? 120.0 : 100.0,
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
          ),
          6: FixedTableWidgetColumnWidth(
            isDesktop ? 100.0 : 90.0,
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
          ),
        },
        header: const [
          'No',
          'اسم صنف المخزون',
          'المستودع الرئيسي',
          'الكمية الافتتاحية',
          'إجمالي التكلفة',
          'الفترة المالية',
          'الإجراءات',
        ],
        items: items,
        minWidth: isDesktop ? 900.0 : 760.0,
        paintRowColorWhen: (item, index) => index.isOdd,
        rowColor: style.surfaceContainer,
        builder: (context, item, index) => [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: fluent.Text('${index + 1}', textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: fluent.Text(
              _getInventoryName(item.inventoryId, state.inventoryItems),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: fluent.Text(
              _getWarehouseName(
                item.inventoryId,
                state.inventoryItems,
                state.warehouses,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: fluent.Text(
              item.countUnits.toString(),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: fluent.Text(
              '${item.costTotal.toStringAsFixed(2)} SAR',
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: fluent.Text(
              'فترة #${item.periodId}',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: fluent.IconButton(
              icon: const fluent.Icon(
                fluent.FluentIcons.delete,
                color: Colors.red,
              ),
              onPressed: () => _onDeleteOpeningQuantityPressed(item),
            ),
          ),
        ],
      ),
    );
  }

  void _onDeleteOpeningQuantityPressed(OpeningQuantityEntity item) async {
    final sure = await fluent.showDialog<bool>(
      context: context,
      builder: (context) => fluent.ContentDialog(
        title: const fluent.Text('حذف الرصيد الافتتاحي ⚠️'),
        content: const fluent.Text(
          'هل أنت متأكد من رغبتك في حذف هذا الرصيد الافتتاحي؟',
        ),
        actions: [
          fluent.Button(
            onPressed: () => Navigator.pop(context, false),
            child: const fluent.Text('إلغاء'),
          ),
          fluent.FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const fluent.Text('تأكيد الحذف'),
          ),
        ],
      ),
    );

    if (sure == true && context.mounted) {
      context.read<OpeningQuantitiesBloc>().add(
        DeleteOpeningQuantityEvent(item.id),
      );
    }
  }
}
