import 'dart:io';

import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/exchange_rates/exchange_rates_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/exchange_rates/exchange_price_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class ExchangeRatesPage extends StatelessWidget {
  const ExchangeRatesPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Widget buildTable(BuildContext context, List<ExchangePriceEntity> items) {
    final style = AppStyle.of(context);

    if (items.isEmpty) {
      return Center(
        child: fluent.Text('لا يوجد أسعار صرف', style: Theme.of(context).textTheme.bodyLarge),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: style.outline, width: 0.5),
      ),
      child: TableWidget<ExchangePriceEntity>(
        columns: {
          0: FixedTableWidgetColumnWidth(
            isDesktop ? 60.0 : 50.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
          1: FixedTableWidgetColumnWidth(
            isDesktop ? 120.0 : 90.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
          2: FixedTableWidgetColumnWidth(
            isDesktop ? 120.0 : 90.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
          3: const FlexTableWidgetColumnWidth(
            1.0,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          ),
        },
        header: const ['No.', 'من العملة', 'إلى العملة', 'سعر الصرف'],
        items: items,
        minWidth: isDesktop ? 500.0 : 400.0,
        onTapRow: (item) => _openEditForm(context, item),
        paintRowColorWhen: (item, index) => index.isOdd,
        rowColor: style.surfaceContainerLow,
        builder: (context, item, index) => [
          Text(item.id.toString()),
          Text(item.fromCurrencyId),
          Text(item.toCurrencyId),
          Text(AppMoneyFormatter.formatDouble(item.price, replaceLast: '.0000')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangeRatesBloc, ExchangeRatesState>(
      builder: (context, state) {
        if (state is ExchangeRatesLoading) {
          return const Center(child: fluent.ProgressRing());
        }
        if (state is ExchangeRatesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(state.errorMessage),
                const SizedBox(height: 8),
                fluent.FilledButton(
                  onPressed: () => context.read<ExchangeRatesBloc>().add(
                    LoadExchangeRatesEvent(),
                  ),
                  child: const fluent.Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (state is ExchangeRatesSuccess) {
          final items = state.items.whereType<ExchangePriceEntity>().toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExchangeRatesBloc>().add(LoadExchangeRatesEvent());
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

  void _openEditForm(BuildContext context, ExchangePriceEntity item) async {
    final didUpdate = await fluent.showDialog<ExchangePriceEntity>(
      context: context,
      builder: (context) => ExchangePriceFormPage(initialValue: item),
    );
    if (didUpdate != null && context.mounted) {
      fluent.displayInfoBar(
        context,
        builder: (context, close) => fluent.InfoBar(
          title: const fluent.Text('تنبيه'),
          content: fluent.Text('تم تحديث سعر الصرف'),
        ),
      );
      context.read<ExchangeRatesBloc>().add(LoadExchangeRatesEvent());
    }
  }
}
