import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/currencies/currencies_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/currencies/currency_form_page.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
class CurrenciesPage extends StatelessWidget {
  const CurrenciesPage({Key? key}) : super(key: key);

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Map<int, TableColumnWidth> get columnWidths => {
        0: FixedColumnWidth(isDesktop ? 90.0 : 70.0),
        1: FixedColumnWidth(isDesktop ? 140.0 : 100.0),
        2: FixedColumnWidth(isDesktop ? 100.0 : 80.0),
        3: FixedColumnWidth(isDesktop ? 140.0 : 100.0),
        4: const FlexColumnWidth(0.30),
      };

  Widget headerCell(String text, TextTheme textTheme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(4),
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
      padding: const EdgeInsets.all(4),
      child: fluent.Text(
        text.isEmpty ? '-' : text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium,
      ),
    );
  }

  Widget buildTable(BuildContext context, List<CurrencyEntity> items) {
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
              child: FilledButton.icon(
                onPressed: () => _openCurrencyForm(context, null),
                icon: const Icon(fluent.FluentIcons.add),
                label: const fluent.Text('إضافة عملة'),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: fluent.Text('لا توجد عملات', style: textTheme.bodyLarge),
            ),
          ),
        ],
      );
    }

    final dataSource = CurrenciesDataGridSource(
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
            child: FilledButton.icon(
              onPressed: () => _openCurrencyForm(context, null),
              icon: const Icon(fluent.FluentIcons.add),
              label: const fluent.Text('إضافة عملة'),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: colors.outline, width: 0.5)),
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
                  final didUpdate = await _openCurrencyForm(context, item);
                  if (didUpdate == true && context.mounted) {
                    fluent.displayInfoBar(context, builder: (context, close) => fluent.InfoBar(title: const fluent.Text('تنبيه'), content: fluent.Text('تم تحديث العملة')));
                    context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
                  }
                }
              },
              columns: [
                GridColumn(
                  columnName: 'id',
                  width: isDesktop ? 90.0 : 70.0,
                  label: headerCell('المعرف', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'name',
                  width: isDesktop ? 140.0 : 100.0,
                  label: headerCell('الاسم', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'symbol',
                  width: isDesktop ? 100.0 : 80.0,
                  label: headerCell('الرمز', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'isDefault',
                  width: isDesktop ? 120.0 : 90.0,
                  label: headerCell('افتراضي', textTheme, colors),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _openCurrencyForm(
    BuildContext context,
    CurrencyEntity? entity,
  ) async {
    final result = await showDialog<CurrencyEntity?>(
      context: context,
      builder: (context) => CurrencyFormPage(initialValue: entity),
    );

    if (result != null && context.mounted) {
      context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
      if (entity == null) {
        fluent.displayInfoBar(context, builder: (context, close) => fluent.InfoBar(title: const fluent.Text('تنبيه'), content: fluent.Text('تمت إضافة العملة')));
      }
    }

    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrenciesBloc, CurrenciesState>(
      builder: (context, state) {
        if (state is CurrenciesLoading) {
          return const Center(child: fluent.ProgressRing());
        }
        if (state is CurrenciesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                fluent.FilledButton(
                  onPressed: () => context.read<CurrenciesBloc>().add(LoadCurrenciesEvent()),
                  child: const fluent.Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is CurrenciesSuccess) {
          final items = state.items.whereType<CurrencyEntity>().toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
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
}

class CurrenciesDataGridSource extends DataGridSource {
  CurrenciesDataGridSource({
    required List<CurrencyEntity> items,
    required this.textTheme,
    required this.colors,
  }) {
    _dataGridRows = items.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'id', value: item.id),
        DataGridCell<String>(columnName: 'name', value: item.name),
        DataGridCell<String>(columnName: 'symbol', value: item.symbol),
        DataGridCell<bool>(columnName: 'isDefault', value: item.isDefault),
      ]);
    }).toList();
  }

  final TextTheme textTheme;
  final ColorScheme colors;
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final index = _dataGridRows.indexOf(row);
    return DataGridRowAdapter(
      color: index.isEven ? null : colors.surfaceVariant.withOpacity(0.12),
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
