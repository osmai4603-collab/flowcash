import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_state.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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
                                await showDialog<OpeningQuantityEntity>(
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
    final dataSource = OpeningQuantitiesDataGridSource(
      items: items,
      state: state,
      style: style,
      onDelete: _onDeleteOpeningQuantityPressed,
    );

    return SfDataGrid(
      source: dataSource,
      headerRowHeight: 40,
      rowHeight: 45,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      columnWidthMode: ColumnWidthMode.fill,
      columns: [
        GridColumn(
          columnName: 'no',
          width: isDesktop ? 60.0 : 50.0,
          label: _buildHeaderCell('No', style),
        ),
        GridColumn(
          columnName: 'inventoryName',
          label: _buildHeaderCell('اسم صنف المخزون', style),
        ),
        GridColumn(
          columnName: 'warehouse',
          width: isDesktop ? 140.0 : 110.0,
          label: _buildHeaderCell('المستودع الرئيسي', style),
        ),
        GridColumn(
          columnName: 'countUnits',
          width: isDesktop ? 110.0 : 90.0,
          label: _buildHeaderCell('الكمية الافتتاحية', style),
        ),
        GridColumn(
          columnName: 'costTotal',
          width: isDesktop ? 130.0 : 110.0,
          label: _buildHeaderCell('إجمالي التكلفة', style),
        ),
        GridColumn(
          columnName: 'period',
          width: isDesktop ? 120.0 : 100.0,
          label: _buildHeaderCell('الفترة المالية', style),
        ),
        GridColumn(
          columnName: 'actions',
          width: isDesktop ? 100.0 : 90.0,
          label: _buildHeaderCell('الإجراءات', style),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, AppStyle style) {
    return fluent.Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      decoration: fluent.BoxDecoration(color: style.surfaceContainerHighest),
      child: fluent.Text(
        text,
        textAlign: TextAlign.center,
        style: style.bodyStrong,
      ),
    );
  }

  void _onDeleteOpeningQuantityPressed(OpeningQuantityEntity item) async {
    final sure = await showDialog<bool>(
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

class OpeningQuantitiesDataGridSource extends DataGridSource {
  OpeningQuantitiesDataGridSource({
    required List<OpeningQuantityEntity> items,
    required this.state,
    required this.style,
    required this.onDelete,
  }) {
    _dataGridRows = items.asMap().entries.map<DataGridRow>((entry) {
      final index = entry.key;
      final item = entry.value;
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'no', value: '${index + 1}'),
          DataGridCell<String>(
            columnName: 'inventoryName',
            value: _getInventoryName(item.inventoryId, state.inventoryItems),
          ),
          DataGridCell<String>(
            columnName: 'warehouse',
            value: _getWarehouseName(
              item.inventoryId,
              state.inventoryItems,
              state.warehouses,
            ),
          ),
          DataGridCell<String>(
            columnName: 'countUnits',
            value: item.countUnits.toString(),
          ),
          DataGridCell<String>(
            columnName: 'costTotal',
            value: '${item.costTotal.toStringAsFixed(2)} SAR',
          ),
          DataGridCell<String>(
            columnName: 'period',
            value: 'فترة #${item.periodId}',
          ),
          DataGridCell<OpeningQuantityEntity>(
            columnName: 'actions',
            value: item,
          ),
        ],
      );
    }).toList();
  }

  final OpeningQuantitiesState state;
  final AppStyle style;
  final void Function(OpeningQuantityEntity item) onDelete;
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: _dataGridRows.indexOf(row).isEven ? null : style.surfaceContainer,
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'actions') {
          final openingItem = dataGridCell.value as OpeningQuantityEntity;
          return Align(
            alignment: Alignment.center,
            child: fluent.IconButton(
              icon: const fluent.Icon(
                fluent.FluentIcons.delete,
                color: Colors.red,
              ),
              onPressed: () => onDelete(openingItem),
            ),
          );
        }

        final displayValue = _resolveCellValue(dataGridCell);
        return Container(
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.all(8.0),
          child: fluent.Text(
            displayValue,
            overflow: TextOverflow.ellipsis,
            style: style.body,
          ),
        );
      }).toList(),
    );
  }

  String _resolveCellValue(DataGridCell cell) {
    return cell.value?.toString() ?? '';
  }

  String _getInventoryName(int inventoryId, List<InventoryEntity> items) {
    try {
      return items.firstWhere((i) => i.id == inventoryId).inventoryName;
    } catch (_) {
      return 'صنف (#$inventoryId)';
    }
  }

  String _getWarehouseName(
    int inventoryId,
    List<InventoryEntity> items,
    List<WarehouseEntity> warehouses,
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
}
