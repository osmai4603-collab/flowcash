import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

// Sub Pages
import 'chart_of_accounts/chart_of_accounts_page.dart';
import 'journal_entries/journal_entries_page.dart';
import 'account_statement/account_statement_page.dart';
import 'trial_balance/trial_balance_page.dart';
import 'group_balances/group_balances_report_page.dart';
import 'account_types/account_types_management_page.dart';

class AccountsTabNotifier extends ChangeNotifier {
  int _selectedIndex = 0;
  int? selectedSubAccountId;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    if (_selectedIndex != value) {
      _selectedIndex = value;
      notifyListeners();
    }
  }

  void navigateToAccountStatement(int subAccountId) {
    selectedSubAccountId = subAccountId;
    _selectedIndex = 2; // Index 2 is Account Statement
    notifyListeners();
  }

  void clearSelectedSubAccountId() {
    selectedSubAccountId = null;
  }
}

class AccountsDashboard extends StatefulWidget {
  const AccountsDashboard({super.key});

  @override
  State<AccountsDashboard> createState() => _AccountsDashboardState();
}

class _AccountsDashboardState extends State<AccountsDashboard> {
  late AccountsTabNotifier _tabNotifier;

  @override
  void initState() {
    super.initState();
    _tabNotifier = AccountsTabNotifier();
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
      child: Consumer<AccountsTabNotifier>(
        builder: (context, notifier, child) {
          return ScaffoldPage(
            header: PageHeader(
              title: Row(
                children: const [
                  Icon(FluentIcons.bank, size: 24),
                  SizedBox(width: 10),
                  Text('إدارة الحسابات المالية'),
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
                    icon: const Icon(FluentIcons.column_options),
                    title: const Text('دليل الحسابات'),
                    body: const ChartOfAccountsPage(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.bulleted_list),
                    title: const Text('قيود اليومية'),
                    body: const JournalEntriesPage(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.report_document),
                    title: const Text('كشف حساب'),
                    body: const AccountStatementPage(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.equalizer),
                    title: const Text('ميزان المراجعة'),
                    body: const TrialBalancePage(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.pie_single),
                    title: const Text('تقرير الأرصدة'),
                    body: const GroupBalancesReportPage(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.settings),
                    title: const Text('أنواع الحسابات'),
                    body: const AccountTypesManagementPage(),
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
