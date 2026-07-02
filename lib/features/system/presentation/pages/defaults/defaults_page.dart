import 'dart:io';

import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/defaults/defaults_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/defaults/default_value_form_page.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class DefaultsPage extends StatelessWidget {
  const DefaultsPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Widget buildTable(BuildContext context, List<ValueEntity> items) {
    final style = AppStyle.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: style.outline, width: 0.5),
      ),
      child: TableWidget<ValueEntity>(
        columns: {
          0: FixedTableWidgetColumnWidth(
            isDesktop ? 70.0 : 55.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
          1: FixedTableWidgetColumnWidth(
            isDesktop ? 220.0 : 140.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
          2: const FlexTableWidgetColumnWidth(
            1.0,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
        },
        header: const ['المعرف', 'الخاصية', 'القيمة'],
        items: items,
        minWidth: isDesktop ? 420.0 : 320.0,
        onTapRow: (valueEntity) => _openEditForm(context, valueEntity),
        paintRowColorWhen: (item, index) => index.isOdd,
        rowColor: style.surfaceContainerLow,
        builder: (context, item, index) => [
          Text(item.id.toString()),
          Text(item.value.toString()),
          Text(item.valueType.name),
        ],
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
                  final result = await fluent.showDialog<ValueEntity?>(
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

  void _openEditForm(BuildContext context, ValueEntity valueEntity) async {
    final didUpdate = await fluent.showDialog<ValueEntity?>(
      context: context,
      builder: (context) => DefaultValueFormPage(initialValue: valueEntity),
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
}
