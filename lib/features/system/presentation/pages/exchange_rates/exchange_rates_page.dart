import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/exchange_rates/exchange_rates_cubit.dart';
import 'package:flowcash/features/system/presentation/pages/exchange_rates/exchange_price_form_page.dart';

class ExchangeRatesPage extends StatelessWidget {
  const ExchangeRatesPage({super.key});

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Map<int, TableColumnWidth> get columnWidths => {
        0: FixedColumnWidth(isDesktop ? 60.0 : 50.0),
        1: FixedColumnWidth(isDesktop ? 120.0 : 90.0),
        2: FixedColumnWidth(isDesktop ? 120.0 : 90.0),
        3: const FlexColumnWidth(0.30),
      };

  Widget buildTable(BuildContext context, List<ExchangePriceEntity> items) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Text('لا يوجد أسعار صرف', style: textTheme.bodyLarge),
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
                headerCell('No.', textTheme, colors),
                headerCell('من العملة', textTheme, colors),
                headerCell('إلى العملة', textTheme, colors),
                headerCell('سعر الصرف', textTheme, colors),
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
                  final didUpdate = await showDialog<bool>(
                    context: context,
                    builder: (context) => ExchangePriceFormPage(initialValue: item),
                  );
                  if (didUpdate == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث سعر الصرف')),
                    );
                    context.read<ExchangeRatesBloc>().add(LoadExchangeRatesEvent());
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
                        dataCell(item.id.toString(), textTheme),
                        dataCell(item.fromCurrencyId, textTheme),
                        dataCell(item.toCurrencyId, textTheme),
                        dataCell(item.price.toStringAsFixed(4), textTheme),
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
        text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangeRatesBloc, ExchangeRatesState>(
      builder: (context, state) {
        if (state is ExchangeRatesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ExchangeRatesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.read<ExchangeRatesBloc>().add(LoadExchangeRatesEvent()),
                  child: const Text('إعادة المحاولة'),
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
}
