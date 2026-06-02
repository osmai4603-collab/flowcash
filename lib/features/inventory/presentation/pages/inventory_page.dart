import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Sub Pages
import 'tabs/inventory_catalog/inventory_catalog_page.dart';
import 'tabs/batches/batches_page.dart';
import 'tabs/transactions/transactions_page.dart';
import 'tabs/warehouse_transfers/warehouse_transfers_page.dart';
import 'tabs/opening_quantities/opening_quantities_page.dart';
import 'tabs/goods_cost/goods_cost_page.dart';
import 'tabs/stocktaking/stocktaking_page.dart';
import 'tabs/inventory_reports/inventory_reports_page.dart';

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
    _tabController = TabController(length: 8, vsync: this);
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
              Icon(
                Icons.warehouse_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
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
                icon: Icon(Icons.inventory_2_outlined),
                text: 'قائمة المخزون',
              ),
              Tab(
                icon: Icon(Icons.all_inbox_outlined),
                text: 'الدفعات',
              ),
              Tab(
                icon: Icon(Icons.swap_horiz_outlined),
                text: 'حركات المخزون',
              ),
              Tab(
                icon: Icon(Icons.local_shipping_outlined),
                text: 'نقل بين المخازن',
              ),
              Tab(
                icon: Icon(Icons.playlist_add_check_outlined),
                text: 'أرصدة افتتاحية',
              ),
              Tab(
                icon: Icon(Icons.price_check_outlined),
                text: 'تكلفة البضاعة',
              ),
              Tab(
                icon: Icon(Icons.fact_check_outlined),
                text: 'جرد المخزون',
              ),
              Tab(
                icon: Icon(Icons.assessment_outlined),
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
              BatchesPage(),
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
