import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
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
          create: (_) => sl<FinancialTransactionsBloc>()..add(LoadFinancialTransactionsEvent()),
        ),
        BlocProvider<FinancialBondsBloc>(
          create: (_) => sl<FinancialBondsBloc>()..add(LoadFinancialBondsEvent()),
        ),
      ],
      child: Theme(
        data: ThemeData(useMaterial3: true),
        child: Material(
          child: ScaffoldPage(
            header: const PageHeader(
              title: Row(
                children: [
                  Icon(FluentIcons.money, size: 20),
                  SizedBox(width: 10),
                  Text('المعاملات المالية'),
                ],
              ),
            ),
            content: NavigationView(
              pane: NavigationPane(
                selected: _selectedIndex,
                toggleButtonPosition: .titleBar,
                onChanged: (index) => setState(() => _selectedIndex = index),
                displayMode: PaneDisplayMode.top,
                items: [
                  PaneItem(
                    icon: Icon(FluentIcons.document),
                    title: Text('فواتير المبيعات'),
                    body: SalesTab(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.document),
                    title: Text('فواتير المشتريات'),
                    body: PurchasesTab(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.document),
                    title: Text('المرتجعات'),
                    body: SalesTab(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.chart),
                    title: const Text('المصروفات والإيرادات'),
                    body: const ExpensesRevenuesTab(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.money),
                    title: Text('سندات القبض والصرف'),
                    body: BondsTab(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.bank),
                    title: Text('الإيداعات والسحوبات'),
                    body: DepositsWithdrawalsTab(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.report_document),
                    title: Text('التقارير المالية'),
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

