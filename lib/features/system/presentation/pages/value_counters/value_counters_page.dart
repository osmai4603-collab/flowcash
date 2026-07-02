import 'dart:io';

import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/value_counters/value_counters_cubit.dart';
import 'package:flowcash/features/system/domain/entities/value_counter_entity.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class ValueCountersPage extends StatelessWidget {
  const ValueCountersPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Widget buildTable(BuildContext context, List<dynamic> items) {
    final style = AppStyle.of(context);
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Center(
        child: fluent.Text('لا يوجد عدادات قيمة', style: textTheme.bodyLarge),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: style.outline, width: 0.5),
      ),
      child: TableWidget<dynamic>(
        columns: {
          0: FixedTableWidgetColumnWidth(
            isDesktop ? 70.0 : 55.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
          1: FixedTableWidgetColumnWidth(
            isDesktop ? 180.0 : 130.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
          2: const FlexTableWidgetColumnWidth(
            1.0,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
        },
        header: const ['المعرف', 'اسم العداد', 'القيمة'],
        items: items,
        minWidth: isDesktop ? 420.0 : 320.0,
        onTapRow: (item) => _handleRowTap(context, item),
        paintRowColorWhen: (item, index) => index.isOdd,
        rowColor: style.surfaceContainerLow,
        builder: (context, item, index) => [
          Text(_getField(item, ['id', 'counterId', 'code'])),
          Text(_getField(item, ['name', 'counterName', 'title'])),
          Text(_getField(item, ['value', 'currentValue', 'amount'])),
        ],
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

  void _handleRowTap(BuildContext context, dynamic item) async {
    if (item is! ValueCounterEntity) {
      return;
    }

    final countController = TextEditingController(text: item.count.toString());
    final maxController = TextEditingController(text: item.counterMax.toString());
    final incrementController = TextEditingController(
      text: item.incrementValue.toString(),
    );
    final formatController = TextEditingController(text: item.formatValue);

    await fluent.showDialog<void>(
      context: context,
      builder: (ctx) => fluent.ContentDialog(
        title: fluent.Text(item.counterType.displayName()),
        content: StatefulBuilder(
          builder: (ctx2, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text('تعديل جميع الحقول ماعدا المعرف ونوع العداد'),
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
              final newCount = int.tryParse(countController.text);
              final newMax = int.tryParse(maxController.text);
              final newIncrement = int.tryParse(incrementController.text);
              final newFormat = formatController.text;

              if (newCount != null && newMax != null && newIncrement != null) {
                final updated = item.copyWith(
                  count: newCount,
                  counterMax: newMax,
                  incrementValue: newIncrement,
                  formatValue: newFormat,
                );
                context.read<ValueCountersBloc>().add(SetValueCountersEvent(updated));
              }
              Navigator.of(ctx).pop();
            },
            child: const fluent.Text('حفظ'),
          ),
        ],
      ),
    );
  }

  String _getField(dynamic item, Iterable<String> keys) {
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
}
