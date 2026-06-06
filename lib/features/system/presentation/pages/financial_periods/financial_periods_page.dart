import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/financial_periods/financial_periods_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/financial_periods/financial_period_form_page.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class FinancialPeriodsPage extends StatelessWidget {
  const FinancialPeriodsPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Widget buildTable(BuildContext context, List<AccountingPeriodEntity> items) {
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
                onPressed: () => _openFinancialPeriodForm(context, null),
                icon: const Icon(Icons.add),
                label: const fluent.Text('إضافة فترة مالية'),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: fluent.Text('لا توجد فترات مالية', style: textTheme.bodyLarge),
            ),
          ),
        ],
      );
    }

    final dataSource = FinancialPeriodsDataGridSource(
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
              onPressed: () => _openFinancialPeriodForm(context, null),
              icon: const Icon(Icons.add),
              label: const fluent.Text('إضافة فترة مالية'),
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
                  final didUpdate = await _openFinancialPeriodForm(
                    context,
                    item,
                  );
                  if (didUpdate == true && context.mounted) {
                    fluent.displayInfoBar(
                      context,
                      builder: (context, close) => fluent.InfoBar(
                        title: const fluent.Text('تنبيه'),
                        content: fluent.Text('تم تحديث الفترة المالية'),
                      ),
                    );
                    context.read<FinancialPeriodsBloc>().add(
                      LoadFinancialPeriodsEvent(),
                    );
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
                  columnName: 'name',
                  width: isDesktop ? 180.0 : 120.0,
                  label: _buildHeaderCell('اسم الفترة', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'start',
                  width: isDesktop ? 120.0 : 90.0,
                  label: _buildHeaderCell('من التاريخ', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'end',
                  width: isDesktop ? 120.0 : 90.0,
                  label: _buildHeaderCell('إلى التاريخ', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'currency',
                  label: _buildHeaderCell('العملة', textTheme, colors),
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

  Future<bool?> _openFinancialPeriodForm(
    BuildContext context,
    AccountingPeriodEntity? entity,
  ) async {
    final result = await showDialog<AccountingPeriodEntity?>(
      context: context,
      builder: (context) => FinancialPeriodFormPage(initialValue: entity),
    );

    if (result != null && context.mounted) {
      context.read<FinancialPeriodsBloc>().add(LoadFinancialPeriodsEvent());
      if (entity == null) {
        fluent.displayInfoBar(
          context,
          builder: (context, close) => fluent.InfoBar(
            title: const fluent.Text('تنبيه'),
            content: fluent.Text('تمت إضافة الفترة المالية'),
          ),
        );
      }
    }

    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialPeriodsBloc, FinancialPeriodsState>(
      builder: (context, state) {
        if (state is FinancialPeriodsLoading) {
          return const Center(child: fluent.ProgressRing());
        }
        if (state is FinancialPeriodsFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                fluent.FilledButton(
                  onPressed: () => context.read<FinancialPeriodsBloc>().add(
                    LoadFinancialPeriodsEvent(),
                  ),
                  child: const fluent.Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is FinancialPeriodsSuccess) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<FinancialPeriodsBloc>().add(
                LoadFinancialPeriodsEvent(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: buildTable(context, state.items),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class FinancialPeriodsDataGridSource extends DataGridSource {
  FinancialPeriodsDataGridSource({
    required List<AccountingPeriodEntity> items,
    required this.textTheme,
    required this.colors,
  }) {
    _dataGridRows = items.map<DataGridRow>((item) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'id', value: item.id.toString()),
          DataGridCell<String>(columnName: 'name', value: item.periodName),
          DataGridCell<String>(
            columnName: 'start',
            value: formatDate(item.dateOfStartPeriod),
          ),
          DataGridCell<String>(
            columnName: 'end',
            value: formatDate(item.dateOfEndPeriod),
          ),
          DataGridCell<String>(columnName: 'currency', value: item.currencyId),
        ],
      );
    }).toList();
  }

  final TextTheme textTheme;
  final ColorScheme colors;
  List<DataGridRow> _dataGridRows = [];

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return date.toIso8601String().split('T').first;
  }

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
