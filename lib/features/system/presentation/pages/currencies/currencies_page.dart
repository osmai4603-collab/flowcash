import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/currencies/currencies_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/currencies/currency_form_page.dart';

import 'package:fluent_ui/fluent_ui.dart' show FluentIcons, InfoBar, ProgressRing, displayInfoBar;
class CurrenciesPage extends StatelessWidget {
  const CurrenciesPage({Key? key}) : super(key: key);

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Map<int, TableColumnWidth> get columnWidths => {
        0: FixedColumnWidth(isDesktop ? 90.0 : 70.0),
        1: FixedColumnWidth(isDesktop ? 140.0 : 100.0),
        2: FixedColumnWidth(isDesktop ? 100.0 : 80.0),
        3: FixedColumnWidth(isDesktop ? 140.0 : 100.0),
        4: const FlexColumnWidth(0.30),
      };

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

  Widget buildTable(BuildContext context, List<CurrencyEntity> items) {
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
                onPressed: () => _openCurrencyForm(context, null),
                icon: const Icon(FluentIcons.add),
                label: const Text('إضافة عملة'),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('لا توجد عملات', style: textTheme.bodyLarge),
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
              onPressed: () => _openCurrencyForm(context, null),
              icon: const Icon(FluentIcons.add),
              label: const Text('إضافة عملة'),
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
                headerCell('المعرف', textTheme, colors),
                headerCell('الاسم', textTheme, colors),
                headerCell('الرمز', textTheme, colors),
                headerCell('الرمز الكامل', textTheme, colors),
                headerCell('البلد', textTheme, colors),
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
                  final didUpdate = await _openCurrencyForm(context, item);
                  if (didUpdate == true && context.mounted) {
                    displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text('تم تحديث العملة')));
                    context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
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
                        dataCell(item.id, textTheme),
                        dataCell(item.name, textTheme),
                        dataCell(item.symbol, textTheme),
                        dataCell(item.fullSymbol, textTheme),
                        dataCell(item.country, textTheme),
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

  Future<bool?> _openCurrencyForm(
    BuildContext context,
    CurrencyEntity? entity,
  ) async {
    final result = await showDialog<CurrencyEntity?>(
      context: context,
      builder: (context) => CurrencyFormPage(initialValue: entity),
    );

    if (result != null && context.mounted) {
      context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
      if (entity == null) {
        displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text('تمت إضافة العملة')));
      }
    }

    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrenciesBloc, CurrenciesState>(
      builder: (context, state) {
        if (state is CurrenciesLoading) {
          return const Center(child: ProgressRing());
        }
        if (state is CurrenciesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.read<CurrenciesBloc>().add(LoadCurrenciesEvent()),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is CurrenciesSuccess) {
          final items = state.items.whereType<CurrencyEntity>().toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
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
