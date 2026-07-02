import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_history.dart';
import 'package:flowcash/features/inventory/presentation/blocs/inventory_histories/inventory_histories_bloc.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class InventoryHistoriesPage extends StatelessWidget {
  final int? inventoryId;

  const InventoryHistoriesPage({super.key, this.inventoryId});

  @override
  Widget build(BuildContext context) {
    final theme = AppStyle.of(context);

    return BlocProvider<InventoryHistoriesBloc>(
      create: (context) =>
          sl<InventoryHistoriesBloc>()..add(LoadInventoryHistories()),
      child: BlocBuilder<InventoryHistoriesBloc, InventoryHistoriesState>(
        builder: (context, state) {
          if (state is InventoryHistoriesLoading) {
            return const Center(child: fluent.ProgressRing());
          } else if (state is InventoryHistoriesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  fluent.Button(
                    child: const Text('إعادة المحاولة'),
                    onPressed: () => context.read<InventoryHistoriesBloc>().add(
                      LoadInventoryHistories(),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is InventoryHistoriesLoaded) {
            // تصفية السجلات حسب معرّف المخزون إن وُجد
            final histories = inventoryId != null
                ? state.histories
                      .where((h) => h.inventoryId == inventoryId)
                      .toList()
                : state.histories;

            final displayHistories = List<InventoryHistory>.generate(
              histories.length,
              (index) => histories[index].copyWith(),
            );
            final remainingByIndex = List<double>.filled(histories.length, 0.0);
            if (histories.isNotEmpty) {
              final remainingMap = <int, double>{};
              for (var index = histories.length - 1; index >= 0; index--) {
                final history = histories[index];
                final opening = history.openingQuantity;
                final current = remainingMap[history.inventoryId] ?? opening;
                displayHistories[index] = history.copyWith(
                  openingQuantity: current,
                );
                final updated = current +
                    (history.transactionType ==
                            InventoryTransactionType.importInventory
                        ? history.countUnits
                        : -history.countUnits);
                remainingMap[history.inventoryId] = updated;
                remainingByIndex[index] = updated;
              }
            }

            if (histories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      inventoryId != null
                          ? 'لا توجد سجلات حركات لهذا المخزون'
                          : 'لا توجد سجلات حركات مخزون حالياً',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: Paddings.smallAll,
              child: TableWidget<InventoryHistory>(
                columns: const {
                  0: FlexTableWidgetColumnWidth(1.5),
                  1: FlexTableWidgetColumnWidth(2, alignment: Alignment.center),
                  2: FlexTableWidgetColumnWidth(6, alignment: .centerStart),
                  3: FlexTableWidgetColumnWidth(
                    1.5,
                    alignment: .centerStart,
                    padding: EdgeInsetsDirectional.only(start: 8),
                  ),
                  4: FlexTableWidgetColumnWidth(
                    1.5,
                    alignment: .centerStart,
                    padding: EdgeInsetsDirectional.only(start: 8),
                  ),
                  5: FlexTableWidgetColumnWidth(
                    1.5,
                    alignment: Alignment.center,
                  ),
                },
                header: const [
                  'رقم الطلب',
                  'نوع الحركة',
                  'الصنف',
                  'الوارد',
                  'الصادر',
                  
                  'المتبقي',
                ],
                items: displayHistories,
                builder: (context, history, index) {
                  final isReceipt =
                      history.transactionType ==
                      InventoryTransactionType.importInventory;
                  final remaining = remainingByIndex[index];
                  return [
                    Text(
                      '#${history.transactionOrderId}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isReceipt ? theme.success : theme.error)
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: fluent.Text(
                        history.transactionType.displayName(),
                        style: fluent.TextStyle(
                          color: isReceipt ? theme.success : theme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    fluent.Text(
                      history.categoryName,
                      style: const fluent.TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    history.transactionType ==
                            InventoryTransactionType.importInventory
                        ? fluent.Text(
                            '${AppMoneyFormatter.formatDouble(history.countUnits)} ${history.categoryUnit}',
                            style: const fluent.TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : SizedBox(),
                    history.transactionType ==
                            InventoryTransactionType.exportInventory
                        ? fluent.Text(
                            '${AppMoneyFormatter.formatDouble(history.countUnits)} ${history.categoryUnit}',
                            style: const fluent.TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : SizedBox(),
                    fluent.Text(
                      '${AppMoneyFormatter.formatDouble(remaining)} ${history.categoryUnit}',
                      style: fluent.TextStyle(
                        color: remaining < 0 ? theme.errorContainer : theme.successContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ];
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
