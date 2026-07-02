import 'dart:io';

import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouses/warehouses_cubit.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/system/presentation/pages/warehouses/warehouse_form_page.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class WarehousesPage extends StatefulWidget {
  const WarehousesPage({super.key});

  @override
  State<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends State<WarehousesPage> {
  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WarehousesBloc>();
    if (bloc.state is WarehousesInitial) {
      bloc.add(LoadWarehousesEvent());
    }
  }

  Map<int, TableColumnWidth> get columnWidths => {
    0: FixedColumnWidth(isDesktop ? 180.0 : 130.0),
    1: const FlexColumnWidth(0.35),
    2: const FlexColumnWidth(0.30),
    3: const FlexColumnWidth(0.20),
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
      for (final key in keys) {
        final result = value.toJson != null ? value.toJson()[key] : null;
        if (result != null) {
          return result.toString();
        }
      }
    } catch (_) {}
    try {
      final dynamic value = item;
      for (final key in keys) {
        final result = value[key];
        if (result != null) {
          return result.toString();
        }
      }
    } catch (_) {}
    try {
      final dynamic value = item;
      if (keys.contains('name') && value.name != null) {
        return value.name.toString();
      }
      if (keys.contains('id') && value.id != null) return value.id.toString();
      if (keys.contains('address') && value.address != null) {
        return value.address.toString();
      }
    } catch (_) {}
    return '';
  }

  Widget headerCell(String text, TextTheme textTheme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: fluent.Text(
        text.isEmpty ? '-' : text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium,
      ),
    );
  }

  Widget buildBody(BuildContext context, List<WarehouseEntity> items) {
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Center(
        child: fluent.Text('لا يوجد مستودعات', style: textTheme.bodyLarge),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: fluent.FilledButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const fluent.Icon(fluent.FluentIcons.add),
                  const SizedBox(width: 8.0),
                  const fluent.Text('إضافة مستودع'),
                ],
              ),
              onPressed: () async {
                final addedWarehouse = await fluent.showDialog<WarehouseEntity?>(
                  context: context,
                  builder: (context) => const WarehouseFormPage(),
                );
                if (addedWarehouse != null && context.mounted) {
                  fluent.displayInfoBar(
                    context,
                    builder: (context, close) => fluent.InfoBar(
                      title: const fluent.Text('تنبيه'),
                      content: fluent.Text('تمت إضافة المستودع'),
                    ),
                  );
                  context.read<WarehousesBloc>().add(LoadWarehousesEvent());
                }
              },
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty ? Container() : buildDataGrid(context, items),
        ),
      ],
    );
  }

  Widget buildDataGrid(BuildContext context, List<WarehouseEntity> items) {
    final style = AppStyle.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: style.outline, width: 0.5),
      ),
      child: TableWidget<WarehouseEntity>(
        columns: {
          0: FixedTableWidgetColumnWidth(
            isDesktop ? 180.0 : 130.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
          1: const FlexTableWidgetColumnWidth(
            0.35,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
          2: const FlexTableWidgetColumnWidth(
            0.30,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
          3: const FlexTableWidgetColumnWidth(
            0.20,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
        },
        header: const ['اسم المستودع', 'العنوان', 'نوع المستودع', 'المستودع الأب'],
        items: items,
        minWidth: isDesktop ? 650.0 : 500.0,
        onTapRow: (item) async {
          final updatedWarehouse = await fluent.showDialog<WarehouseEntity?>(
            context: context,
            builder: (context) => WarehouseFormPage(initialValue: item),
          );
          if (updatedWarehouse != null && context.mounted) {
            fluent.displayInfoBar(
              context,
              builder: (context, close) => const fluent.InfoBar(
                title: fluent.Text('تنبيه'),
                content: fluent.Text('تم تحديث بيانات المستودع'),
              ),
            );
            context.read<WarehousesBloc>().add(LoadWarehousesEvent());
          }
        },
        paintRowColorWhen: (item, index) => index.isOdd,
        rowColor: style.surfaceContainerLow,
        builder: (context, item, index) => [
          Text(item.warehouseName),
          Text(item.location),
          Text(item.warehouseType.displayName()),
          Text(item.parentId?.toString() ?? ''),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WarehousesBloc, WarehousesState>(
      builder: (context, state) {
        if (state is WarehousesLoading) {
          return const Center(child: fluent.ProgressRing());
        }
        if (state is WarehousesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      context.read<WarehousesBloc>().add(LoadWarehousesEvent()),
                  child: const fluent.Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is WarehousesSuccess) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<WarehousesBloc>().add(LoadWarehousesEvent());
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
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
