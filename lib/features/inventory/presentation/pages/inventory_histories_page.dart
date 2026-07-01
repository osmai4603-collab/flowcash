import 'package:flowcash/core/theme/paddings.dart';
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
    final theme = Theme.of(context);

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
                  2: FlexTableWidgetColumnWidth(3),
                  3: FlexTableWidgetColumnWidth(
                    1.5,
                    alignment: Alignment.center,
                  ),
                  4: FlexTableWidgetColumnWidth(2),
                },
                header: const [
                  'رقم الطلب',
                  'نوع الحركة',
                  'الصنف',
                  'الكمية',
                  'الوحدة',
                ],
                items: histories,
                builder: (context, history, index) {
                  final isReceipt =
                      history.transactionType ==
                      InventoryTransactionType.importInventory;
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
                        color: (isReceipt ? Colors.green : Colors.red)
                            .withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        history.transactionType.displayName(),
                        style: TextStyle(
                          color: isReceipt
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      history.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      history.countUnits.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      history.categoryUnit,
                      style: TextStyle(color: theme.hintColor, fontSize: 13),
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
