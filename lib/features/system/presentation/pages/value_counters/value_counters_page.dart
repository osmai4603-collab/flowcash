import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/value_counters/value_counters_cubit.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ValueCountersPage extends StatelessWidget {
  const ValueCountersPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Widget buildTable(BuildContext context, List<dynamic> items) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Center(
        child: fluent.Text('لا يوجد عدادات قيمة', style: textTheme.bodyLarge),
      );
    }

    final dataSource = ValueCountersDataGridSource(
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
                  if (item is ValueCounterEntity) {
                    final countController = TextEditingController(
                      text: item.count.toString(),
                    );
                    final maxController = TextEditingController(
                      text: item.counterMax.toString(),
                    );
                    final incrementController = TextEditingController(
                      text: item.incrementValue.toString(),
                    );
                    final formatController = TextEditingController(
                      text: item.formatValue,
                    );

                    await showDialog<void>(
                      context: context,
                      builder: (ctx) => fluent.ContentDialog(
                        title: fluent.Text(item.counterType.displayName()),
                        content: StatefulBuilder(
                          builder: (ctx2, setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                fluent.Text(
                                  'تعديل جميع الحقول ماعدا المعرف ونوع العداد',
                                ),
                                const SizedBox(height: 16),
                                fluent.InfoLabel(
                                  label: 'القيمة',
                                  child: fluent.TextFormBox(
                                    controller: countController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                fluent.InfoLabel(
                                  label: 'الحد الأقصى',
                                  child: fluent.TextFormBox(
                                    controller: maxController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                fluent.InfoLabel(
                                  label: 'قيمة الزيادة',
                                  child: fluent.TextFormBox(
                                    controller: incrementController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                fluent.InfoLabel(
                                  label: 'تنسيق القيمة',
                                  child: fluent.TextFormBox(
                                    controller: formatController,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        actions: [
                          fluent.Button(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: const fluent.Text('إلغاء'),
                          ),
                          fluent.FilledButton(
                            onPressed: () {
                              final newCount = int.tryParse(
                                countController.text,
                              );
                              final newMax = int.tryParse(maxController.text);
                              final newIncrement = int.tryParse(
                                incrementController.text,
                              );
                              final newFormat = formatController.text;

                              if (newCount != null &&
                                  newMax != null &&
                                  newIncrement != null) {
                                final updated = item.copyWith(
                                  count: newCount,
                                  counterMax: newMax,
                                  incrementValue: newIncrement,
                                  formatValue: newFormat,
                                );
                                context.read<ValueCountersBloc>().add(
                                  SetValueCountersEvent(updated),
                                );
                              }
                              Navigator.of(ctx).pop();
                            },
                            child: const fluent.Text('حفظ'),
                          ),
                        ],
                      ),
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
                  width: isDesktop ? 180.0 : 130.0,
                  label: _buildHeaderCell('اسم العداد', textTheme, colors),
                ),
                GridColumn(
                  columnName: 'value',
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
    return BlocBuilder<ValueCountersBloc, ValueCountersState>(
      builder: (context, state) {
        if (state is ValueCountersLoading) {
          return Center(child: fluent.ProgressRing());
        }
        if (state is ValueCountersFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                fluent.FilledButton(
                  onPressed: () => context.read<ValueCountersBloc>().add(
                    LoadValueCountersEvent(),
                  ),
                  child: const fluent.Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is ValueCountersSuccess) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ValueCountersBloc>().add(LoadValueCountersEvent());
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

class ValueCountersDataGridSource extends DataGridSource {
  ValueCountersDataGridSource({
    required List<dynamic> items,
    required this.textTheme,
    required this.colors,
  }) {
    _dataGridRows = items.map<DataGridRow>((item) {
      final id = getField(item, ['id', 'counterId', 'code']);
      final name = getField(item, ['name', 'counterName', 'title']);
      final value = getField(item, ['value', 'currentValue', 'amount']);
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'id', value: id),
          DataGridCell<String>(columnName: 'name', value: name),
          DataGridCell<String>(columnName: 'value', value: value),
        ],
      );
    }).toList();
  }

  final TextTheme textTheme;
  final ColorScheme colors;
  List<DataGridRow> _dataGridRows = [];

  String getField(dynamic item, Iterable<String> keys) {
    if (item is Map) {
      for (final key in keys) {
        if (item.containsKey(key) && item[key] != null) {
          return item[key].toString();
        }
      }
    }
    try {
      if (item is ValueCounterEntity) {
        if (keys.contains('id')) return item.id.toString();
        if (keys.contains('name')) return item.counterType.displayName();
        if (keys.contains('value')) return item.count.toString();
      }
    } catch (_) {}
    try {
      final dynamic value = item;
      if (keys.contains('name') && value.name != null) {
        return value.name.toString();
      }
      if (keys.contains('id') && value.id != null) {
        return value.id.toString();
      }
      if (keys.contains('value') && value.value != null) {
        return value.value.toString();
      }
    } catch (_) {}
    return '';
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
