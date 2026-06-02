import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Sub Pages
import 'chart_of_accounts/chart_of_accounts_page.dart';
import 'journal_entries/journal_entries_page.dart';
import 'account_statement/account_statement_page.dart';
import 'trial_balance/trial_balance_page.dart';
import 'group_balances/group_balances_report_page.dart';
import 'account_types/account_types_management_page.dart';

class AccountsTabNotifier extends ChangeNotifier {
  final TabController tabController;
  int? selectedSubAccountId;

  AccountsTabNotifier(this.tabController);

  void navigateToAccountStatement(int subAccountId) {
    selectedSubAccountId = subAccountId;
    notifyListeners();
    tabController.animateTo(2); // Index 2 is Account Statement
  }

  void clearSelectedSubAccountId() {
    selectedSubAccountId = null;
  }
}

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AccountsTabNotifier _tabNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabNotifier = AccountsTabNotifier(_tabController);
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
                Icons.account_balance_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                'إدارة الحسابات المالية',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          bottom: TabBar(
            
            controller: _tabController,

            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.account_tree_outlined),
                text: 'دليل الحسابات',
              ),
              Tab(icon: Icon(Icons.book_outlined), text: 'قيود اليومية'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'كشف حساب'),
              Tab(
                icon: Icon(Icons.compare_arrows_outlined),
                text: 'ميزان المراجعة',
              ),
              Tab(icon: Icon(Icons.pie_chart_outline), text: 'تقرير الأرصدة'),
              Tab(
                icon: Icon(Icons.settings_applications_outlined),
                text: 'أنواع الحسابات',
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
              ChartOfAccountsPage(),
              JournalEntriesPage(),
              AccountStatementPage(),
              TrialBalancePage(),
              GroupBalancesReportPage(),
              AccountTypesManagementPage(),
            ],
          ),
        ),
      ),
    );
  }
}
