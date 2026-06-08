import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_event.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_bonds/financial_bonds_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_bonds/financial_bonds_event.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_transactions/financial_transactions_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_transactions/financial_transactions_event.dart';
import 'tabs/bonds_tab.dart';
import 'tabs/deposits_withdrawals_tab.dart';
import 'tabs/expenses_revenues_tab.dart';
import 'tabs/purchases_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/sales_tab.dart';

class TransactionsDashboard extends StatefulWidget {
  const TransactionsDashboard({super.key});

  @override
  State<TransactionsDashboard> createState() => _TransactionsDashboardState();
}

class _TransactionsDashboardState extends State<TransactionsDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BillsBloc>(
          create: (_) => sl<BillsBloc>()..add(LoadBillsEvent()),
        ),
        BlocProvider<FinancialTransactionsBloc>(
          create: (_) =>
              sl<FinancialTransactionsBloc>()
                ..add(LoadFinancialTransactionsEvent()),
        ),
        BlocProvider<FinancialBondsBloc>(
          create: (_) =>
              sl<FinancialBondsBloc>()..add(LoadFinancialBondsEvent()),
        ),
      ],
      child: Theme(
        data: ThemeData(useMaterial3: true),
        child: Material(
          child: fluent.ScaffoldPage(
            header: const fluent.PageHeader(
              title: Row(
                children: [
                  fluent.Icon(fluent.FluentIcons.money, size: 20),
                  SizedBox(width: 10),
                  fluent.Text('المعاملات المالية'),
                ],
              ),
            ),
            content: fluent.NavigationView(
              pane: fluent.NavigationPane(
                selected: _selectedIndex,
                toggleButtonPosition: .titleBar,
                onChanged: (index) => setState(() => _selectedIndex = index),
                displayMode: fluent.PaneDisplayMode.top,
                items: [
                  fluent.PaneItem(
                    icon: fluent.Icon(fluent.FluentIcons.document),
                    title: fluent.Text('فواتير المبيعات'),
                    body: SalesTab(),
                  ),
                  fluent.PaneItem(
                    icon: fluent.Icon(fluent.FluentIcons.document),
                    title: fluent.Text('فواتير المشتريات'),
                    body: PurchasesTab(),
                  ),
                  fluent.PaneItem(
                    icon: fluent.Icon(fluent.FluentIcons.document),
                    title: fluent.Text('المرتجعات'),
                    body: SalesTab(),
                  ),
                  fluent.PaneItem(
                    icon: const fluent.Icon(fluent.FluentIcons.chart),
                    title: const fluent.Text('المصروفات والإيرادات'),
                    body: const ExpensesRevenuesTab(),
                  ),
                  fluent.PaneItem(
                    icon: fluent.Icon(fluent.FluentIcons.money),
                    title: fluent.Text('سندات القبض والصرف'),
                    body: BondsTab(),
                  ),
                  fluent.PaneItem(
                    icon: fluent.Icon(fluent.FluentIcons.bank),
                    title: fluent.Text('الإيداعات والسحوبات'),
                    body: DepositsWithdrawalsTab(),
                  ),
                  fluent.PaneItem(
                    icon: fluent.Icon(fluent.FluentIcons.report_document),
                    title: fluent.Text('التقارير المالية'),
                    body: ReportsTab(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
