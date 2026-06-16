import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/services/navigation_service.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/usecases/main_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_entry_repository_usecases.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = DashboardViewNotifier();
    _notifier.loadDashboard();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Consumer<DashboardViewNotifier>(
        builder: (context, state, child) {
          return ScaffoldPage(
            header: PageHeader(
              title: Row(
                children: const [
                  Icon(FluentIcons.view_dashboard, size: 24),
                  SizedBox(width: 10),
                  Text('لوحة المعلومات'),
                ],
              ),
              commandBar: Row(
                children: [
                  Button(
                    onPressed: state.isLoading ? null : state.refresh,
                    child: const Text('تحديث'),
                  ),
                ],
              ),
            ),
            content: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(DashboardViewNotifier state) {
    switch (state.status) {
      case DashboardStatus.initial:
      case DashboardStatus.loading:
        return const SizedBox(
          height: 360,
          child: Center(child: ProgressRing()),
        );
      case DashboardStatus.error:
        return SizedBox(
          height: 360,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FluentIcons.error,
                  size: 32,
                  color: const Color(0xFFD13438),
                ),
                const SizedBox(height: 12),
                Text(state.errorMessage ?? 'حدث خطأ أثناء تحميل البيانات'),
                const SizedBox(height: 12),
                Button(
                  onPressed: state.refresh,
                  child: const Text('حاول مجدداً'),
                ),
              ],
            ),
          ),
        );
      case DashboardStatus.loaded:
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: state.summaryCards
                    .map((card) => _buildSummaryCard(card))
                    .toList(),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('الوصول السريع'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: state.quickActions(context)
                    .map((action) => _buildQuickAction(action))
                    .toList(),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('آخر التنبيهات'),
              const SizedBox(height: 12),
              _buildNotifications(state.notifications),
              const SizedBox(height: 20),
              _buildSectionTitle('آخر المعاملات'),
              const SizedBox(height: 12),
              _buildRecentTransactions(state.recentTransactions),
            ],
          ),
        );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSummaryCard(DashboardSummaryCard card) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(card.icon, size: 28, color: card.color),
          const SizedBox(height: 16),
          Text(
            card.title,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            card.value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          if (card.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              card.subtitle!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAction(DashboardQuickAction action) {
    return SizedBox(
      width: 140,
      child: Button(
        onPressed: action.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, size: 20),
            const SizedBox(height: 8),
            Text(action.title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifications(List<DashboardNotification> notifications) {
    if (notifications.isEmpty) {
      return const Text('لا توجد إشعارات جديدة.');
    }

    return Column(
      children: notifications.map((notification) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(notification.icon, size: 20, color: notification.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentTransactions(List<DashboardTransaction> transactions) {
    if (transactions.isEmpty) {
      return const Text('لا توجد معاملات حديثة.');
    }

    return Column(
      children: transactions.map((transaction) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                transaction.amount,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

enum DashboardStatus { initial, loading, loaded, error }

class DashboardViewNotifier extends ChangeNotifier {
  final _getMainAccounts = sl<GetMainAccountsUseCase>();
  final _getSubAccounts = sl<GetSubAccountsUseCase>();
  final _getJournalEntries = sl<GetJournalEntriesUseCase>();

  DashboardStatus status = DashboardStatus.initial;
  String? errorMessage;
  DashboardSummary? summary;
  List<DashboardNotification> notifications = [];
  List<DashboardTransaction> recentTransactions = [];

  bool get isLoading => status == DashboardStatus.loading;

  List<DashboardSummaryCard> get summaryCards {
    if (summary == null) return [];
    return [
      DashboardSummaryCard(
        icon: FluentIcons.money,
        title: 'إجمالي الأصول',
        value: summary!.totalAssets,
        subtitle: 'القيمة الحالية للأصول',
        color: Colors.green,
      ),
      DashboardSummaryCard(
        icon: FluentIcons.decline_call,
        title: 'إجمالي الالتزامات',
        value: summary!.totalLiabilities,
        subtitle: 'المبالغ المستحقة',
        color: const Color(0xFFD13438),
      ),
      DashboardSummaryCard(
        icon: FluentIcons.bank,
        title: 'صافي التدفق',
        value: summary!.netCashFlow,
        subtitle: 'الفارق بين الإيرادات والمصروفات',
        color: const Color(0xFF0178D4),
      ),
      DashboardSummaryCard(
        icon: FluentIcons.chart,
        title: 'إجمالي الإيرادات',
        value: summary!.totalRevenue,
        subtitle: 'المجموع الفعلي للإيرادات',
        color: const Color(0xFFFFC107),
      ),
    ];
  }

  List<DashboardQuickAction> quickActions(BuildContext context) => [
    DashboardQuickAction(
      title: 'الحسابات',
      icon: FluentIcons.people,
      onTap: () => NavigationService.toAccounts(context),
    ),
    DashboardQuickAction(
      title: 'المخزون',
      icon: FluentIcons.shop,
      onTap: () => NavigationService.toInventory(context),
    ),
    DashboardQuickAction(
      title: 'الفئات',
      icon: FluentIcons.check_list,
      onTap: () => NavigationService.toCategories(context),
    ),
    DashboardQuickAction(
      title: 'المعاملات',
      icon: FluentIcons.money,
      onTap: () => NavigationService.toTransactions(context),
    ),
  ];

  Future<void> loadDashboard() async {
    status = DashboardStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final mainResult = await _getMainAccounts();
      final subResult = await _getSubAccounts();
      final entriesResult = await _getJournalEntries();

      final mainAccounts = mainResult.getOrElse((_) => []);
      final subAccounts = subResult.getOrElse((_) => []);
      final allEntries = entriesResult.getOrElse((_) => []);

      final mainAccountsMap = {for (var acc in mainAccounts) acc.id: acc};

      double totalAssets = 0.0;
      double totalLiabilities = 0.0;
      double totalRevenue = 0.0;
      double totalExpenses = 0.0;

      for (final sub in subAccounts) {
        final parent = mainAccountsMap[sub.mainAccountId];
        if (parent != null) {
          final group = parent.mainAccountType.accountType;
          final netBalance = sub.incrementBalance - sub.decrementBalance;
          if (group == MainAccountGroup.assets) {
            totalAssets += netBalance;
          } else if (group == MainAccountGroup.liabilities) {
            totalLiabilities += (sub.decrementBalance - sub.incrementBalance);
          } else if (group == MainAccountGroup.revenues) {
            totalRevenue += (sub.decrementBalance - sub.incrementBalance);
          } else if (group == MainAccountGroup.expenses) {
            totalExpenses += netBalance;
          }
        }
      }

      summary = DashboardSummary(
        totalAssets: totalAssets,
        totalLiabilities: totalLiabilities,
        netCashFlow: totalRevenue - totalExpenses,
        totalRevenue: totalRevenue,
      );

      final listNotifications = <DashboardNotification>[];
      for (final sub in subAccounts) {
        if (sub.balanceMax != null &&
            (sub.incrementBalance - sub.decrementBalance).abs() > sub.balanceMax!) {
          listNotifications.add(
            DashboardNotification(
              title: 'تجاوز الحد الأقصى',
              message: 'الحساب "${sub.accountName}" تجاوز الحد الأقصى المسموح به.',
              icon: FluentIcons.warning,
              color: Colors.orange,
            ),
          );
        }
      }

      if (listNotifications.isEmpty) {
        listNotifications.add(
          DashboardNotification(
            title: 'النظام جاهز',
            message: 'جميع الحسابات والعمليات تعمل بشكل سليم.',
            icon: FluentIcons.completed,
            color: Colors.green,
          ),
        );
      }
      notifications = listNotifications;

      final sortedEntries = List<JournalEntryEntity>.from(allEntries)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recentEntries = sortedEntries.take(5).toList();

      recentTransactions = recentEntries.map((entry) {
        final prefix = entry.baseAmount >= 0 ? '+' : '';
        return DashboardTransaction(
          title: entry.description ?? entry.referenceNumber,
          subtitle: 'قيد يومية - ${DateFormat('yyyy-MM-dd HH:mm').format(entry.createdAt)}',
          amount: '$prefix ${entry.baseAmount.toStringAsFixed(2)} ${entry.currencyId}',
        );
      }).toList();

      status = DashboardStatus.loaded;
    } catch (e) {
      status = DashboardStatus.error;
      errorMessage = 'تعذر تحميل بيانات لوحة المعلومات: $e';
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}

class DashboardSummary {
  final double totalAssets;
  final double totalLiabilities;
  final double netCashFlow;
  final double totalRevenue;

  DashboardSummary({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netCashFlow,
    required this.totalRevenue,
  });
}

class DashboardSummaryCard {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  DashboardSummaryCard({
    required this.icon,
    required this.title,
    required double value,
    this.subtitle,
    required this.color,
  }) : value = _formatValue(value);

  static String _formatValue(double amount) {
    return '${amount.toStringAsFixed(0)} ر.س';
  }
}

class DashboardQuickAction {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  DashboardQuickAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class DashboardNotification {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  DashboardNotification({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}

class DashboardTransaction {
  final String title;
  final String subtitle;
  final String amount;

  DashboardTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
  });
}
