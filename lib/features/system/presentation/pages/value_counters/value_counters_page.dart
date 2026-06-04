import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/value_counters/value_counters_cubit.dart';
import 'package:flowcash/features/settings/domain/entities/value_counter_entity.dart';

class ValueCountersPage extends StatelessWidget {
  const ValueCountersPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Map<int, TableColumnWidth> get columnWidths => {
        0: FixedColumnWidth(isDesktop ? 70.0 : 55.0),
        1: FixedColumnWidth(isDesktop ? 180.0 : 130.0),
        2: const FlexColumnWidth(0.40),
      };

  String getField(dynamic item, Iterable<String> keys) {
    if (item is Map) {
      for (final key in keys) {
        if (item.containsKey(key) && item[key] != null) {
          return item[key].toString();
        }
      }
    }
    // handle settings ValueCounterEntity
    try {
      if (item is ValueCounterEntity) {
        if (keys.contains('id')) return item.id.toString();
        if (keys.contains('name')) return item.counterType.displayName();
        if (keys.contains('value')) return item.count.toString();
      }
    } catch (_) {}
    try {
      final dynamic value = item;
      if (keys.contains('name') && value.name != null) return value.name.toString();
      if (keys.contains('id') && value.id != null) return value.id.toString();
      if (keys.contains('value') && value.value != null) return value.value.toString();
    } catch (_) {}
    return '';
  }

  Widget headerCell(String text, TextTheme textTheme, ColorScheme colors) {
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

  Widget dataCell(String text, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text.isEmpty ? '-' : text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium,
      ),
    );
  }

  Widget buildTable(BuildContext context, List<dynamic> items) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Text('لا يوجد عدادات قيمة', style: textTheme.bodyLarge),
      );
    }

    return Column(
      children: [
        Table(
          border: TableBorder.all(width: 0.50, color: colors.outline),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          children: [
            TableRow(
              decoration: BoxDecoration(color: colors.primaryContainer),
              children: [
                headerCell('المعرف', textTheme, colors),
                headerCell('اسم العداد', textTheme, colors),
                headerCell('القيمة', textTheme, colors),
              ],
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final id = getField(item, ['id', 'counterId', 'code']);
              final name = getField(item, ['name', 'counterName', 'title']);
              final value = getField(item, ['value', 'currentValue', 'amount']);

              return InkWell(
                onTap: () async {
                  if (item is ValueCounterEntity) {
                    final countController = TextEditingController(text: item.count.toString());
                    final maxController = TextEditingController(text: item.counterMax.toString());
                    final incrementController = TextEditingController(text: item.incrementValue.toString());
                    final formatController = TextEditingController(text: item.formatValue);

                    await showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(item.counterType.displayName()),
                        content: StatefulBuilder(builder: (ctx2, setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('تعديل جميع الحقول ماعدا المعرف ونوع العداد'),
                              const SizedBox(height: 16),
                              TextField(
                                controller: countController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'القيمة'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: maxController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'الحد الأقصى'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: incrementController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'قيمة الزيادة'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: formatController,
                                decoration: const InputDecoration(labelText: 'تنسيق القيمة'),
                              ),
                            ],
                          );
                        }),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
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
                            child: const Text('حفظ'),
                          ),
                        ],
                      ),
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
                      color: index % 2 != 0 ? colors.primaryContainer : null,
                    ),
                    children: [
                      dataCell(id, textTheme),
                      dataCell(name, textTheme),
                      dataCell(value, textTheme),
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValueCountersBloc, ValueCountersState>(
      builder: (context, state) {
        if (state is ValueCountersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ValueCountersFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.read<ValueCountersBloc>().add(LoadValueCountersEvent()),
                  child: const Text('إعادة المحاولة'),
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
