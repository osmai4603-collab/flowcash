import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

// Sub Pages
import 'tabs/inventory_catalog/inventory_list_page.dart';
import 'inventory_histories_page.dart';
import 'tabs/transactions/transactions_page.dart';
import 'tabs/warehouse_transfers/warehouse_transfers_page.dart';
import 'tabs/opening_quantities/opening_quantities_page.dart';
import 'tabs/stocktaking/stocktaking_page.dart';
import 'tabs/inventory_reports/inventory_reports_page.dart';

class InventoryTabNotifier extends ChangeNotifier {
  int _selectedIndex = 0;
  int? selectedInventoryId;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    if (_selectedIndex != value) {
      _selectedIndex = value;
      notifyListeners();
    }
  }

  void navigateToHistories(int inventoryId) {
    selectedInventoryId = inventoryId;
    _selectedIndex = 1; // Index 1 is Histories
    notifyListeners();
  }

  void navigateToBatches(int inventoryId) {
    selectedInventoryId = inventoryId;
    _selectedIndex = 2; // Index 2 is Transactions/Batches
    notifyListeners();
  }

  void clearSelectedInventoryId() {
    selectedInventoryId = null;
  }
}

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  late InventoryTabNotifier _tabNotifier;

  @override
  void initState() {
    super.initState();
    _tabNotifier = InventoryTabNotifier();
  }

  @override
  void dispose() {
    _tabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _tabNotifier,
      child: Consumer<InventoryTabNotifier>(
        builder: (context, notifier, child) {
          return ScaffoldPage(
            header: PageHeader(
              title: Row(
                children: const [
                  Icon(FluentIcons.shop, size: 24),
                  SizedBox(width: 10),
                  Text('إدارة المخازن والمخزون'),
                ],
              ),
            ),
            content: NavigationView(
              pane: NavigationPane(
                selected: notifier.selectedIndex,
                onChanged: (index) => notifier.selectedIndex = index,
                displayMode: PaneDisplayMode.top,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.product),
                    title: const Text('قائمة المخزون'),
                    body: const InventoryListPage(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.history),
                    title: const Text('سجلات المخزون'),
                    body: InventoryHistoriesPage(
                      inventoryId: notifier.selectedInventoryId,
                    ),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.sync),
                    title: const Text('حركات المخزون'),
                    body: const TransactionsPage(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.send),
                    title: const Text('نقل بين المخازن'),
                    body: const WarehouseTransfersPage(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.page_add),
                    title: const Text('أرصدة افتتاحية'),
                    body: const OpeningQuantitiesPage(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.task_list),
                    title: const Text('جرد المخزون'),
                    body: const StocktakingPage(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.report_document),
                    title: const Text('تقارير المخزون'),
                    body: const InventoryReportsPage(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
