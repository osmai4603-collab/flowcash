import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_state.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_transactions/financial_transactions_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_transactions/financial_transactions_state.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<BillsBloc, BillsState>(
      builder: (context, billsState) {
        return BlocBuilder<
          FinancialTransactionsBloc,
          FinancialTransactionsState
        >(
          builder: (context, transState) {
            // Calculations
            double totalSales = 0.0;
            double totalPurchases = 0.0;
            double totalExpenses = 0.0;
            double totalRevenues = 0.0;

            for (final bill in billsState.bills) {
              // Assume notes starting with "[مشتريات]" are purchases, others are sales.
              if (bill.note?.contains('[مشتريات]') ?? false) {
                if (bill.note?.contains('مرتجع') ?? false) {
                  totalPurchases -= bill.offerAmount;
                } else {
                  totalPurchases += bill.offerAmount;
                }
              } else {
                if (bill.note?.contains('مرتجع') ?? false) {
                  totalSales -= bill.offerAmount;
                } else {
                  totalSales += bill.offerAmount;
                }
              }
            }

            for (final t in transState.transactions) {
              if (t.historyGroup == HistoriesGroup.expenses) {
                totalExpenses += t.offerAmount;
              } else if (t.historyGroup == HistoriesGroup.revenues) {
                totalRevenues += t.offerAmount;
              }
            }

            final double netCashFlow =
                (totalSales + totalRevenues) - (totalPurchases + totalExpenses);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextWidget(
                    text: '📊 لوحة الملخص المالي العام',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary cards grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 800 ? 4 : 2;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: cols,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildReportCard(
                            context,
                            'إجمالي المبيعات',
                            '$totalSales \$',
                            Icons.shopping_cart,
                            Colors.green,
                          ),
                          _buildReportCard(
                            context,
                            'إجمالي المشتريات',
                            '$totalPurchases \$',
                            Icons.shopping_cart,
                            Colors.blue,
                          ),
                          _buildReportCard(
                            context,
                            'إجمالي المصروفات',
                            '$totalExpenses \$',
                            Icons.arrow_circle_down,
                            Colors.red,
                          ),
                          _buildReportCard(
                            context,
                            'إجمالي الإيرادات',
                            '$totalRevenues \$',
                            Icons.arrow_circle_up,
                            Colors.teal,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Net Income Card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: netCashFlow >= 0
                              ? [Colors.teal.shade800, Colors.teal.shade600]
                              : [Colors.red.shade900, Colors.red.shade700],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const fluent.Text(
                            'صافي التدفق المالي (الربح / الخسارة التقريبية)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          fluent.Text(
                            '$netCashFlow \$',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withAlpha(200),
                  ]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                fluent.Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: color.withAlpha(30),
                  radius: 18,
                  child: fluent.Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            fluent.Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
