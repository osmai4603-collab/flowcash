import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

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
                children: state.quickActions
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
        subtitle: 'هذا الشهر',
        color: const Color(0xFFFFC107),
      ),
    ];
  }

  List<DashboardQuickAction> get quickActions => [
    DashboardQuickAction(
      title: 'الحسابات',
      icon: FluentIcons.people,
      onTap: () {},
    ),
    DashboardQuickAction(
      title: 'المخزون',
      icon: FluentIcons.shop,
      onTap: () {},
    ),
    DashboardQuickAction(
      title: 'الفئات',
      icon: FluentIcons.check_list,
      onTap: () {},
    ),
    DashboardQuickAction(
      title: 'المعاملات',
      icon: FluentIcons.money,
      onTap: () {},
    ),
  ];

  Future<void> loadDashboard() async {
    status = DashboardStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      summary = DashboardSummary(
        totalAssets: 125000.0,
        totalLiabilities: 52000.0,
        netCashFlow: 73000.0,
        totalRevenue: 98000.0,
      );

      notifications = [
        DashboardNotification(
          title: 'فاتورة غير مدفوعة',
          message: 'فاتورة مبيعات رقم 1234 لم تُسدد بعد.',
          icon: FluentIcons.warning,
          color: Colors.orange,
        ),
        DashboardNotification(
          title: 'مخزون منخفض',
          message: 'المخزون من المنتج "حبر طابعة" وصل إلى الحد الأدنى.',
          icon: FluentIcons.warning,
          color: Colors.red,
        ),
      ];

      recentTransactions = [
        DashboardTransaction(
          title: 'سحب نقدي',
          subtitle: 'من حساب الصندوق 01',
          amount: '- 4,200.00',
        ),
        DashboardTransaction(
          title: 'إصدار فاتورة بيع',
          subtitle: 'فاتورة رقم 7589',
          amount: '+ 8,500.00',
        ),
        DashboardTransaction(
          title: 'دفع مورد',
          subtitle: 'رقم سند 112',
          amount: '- 2,200.00',
        ),
      ];

      status = DashboardStatus.loaded;
    } catch (_) {
      status = DashboardStatus.error;
      errorMessage = 'تعذر تحميل بيانات لوحة المعلومات.';
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
