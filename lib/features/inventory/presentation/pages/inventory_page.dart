import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Sub Pages
import 'tabs/inventory_catalog/inventory_catalog_page.dart';
import 'tabs/transactions/transactions_page.dart';
import 'tabs/warehouse_transfers/warehouse_transfers_page.dart';
import 'tabs/opening_quantities/opening_quantities_page.dart';
import 'tabs/goods_cost/goods_cost_page.dart';
import 'tabs/stocktaking/stocktaking_page.dart';
import 'tabs/inventory_reports/inventory_reports_page.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class InventoryTabNotifier extends ChangeNotifier {
  final TabController tabController;
  int? selectedInventoryId;

  InventoryTabNotifier(this.tabController);

  void navigateToBatches(int inventoryId) {
    selectedInventoryId = inventoryId;
    notifyListeners();
    tabController.animateTo(1); // Index 1 is Batches
  }

  void clearSelectedInventoryId() {
    selectedInventoryId = null;
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late InventoryTabNotifier _tabNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabNotifier = InventoryTabNotifier(_tabController);
  }

  @override
  void dispose() {
    _tabNotifier.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider.value(
      value: _tabNotifier,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              fluent.Icon(
                fluent.FluentIcons.product,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 10),
              const fluent.Text(
                'إدارة المخازن والمخزون',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            tabs: const [
              Tab(
                icon: fluent.Icon(fluent.FluentIcons.product),
                text: 'قائمة المخزون',
              ),
              Tab(
                icon: fluent.Icon(fluent.FluentIcons.move),
                text: 'حركات المخزون',
              ),
              Tab(
                icon: fluent.Icon(fluent.FluentIcons.shopping_cart),
                text: 'نقل بين المخازن',
              ),
              Tab(
                icon: fluent.Icon(fluent.FluentIcons.page_checked_out),
                text: 'أرصدة افتتاحية',
              ),
              Tab(
                icon: fluent.Icon(fluent.FluentIcons.receipt_check),
                text: 'تكلفة البضاعة',
              ),
              Tab(
                icon: fluent.Icon(fluent.FluentIcons.check_list),
                text: 'جرد المخزون',
              ),
              Tab(
                icon: fluent.Icon(fluent.FluentIcons.assessment_group),
                text: 'تقارير المخزون',
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withAlpha(240),
              ],
            ),
          ),
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: const [
              InventoryCatalogPage(),
              TransactionsPage(),
              WarehouseTransfersPage(),
              OpeningQuantitiesPage(),
              GoodsCostPage(),
              StocktakingPage(),
              InventoryReportsPage(),
            ],
          ),
        ),
      ),
    );
  }
}
