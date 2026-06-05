import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/financial_periods/financial_periods_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/financial_periods/financial_period_form_page.dart';

import 'package:fluent_ui/fluent_ui.dart' show InfoBar, ProgressRing, displayInfoBar;
class FinancialPeriodsPage extends StatelessWidget {
  const FinancialPeriodsPage({Key? key}) : super(key: key);

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Map<int, TableColumnWidth> get columnWidths => {
        0: FixedColumnWidth(isDesktop ? 70.0 : 55.0),
        1: FixedColumnWidth(isDesktop ? 180.0 : 120.0),
        2: FixedColumnWidth(isDesktop ? 120.0 : 90.0),
        3: FixedColumnWidth(isDesktop ? 120.0 : 90.0),
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

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return date.toIso8601String().split('T').first;
  }

  Widget buildTable(BuildContext context, List<AccountingPeriodEntity> items) {
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
                onPressed: () => _openFinancialPeriodForm(context, null),
                icon: const Icon(Icons.add),
                label: const Text('إضافة فترة مالية'),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('لا توجد فترات مالية', style: textTheme.bodyLarge),
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
              onPressed: () => _openFinancialPeriodForm(context, null),
              icon: const Icon(Icons.add),
              label: const Text('إضافة فترة مالية'),
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
                headerCell('اسم الفترة', textTheme, colors),
                headerCell('من التاريخ', textTheme, colors),
                headerCell('إلى التاريخ', textTheme, colors),
                headerCell('العملة', textTheme, colors),
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
                  final didUpdate = await _openFinancialPeriodForm(context, item);
                  if (didUpdate == true && context.mounted) {
                    displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text('تم تحديث الفترة المالية')));
                    context.read<FinancialPeriodsBloc>().add(LoadFinancialPeriodsEvent());
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
                        dataCell(item.id.toString(), textTheme),
                        dataCell(item.periodName, textTheme),
                        dataCell(formatDate(item.dateOfStartPeriod), textTheme),
                        dataCell(formatDate(item.dateOfEndPeriod), textTheme),
                        dataCell(item.currencyId, textTheme),
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

  Future<bool?> _openFinancialPeriodForm(
    BuildContext context,
    AccountingPeriodEntity? entity,
  ) async {
    final result = await showDialog<AccountingPeriodEntity?>(
      context: context,
      builder: (context) => FinancialPeriodFormPage(initialValue: entity),
    );

    if (result != null && context.mounted) {
      context.read<FinancialPeriodsBloc>().add(LoadFinancialPeriodsEvent());
      if (entity == null) {
        displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text('تمت إضافة الفترة المالية')));
      }
    }

    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialPeriodsBloc, FinancialPeriodsState>(
      builder: (context, state) {
        if (state is FinancialPeriodsLoading) {
          return const Center(child: ProgressRing());
        }
        if (state is FinancialPeriodsFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.read<FinancialPeriodsBloc>().add(LoadFinancialPeriodsEvent()),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is FinancialPeriodsSuccess) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<FinancialPeriodsBloc>().add(LoadFinancialPeriodsEvent());
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
