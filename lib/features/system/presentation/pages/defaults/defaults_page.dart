import 'dart:io';

import 'package:flowcash/core/theme/paddings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/defaults/defaults_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/defaults/default_value_form_page.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DefaultsPage extends StatelessWidget {
  const DefaultsPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Widget buildTable(BuildContext context, List<ValueEntity> items) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final dataSource = DefaultsDataGridSource(
      items: items,
      textTheme: textTheme,
      colors: colors,
    );

    return Column(
      children: [
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
                  final valueEntity =
                      items[details.rowColumnIndex.rowIndex - 1];
                  final didUpdate = await showDialog<ValueEntity?>(
                    context: context,
                    builder: (context) =>
                        DefaultValueFormPage(initialValue: valueEntity),
                  );
                  if (didUpdate != null && context.mounted) {
                    fluent.displayInfoBar(
                      context,
                      builder: (context, close) => fluent.InfoBar(
                        title: const fluent.Text('تنبيه'),
                        content: fluent.Text('تم تحديث القيمة'),
                      ),
                    );
                    context.read<DefaultsBloc>().add(LoadDefaultsEvent());
                  }
                }
              },
              columns: [
                GridColumn(
                  columnName: 'id',
                  width: isDesktop ? 70.0 : 55.0,
                  label: _buildHeaderCell('المعرف', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'value',
                  width: isDesktop ? 220.0 : 140.0,
                  label: _buildHeaderCell('الخاصية', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'type',
                  label: _buildHeaderCell('القيمة', textTheme, colors),
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
      decoration: BoxDecoration(color: colors.surfaceContainerHigh),
      child: fluent.Text(
        text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DefaultsBloc, DefaultsState>(
      builder: (context, state) {
        if (state is DefaultsLoading) {
          return const Center(child: fluent.ProgressRing());
        }
        if (state is DefaultsFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                fluent.FilledButton(
                  onPressed: () =>
                      context.read<DefaultsBloc>().add(LoadDefaultsEvent()),
                  child: const fluent.Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is DefaultsSuccess) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DefaultsBloc>().add(LoadDefaultsEvent());
            },
            child: Padding(
              padding: Paddings.mediumAll,
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

  Widget buildBody(BuildContext context, List<ValueEntity> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              fluent.FilledButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const fluent.Icon(fluent.FluentIcons.add),
                    const SizedBox(width: 8.0),
                    const fluent.Text('إضافة'),
                  ],
                ),
                onPressed: () async {
                  final result = await showDialog<ValueEntity?>(
                    context: context,
                    builder: (context) =>
                        DefaultValueFormPage(initialValue: null),
                  );
                  if (result != null && context.mounted) {
                    fluent.displayInfoBar(
                      context,
                      builder: (context, close) => fluent.InfoBar(
                        title: const fluent.Text('تنبيه'),
                        content: fluent.Text('تمت إضافة القيمة'),
                      ),
                    );
                    context.read<DefaultsBloc>().add(LoadDefaultsEvent());
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? buildEmpty(context)
              : buildTable(context, items),
        ),
      ],
    );
  }

  Widget buildEmpty(BuildContext context) {
    return Center(
      child: fluent.Text(
        'لا توجد قيم افتراضية',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class DefaultsDataGridSource extends DataGridSource {
  DefaultsDataGridSource({
    required List<ValueEntity> items,
    required this.textTheme,
    required this.colors,
  }) {
    _dataGridRows = items.map<DataGridRow>((item) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'id', value: item.id.toString()),
          DataGridCell<String>(
            columnName: 'value',
            value: item.value.toString(),
          ),
          DataGridCell<String>(columnName: 'type', value: item.valueType.name),
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
}
