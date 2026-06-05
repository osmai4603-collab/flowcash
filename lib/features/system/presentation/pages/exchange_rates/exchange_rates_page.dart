import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/exchange_rates/exchange_rates_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/exchange_rates/exchange_price_form_page.dart';

import 'package:fluent_ui/fluent_ui.dart'
    show InfoBar, ProgressRing, displayInfoBar;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ExchangeRatesPage extends StatelessWidget {
  const ExchangeRatesPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Widget buildTable(BuildContext context, List<ExchangePriceEntity> items) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Text('لا يوجد أسعار صرف', style: textTheme.bodyLarge),
      );
    }

    final dataSource = ExchangeRatesDataGridSource(
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
                  final item = items[details.rowColumnIndex.rowIndex - 1];
                  final didUpdate = await showDialog<bool>(
                    context: context,
                    builder: (context) =>
                        ExchangePriceFormPage(initialValue: item),
                  );
                  if (didUpdate == true && context.mounted) {
                    displayInfoBar(
                      context,
                      builder: (context, close) => InfoBar(
                        title: const Text('تنبيه'),
                        content: Text('تم تحديث سعر الصرف'),
                      ),
                    );
                    context.read<ExchangeRatesBloc>().add(
                      LoadExchangeRatesEvent(),
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
                  columnName: 'from',
                  width: isDesktop ? 120.0 : 90.0,
                  label: _buildHeaderCell('من العملة', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'to',
                  width: isDesktop ? 120.0 : 90.0,
                  label: _buildHeaderCell('إلى العملة', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'price',
                  label: _buildHeaderCell('سعر الصرف', textTheme, colors),
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
      child: Text(
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
    return BlocBuilder<ExchangeRatesBloc, ExchangeRatesState>(
      builder: (context, state) {
        if (state is ExchangeRatesLoading) {
          return const Center(child: ProgressRing());
        }
        if (state is ExchangeRatesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.read<ExchangeRatesBloc>().add(
                    LoadExchangeRatesEvent(),
                  ),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is ExchangeRatesSuccess) {
          final items = state.items.whereType<ExchangePriceEntity>().toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExchangeRatesBloc>().add(LoadExchangeRatesEvent());
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

class ExchangeRatesDataGridSource extends DataGridSource {
  ExchangeRatesDataGridSource({
    required List<ExchangePriceEntity> items,
    required this.textTheme,
    required this.colors,
  }) {
    _dataGridRows = items.map<DataGridRow>((item) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'no', value: item.id.toString()),
          DataGridCell<String>(columnName: 'from', value: item.fromCurrencyId),
          DataGridCell<String>(columnName: 'to', value: item.toCurrencyId),
          DataGridCell<String>(
            columnName: 'price',
            value: item.price.toStringAsFixed(4),
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
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        );
      }).toList(),
    );
  }
}
