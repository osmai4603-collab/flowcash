import 'dart:io';

import 'package:flowcash/core/theme/paddings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/defaults/defaults_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/defaults/default_value_form_page.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' show FluentIcons, InfoBar, ProgressRing, displayInfoBar;
class DefaultsPage extends StatelessWidget {
  const DefaultsPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Map<int, TableColumnWidth> get columnWidths => {
    0: FixedColumnWidth(isDesktop ? 70.0 : 55.0),
    1: FixedColumnWidth(isDesktop ? 220.0 : 140.0),
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
    try {
      final dynamic value = item;
      if (keys.contains('name') && value.name != null)
        return value.name.toString();
      if (keys.contains('key') && value.key != null)
        return value.key.toString();
      if (keys.contains('value') && value.value != null)
        return value.value.toString();
    } catch (_) {}
    return item?.toString() ?? '';
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

  Widget buildBody(BuildContext context, List<ValueEntity> items) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (items.isEmpty) {}

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<ValueEntity?>(
                    context: context,
                    builder: (context) =>
                        DefaultValueFormPage(initialValue: null),
                  );
                  if (result != null && context.mounted) {
                    displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text('تمت إضافة القيمة')));
                    context.read<DefaultsBloc>().add(LoadDefaultsEvent());
                  }
                },
                icon: const Icon(FluentIcons.add),
                label: const Text('إضافة'),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty ? buildEmpty(context) : buildTable(context, items),
        ),
      ],
    );
  }

  Widget buildEmpty(BuildContext context) {
    return Center(
      child: Text('لا توجد قيم افتراضية', style: TextTheme.of(context).bodyLarge),
    );
  }

  Widget buildTable(BuildContext context, List<ValueEntity> items) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
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
                headerCell('الخاصية', textTheme, colors),
                headerCell('القيمة', textTheme, colors),
              ],
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final valueEntity = items[index];

              return InkWell(
                onTap: () async {
                  final didUpdate = await showDialog<ValueEntity?>(
                    context: context,
                    builder: (context) =>
                        DefaultValueFormPage(initialValue: valueEntity),
                  );
                  if (didUpdate != null && context.mounted) {
                    displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text('تم تحديث القيمة')));
                    context.read<DefaultsBloc>().add(LoadDefaultsEvent());
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
                        dataCell(valueEntity.id.toString(), textTheme),
                        dataCell(valueEntity.value.toString(), textTheme),
                        dataCell(valueEntity.valueType.name, textTheme),
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
    return BlocBuilder<DefaultsBloc, DefaultsState>(
      builder: (context, state) {
        if (state is DefaultsLoading) {
          return const Center(child: ProgressRing());
        }
        if (state is DefaultsFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      context.read<DefaultsBloc>().add(LoadDefaultsEvent()),
                  child: const Text('إعادة المحاولة'),
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
}
