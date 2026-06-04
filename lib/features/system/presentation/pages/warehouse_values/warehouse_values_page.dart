import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouse_values/warehouse_values_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/warehouse_values/warehouse_value_form_page.dart';

class WarehouseValuesPage extends StatelessWidget {
  const WarehouseValuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WarehouseValuesBloc, WarehouseValuesState>(
      builder: (context, state) {
        if (state is WarehouseValuesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is WarehouseValuesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.read<WarehouseValuesBloc>().add(
                    LoadWarehouseValuesEvent(),
                  ),
                  child: const Text('إعادة المحاولة'),
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

  Map<int, TableColumnWidth> get columnWidths => {
    0: FixedColumnWidth(isDesktop ? 60.0 : 50.0),
    1: FixedColumnWidth(isDesktop ? 120.0 : 90.0),
    2: FixedColumnWidth(isDesktop ? 140.0 : 110.0),
    3: FixedColumnWidth(isDesktop ? 120.0 : 90.0),
    4: const FlexColumnWidth(0.30),
  };

  Widget _buildHeaderCell(
    String text,
    TextTheme textTheme,
    ColorScheme colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium,
      ),
    );
  }

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
              child: FilledButton.icon(
                onPressed: () => _openWarehouseValueForm(context, null),
                icon: const Icon(Icons.add),
                label: const Text('إضافة قيمة'),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('لا توجد قيم مستودع', style: textTheme.bodyLarge),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _openWarehouseValueForm(context, null),
              icon: const Icon(Icons.add),
              label: const Text('إضافة قيمة'),
            ),
          ),
        ),
        Table(
          border: TableBorder.all(width: 0.50, color: colors.outline),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          children: [
            TableRow(
              decoration: BoxDecoration(color: colors.primaryContainer),
              children: [
                _buildHeaderCell('No.', textTheme, colors),
                _buildHeaderCell('المستودع', textTheme, colors),
                _buildHeaderCell('النوع', textTheme, colors),
                _buildHeaderCell('القيمة', textTheme, colors),
                _buildHeaderCell('حساب فرعي', textTheme, colors),
              ],
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () async {
                  final didUpdate = await _openWarehouseValueForm(
                    context,
                    item,
                  );
                  if (didUpdate == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث قيمة المستودع')),
                    );
                    context.read<WarehouseValuesBloc>().add(
                      LoadWarehouseValuesEvent(),
                    );
                  }
                },
                child: Table(
                  border: TableBorder.all(width: 0.50, color: colors.outline),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: columnWidths,
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: index.isOdd ? colors.primaryContainer : null,
                      ),
                      children: [
                        _buildDataCell((index + 1).toString(), textTheme),
                        _buildDataCell(item.warehouseId.toString(), textTheme),
                        _buildDataCell(item.valueType.displayName(), textTheme),
                        _buildDataCell(_displayValue(item.value), textTheme),
                        _buildDataCell(
                          _displaySubaccount(item.value),
                          textTheme,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة قيمة المستودع')),
        );
      }
    }

    return result != null;
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
