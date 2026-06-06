import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouses/warehouses_cubit.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/system/presentation/pages/warehouses/warehouse_form_page.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WarehousesPage extends StatefulWidget {
  const WarehousesPage({super.key});

  @override
  State<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends State<WarehousesPage> {
  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WarehousesBloc>();
    if (bloc.state is WarehousesInitial) {
      bloc.add(LoadWarehousesEvent());
    }
  }

  Map<int, TableColumnWidth> get columnWidths => {
    0: FixedColumnWidth(isDesktop ? 180.0 : 130.0),
    1: const FlexColumnWidth(0.35),
    2: const FlexColumnWidth(0.30),
    3: const FlexColumnWidth(0.20),
  };

  String getField(dynamic item, Iterable<String> keys) {
    if (item is Map) {
      for (final key in keys) {
        if (item.containsKey(key) && item[key] != null) {
          return item[key].toString();
        }
      }
    }
    try {
      final dynamic value = item;
      for (final key in keys) {
        final result = value.toJson != null ? value.toJson()[key] : null;
        if (result != null) {
          return result.toString();
        }
      }
    } catch (_) {}
    try {
      final dynamic value = item;
      for (final key in keys) {
        final result = value[key];
        if (result != null) {
          return result.toString();
        }
      }
    } catch (_) {}
    try {
      final dynamic value = item;
      if (keys.contains('name') && value.name != null) {
        return value.name.toString();
      }
      if (keys.contains('id') && value.id != null) return value.id.toString();
      if (keys.contains('address') && value.address != null) {
        return value.address.toString();
      }
    } catch (_) {}
    return '';
  }

  Widget headerCell(String text, TextTheme textTheme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: fluent.Text(
        text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget dataCell(String text, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: fluent.Text(
        text.isEmpty ? '-' : text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium,
      ),
    );
  }

  Widget buildBody(BuildContext context, List<WarehouseEntity> items) {
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Center(
        child: fluent.Text('لا يوجد مستودعات', style: textTheme.bodyLarge),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () async {
                final addedWarehouse = await showDialog<WarehouseEntity?>(
                  context: context,
                  builder: (context) => const WarehouseFormPage(),
                );
                if (addedWarehouse != null && context.mounted) {
                  fluent.displayInfoBar(context, builder: (context, close) => fluent.InfoBar(title: const fluent.Text('تنبيه'), content: fluent.Text('تمت إضافة المستودع')));
                  context.read<WarehousesBloc>().add(LoadWarehousesEvent());
                }
              },
              icon: const Icon(fluent.FluentIcons.add),
              label: const fluent.Text('إضافة مستودع'),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Container()
              : buildDataGrid(context, items)
        ),
      ],
    );
  }

  Widget buildDataGrid(BuildContext context, List<WarehouseEntity> items) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final dataSource = WarehousesDataGridSource(
      items: items,
      textTheme: textTheme,
      colors: colors,
    );

    return SfDataGrid(
      source: dataSource,
      headerRowHeight: 40,
      rowHeight: 30,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      columnWidthMode: ColumnWidthMode.fill,
      onCellTap: (DataGridCellTapDetails details) async {
        if (details.rowColumnIndex.rowIndex > 0) {
          final item = dataSource.items[details.rowColumnIndex.rowIndex - 1];
          final updatedWarehouse = await showDialog<WarehouseEntity?>(
            context: context,
            builder: (context) => WarehouseFormPage(initialValue: item),
          );
          if (updatedWarehouse != null && context.mounted) {
            fluent.displayInfoBar(
              context,
              builder: (context, close) => const fluent.InfoBar(
                title: fluent.Text('تنبيه'),
                content: fluent.Text('تم تحديث بيانات المستودع'),
              ),
            );
            context.read<WarehousesBloc>().add(LoadWarehousesEvent());
          }
        }
      },
      columns: [
        GridColumn(
          columnName: 'warehouseName',
          width: isDesktop ? 180.0 : 130.0,
          label: _buildHeaderCell('اسم المستودع', textTheme, colors),
        ),
        GridColumn(
          columnName: 'location',
          label: _buildHeaderCell('العنوان', textTheme, colors),
        ),
        GridColumn(
          columnName: 'warehouseType',
          width: isDesktop ? 140.0 : 120.0,
          label: _buildHeaderCell('نوع المستودع', textTheme, colors),
        ),
        GridColumn(
          columnName: 'parentId',
          label: _buildHeaderCell('المستودع الأب', textTheme, colors),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(
    String text,
    TextTheme textTheme,
    ColorScheme colors,
  ) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: colors.primaryContainer),
      child: fluent.Text(
        text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WarehousesBloc, WarehousesState>(
      builder: (context, state) {
        if (state is WarehousesLoading) {
          return const Center(child: fluent.ProgressRing());
        }
        if (state is WarehousesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                fluent.FilledButton(
                  onPressed: () =>
                      context.read<WarehousesBloc>().add(LoadWarehousesEvent()),
                  child: const fluent.Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is WarehousesSuccess) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<WarehousesBloc>().add(LoadWarehousesEvent());
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: buildBody(context, state.items),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class WarehousesDataGridSource extends DataGridSource {
  WarehousesDataGridSource({
    required List<WarehouseEntity> items,
    required this.textTheme,
    required this.colors,
  })  : _items = items,
        _dataGridRows = items.map<DataGridRow>((item) {
          return DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'warehouseName', value: item.warehouseName),
              DataGridCell<String>(columnName: 'location', value: item.location),
              DataGridCell<String>(columnName: 'warehouseType', value: item.warehouseType.displayName()),
              DataGridCell<String>(columnName: 'parentId', value: item.parentId?.toString() ?? ''),
            ],
          );
        }).toList();

  final TextTheme textTheme;
  final ColorScheme colors;
  final List<WarehouseEntity> _items;
  final List<DataGridRow> _dataGridRows;

  List<WarehouseEntity> get items => _items;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final index = _dataGridRows.indexOf(row);
    return DataGridRowAdapter(
      color: index.isOdd ? colors.primaryContainer.withOpacity(0.12) : null,
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: fluent.Text(
            dataGridCell.value.toString().isEmpty ? '-' : dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        );
      }).toList(),
    );
  }
}
