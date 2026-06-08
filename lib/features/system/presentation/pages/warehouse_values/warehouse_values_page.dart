import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouse_values/warehouse_values_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/warehouse_values/warehouse_value_form_page.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class WarehouseValuesPage extends StatelessWidget {
  const WarehouseValuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WarehouseValuesBloc, WarehouseValuesState>(
      builder: (context, state) {
        if (state is WarehouseValuesLoading) {
          return const Center(child: fluent.ProgressRing());
        }
        if (state is WarehouseValuesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                fluent.FilledButton(
                  onPressed: () => context.read<WarehouseValuesBloc>().add(
                    LoadWarehouseValuesEvent(),
                  ),
                  child: const fluent.Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is WarehouseValuesSuccess) {
          final items = state.items.whereType<WarehouseValueEntity>().toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<WarehouseValuesBloc>().add(
                LoadWarehouseValuesEvent(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: buildTable(context, items),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Widget buildTable(BuildContext context, List<WarehouseValueEntity> items) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: fluent.FilledButton(
child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const fluent.Icon(fluent.FluentIcons.add),
    const SizedBox(width: 8.0),
    const fluent.Text('إضافة قيمة'),
  ],
),
onPressed: () => _openWarehouseValueForm(context, null),
),
            ),
          ),
          Expanded(
            child: Center(
              child: fluent.Text(
                'لا توجد قيم مستودع',
                style: textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      );
    }

    final dataSource = WarehouseValuesDataGridSource(
      items: items,
      textTheme: textTheme,
      colors: colors,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: fluent.FilledButton(
child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const fluent.Icon(fluent.FluentIcons.add),
    const SizedBox(width: 8.0),
    const fluent.Text('إضافة قيمة'),
  ],
),
onPressed: () => _openWarehouseValueForm(context, null),
),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline, width: 0.5),
            ),
            child: SfDataGrid(
              source: dataSource,
              headerRowHeight: 40,
              rowHeight: 30,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              columnWidthMode: ColumnWidthMode.fill,
              onCellTap: (DataGridCellTapDetails details) async {
                if (details.rowColumnIndex.rowIndex > 0) {
                  final item = items[details.rowColumnIndex.rowIndex - 1];
                  final didUpdate = await _openWarehouseValueForm(
                    context,
                    item,
                  );
                  if (didUpdate == true && context.mounted) {
                    fluent.displayInfoBar(
                      context,
                      builder: (context, close) => fluent.InfoBar(
                        title: const fluent.Text('تنبيه'),
                        content: fluent.Text('تم تحديث قيمة المستودع'),
                      ),
                    );
                    context.read<WarehouseValuesBloc>().add(
                      LoadWarehouseValuesEvent(),
                    );
                  }
                }
              },
              columns: [
                GridColumn(
                  columnName: 'no',
                  width: isDesktop ? 60.0 : 50.0,
                  label: _buildHeaderCell('No.', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'warehouse',
                  width: isDesktop ? 120.0 : 90.0,
                  label: _buildHeaderCell('المستودع', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'type',
                  width: isDesktop ? 140.0 : 110.0,
                  label: _buildHeaderCell('النوع', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'value',
                  width: isDesktop ? 120.0 : 90.0,
                  label: _buildHeaderCell('القيمة', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'subaccount',
                  label: _buildHeaderCell('حساب فرعي', textTheme, colors),
                ),
              ],
            ),
          ),
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

  Future<bool?> _openWarehouseValueForm(
    BuildContext context,
    WarehouseValueEntity? entity,
  ) async {
    final result = await showDialog<WarehouseValueEntity?>(
      context: context,
      builder: (context) => WarehouseValueFormPage(initialValue: entity),
    );

    if (result != null && context.mounted) {
      context.read<WarehouseValuesBloc>().add(LoadWarehouseValuesEvent());
      if (entity == null) {
        fluent.displayInfoBar(
          context,
          builder: (context, close) => fluent.InfoBar(
            title: const fluent.Text('تنبيه'),
            content: fluent.Text('تمت إضافة قيمة المستودع'),
          ),
        );
      }
    }

    return result != null;
  }
}

class WarehouseValuesDataGridSource extends DataGridSource {
  WarehouseValuesDataGridSource({
    required List<WarehouseValueEntity> items,
    required this.textTheme,
    required this.colors,
  }) {
    _dataGridRows = items.asMap().entries.map<DataGridRow>((entry) {
      final index = entry.key;
      final item = entry.value;
      return DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'no', value: index + 1),
          DataGridCell<String>(
            columnName: 'warehouse',
            value: item.warehouseId.toString(),
          ),
          DataGridCell<String>(
            columnName: 'type',
            value: item.valueType.displayName(),
          ),
          DataGridCell<String>(
            columnName: 'value',
            value: _displayValue(item.value),
          ),
          DataGridCell<String>(
            columnName: 'subaccount',
            value: _displaySubaccount(item.value),
          ),
        ],
      );
    }).toList();
  }

  final TextTheme textTheme;
  final ColorScheme colors;
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: fluent.Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        );
      }).toList(),
    );
  }

  String _displayValue(Object? value) {
    if (value == null) return 'فارغ';
    return value.toString();
  }

  String _displaySubaccount(Object? value) {
    if (value == null) return 'غير مرتبط';
    final parsed = int.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return parsed.toString();
  }
}
