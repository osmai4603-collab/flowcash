import 'package:flowcash/core/theme/paddings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/presentation/blocs/inventory_histories/inventory_histories_bloc.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class InventoryHistoriesPage extends StatelessWidget {
  const InventoryHistoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<InventoryHistoriesBloc>(
      create: (context) =>
          sl<InventoryHistoriesBloc>()..add(LoadInventoryHistories()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجلات حركات المخزون'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<InventoryHistoriesBloc, InventoryHistoriesState>(
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
                      onPressed: () => context
                          .read<InventoryHistoriesBloc>()
                          .add(LoadInventoryHistories()),
                    ),
                  ],
                ),
              );
            } else if (state is InventoryHistoriesLoaded) {
              final histories = state.histories;
              if (histories.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد سجلات حركات مخزون حالياً',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                padding: Paddings.largeAll,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.5),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(3),
                        3: FlexColumnWidth(1.5),
                        4: FlexColumnWidth(2),
                      },
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: theme.dividerColor.withAlpha(50),
                          width: 1,
                        ),
                      ),
                      children: [
                        // Table Header
                        TableRow(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withAlpha(50),
                          ),
                          children: const [
                            _TableCell(text: 'رقم الطلب', isHeader: true),
                            _TableCell(text: 'نوع الحركة', isHeader: true),
                            _TableCell(text: 'الصنف', isHeader: true),
                            _TableCell(text: 'الكمية', isHeader: true),
                            _TableCell(text: 'الوحدة', isHeader: true),
                          ],
                        ),
                        // Table Data
                        ...histories.map((history) {
                          final isReceipt =
                              history.transactionType ==
                              InventoryTransactionType.importInventory;
                          return TableRow(
                            children: [
                              _TableCell(
                                text: '#${history.transactionOrderId}',
                                textStyle: const TextStyle(
                                  fontFamily: 'monospace',
                                ),
                              ),
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (isReceipt
                                              ? Colors.green
                                              : Colors.red)
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
                                ),
                              ),
                              _TableCell(
                                text: history.categoryName,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              _TableCell(
                                text: history.countUnits.toString(),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _TableCell(
                                text: history.categoryUnit,
                                textStyle: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final TextStyle? textStyle;

  const _TableCell({
    required this.text,
    this.isHeader = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          text,
          style: isHeader
              ? const TextStyle(fontWeight: FontWeight.bold)
              : textStyle,
        ),
      ),
    );
  }
}
