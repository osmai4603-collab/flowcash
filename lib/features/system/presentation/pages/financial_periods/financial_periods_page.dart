import 'dart:io';

import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/financial_periods/financial_periods_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/financial_periods/financial_period_form_page.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class FinancialPeriodsPage extends StatelessWidget {
  const FinancialPeriodsPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Widget buildTable(BuildContext context, List<AccountingPeriodEntity> items) {
    final style = AppStyle.of(context);
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: fluent.FilledButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const fluent.Icon(Icons.add),
                    const SizedBox(width: 8.0),
                    const fluent.Text('إضافة فترة مالية'),
                  ],
                ),
                onPressed: () => _openFinancialPeriodForm(context, null),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: fluent.Text(
                'لا توجد فترات مالية',
                style: textTheme.bodyLarge,
              ),
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
            child: fluent.FilledButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const fluent.Icon(Icons.add),
                  const SizedBox(width: 8.0),
                  const fluent.Text('إضافة فترة مالية'),
                ],
              ),
              onPressed: () => _openFinancialPeriodForm(context, null),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: style.outline, width: 0.5),
            ),
            child: TableWidget<AccountingPeriodEntity>(
              columns: {
                0: FixedTableWidgetColumnWidth(
                  isDesktop ? 70.0 : 55.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
                1: FixedTableWidgetColumnWidth(
                  isDesktop ? 180.0 : 120.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
                2: FixedTableWidgetColumnWidth(
                  isDesktop ? 120.0 : 90.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
                3: FixedTableWidgetColumnWidth(
                  isDesktop ? 120.0 : 90.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
                4: const FlexTableWidgetColumnWidth(
                  1.0,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
              },
              header: const ['المعرف', 'اسم الفترة', 'من التاريخ', 'إلى التاريخ', 'العملة'],
              items: items,
              minWidth: isDesktop ? 650.0 : 500.0,
              onTapRow: (item) => _handleRowTap(context, item),
              paintRowColorWhen: (item, index) => index.isOdd,
              rowColor: style.surfaceContainerLow,
              builder: (context, item, index) => [
                Text(item.id.toString()),
                Text(item.periodName),
                Text(_formatDate(item.dateOfStartPeriod)),
                Text(_formatDate(item.dateOfEndPeriod)),
                Text(item.currencyId),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _openFinancialPeriodForm(
    BuildContext context,
    AccountingPeriodEntity? entity,
  ) async {
    final result = await fluent.showDialog<AccountingPeriodEntity?>(
      context: context,
      builder: (context) => FinancialPeriodFormPage(initialValue: entity),
    );

    if (result != null && context.mounted) {
      context.read<FinancialPeriodsBloc>().add(LoadFinancialPeriodsEvent());
      if (entity == null) {
        fluent.displayInfoBar(
          context,
          builder: (context, close) => fluent.InfoBar(
            title: const fluent.Text('تنبيه'),
            content: fluent.Text('تمت إضافة الفترة المالية'),
          ),
        );
      }
    }

    return result != null;
  }

  void _handleRowTap(BuildContext context, AccountingPeriodEntity item) async {
    final didUpdate = await _openFinancialPeriodForm(context, item);
    if (didUpdate == true && context.mounted) {
      fluent.displayInfoBar(
        context,
        builder: (context, close) => fluent.InfoBar(
          title: const fluent.Text('تنبيه'),
          content: fluent.Text('تم تحديث الفترة المالية'),
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return date.toIso8601String().split('T').first;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialPeriodsBloc, FinancialPeriodsState>(
      builder: (context, state) {
        if (state is FinancialPeriodsLoading) {
          return const Center(child: fluent.ProgressRing());
        }
        if (state is FinancialPeriodsFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                fluent.FilledButton(
                  onPressed: () => context.read<FinancialPeriodsBloc>().add(
                    LoadFinancialPeriodsEvent(),
                  ),
                  child: const fluent.Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is FinancialPeriodsSuccess) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<FinancialPeriodsBloc>().add(
                LoadFinancialPeriodsEvent(),
              );
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
