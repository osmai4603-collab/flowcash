import 'dart:io';

import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/currencies/currencies_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/currencies/currency_form_page.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class CurrenciesPage extends StatelessWidget {
  const CurrenciesPage({Key? key}) : super(key: key);

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Widget buildTable(BuildContext context, List<CurrencyEntity> items) {
    final style = AppStyle.of(context);

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
                    const fluent.Icon(fluent.FluentIcons.add),
                    const SizedBox(width: 8.0),
                    const fluent.Text('إضافة عملة'),
                  ],
                ),
                onPressed: () => _openCurrencyForm(context, null),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: fluent.Text('لا توجد عملات', style: style.bodyLarge),
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
                  const fluent.Icon(fluent.FluentIcons.add),
                  const SizedBox(width: 8.0),
                  const fluent.Text('إضافة عملة'),
                ],
              ),
              onPressed: () => _openCurrencyForm(context, null),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: style.outline, width: 0.5),
            ),
            child: TableWidget<CurrencyEntity>(
              columns: {
                0: FixedTableWidgetColumnWidth(
                  isDesktop ? 90.0 : 70.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
                1: FixedTableWidgetColumnWidth(
                  isDesktop ? 140.0 : 100.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
                2: FixedTableWidgetColumnWidth(
                  isDesktop ? 100.0 : 80.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
                3: const FlexTableWidgetColumnWidth(
                  1.0,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                ),
              },
              header: const ['المعرف', 'الاسم', 'الرمز', 'افتراضي'],
              items: items,
              minWidth: isDesktop ? 500.0 : 380.0,
              onTapRow: (item) => _openCurrencyForm(context, item),
              paintRowColorWhen: (item, index) => index.isOdd,
              rowColor: style.surfaceContainerLow,
              builder: (context, item, index) => [
                Text(item.id),
                Text(item.name),
                Text(item.symbol),
                Text(item.isDefault ? 'نعم' : 'لا'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _openCurrencyForm(
    BuildContext context,
    CurrencyEntity? entity,
  ) async {
    final result = await fluent.showDialog<CurrencyEntity?>(
      context: context,
      builder: (context) => CurrencyFormPage(initialValue: entity),
    );

    if (result != null && context.mounted) {
      context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
      if (entity == null) {
        fluent.displayInfoBar(
          context,
          builder: (context, close) => fluent.InfoBar(
            title: const fluent.Text('تنبيه'),
            content: fluent.Text('تمت إضافة العملة'),
          ),
        );
      }
    }

    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrenciesBloc, CurrenciesState>(
      builder: (context, state) {
        if (state is CurrenciesLoading) {
          return const Center(child: fluent.ProgressRing());
        }
        if (state is CurrenciesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                fluent.FilledButton(
                  onPressed: () =>
                      context.read<CurrenciesBloc>().add(LoadCurrenciesEvent()),
                  child: const fluent.Text('إعادة المحاولة'),
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
