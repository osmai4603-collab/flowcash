import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouses/warehouses_cubit.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/system/presentation/pages/warehouses/warehouse_form_page.dart';

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

  Widget buildBody(BuildContext context, List<WarehouseEntity> items) {
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Center(
        child: Text('لا يوجد مستودعات', style: textTheme.bodyLarge),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () async {
                final addedWarehouse = await showDialog<WarehouseEntity?>(
                  context: context,
                  builder: (context) => const WarehouseFormPage(),
                );
                if (addedWarehouse != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت إضافة المستودع')),
                  );
                  context.read<WarehousesBloc>().add(LoadWarehousesEvent());
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة مستودع'),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Container()
              : buildTable(context, items)
        ),
      ],
    );
  }

  Widget buildTable(BuildContext context, List<WarehouseEntity> items) {
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
                headerCell('اسم المستودع', textTheme, colors),
                headerCell('العنوان', textTheme, colors),
                headerCell('نوع المستودع', textTheme, colors),
                headerCell('المستودع الأب', textTheme, colors),
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
                  final updatedWarehouse = await showDialog<WarehouseEntity?>(
                    context: context,
                    builder: (context) => WarehouseFormPage(initialValue: item),
                  );
                  if (updatedWarehouse != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث بيانات المستودع')),
                    );
                    context.read<WarehousesBloc>().add(LoadWarehousesEvent());
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
                        dataCell(item.warehouseName, textTheme),
                        dataCell(item.location, textTheme),
                        dataCell(item.warehouseType.displayName(), textTheme),
                        dataCell(item.parentId?.toString() ?? '', textTheme),
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
    return BlocBuilder<WarehousesBloc, WarehousesState>(
      builder: (context, state) {
        if (state is WarehousesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is WarehousesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      context.read<WarehousesBloc>().add(LoadWarehousesEvent()),
                  child: const Text('إعادة المحاولة'),
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
