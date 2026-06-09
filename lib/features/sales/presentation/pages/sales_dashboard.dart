import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flowcash/features/sales/presentation/pages/customers/customers_page.dart';
import 'package:flowcash/features/sales/presentation/pages/proceeds/proceeds_view.dart';
import 'package:flowcash/features/sales/presentation/pages/sales/sales_page.dart';
import 'package:flowcash/features/sales/presentation/pages/sales_return/sales_returns_page.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return fluent.NavigationView(
      pane: fluent.NavigationPane(
        displayMode: fluent.PaneDisplayMode.top,
        selected: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
        items: [
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.document),
            title: const fluent.Text('المبيعات'),
            body: const SalesPage(),
          ),
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.undo),
            title: const fluent.Text('مرتجعات المبيعات'),
            body: const SalesReturnsPage(),
          ),
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.money),
            title: const fluent.Text('إسناد القبض'),
            body: const ProceedsView(),
          ),
          fluent.PaneItem(
            icon: const fluent.Icon(fluent.FluentIcons.people),
            title: const fluent.Text('العملاء'),
            body: const CustomersPage(),
          ),
        ],
      ),
    );
  }
}
