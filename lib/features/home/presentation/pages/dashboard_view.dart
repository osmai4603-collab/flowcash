import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/services/navigation_service.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/usecases/main_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/journal_entry_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';
import 'package:flowcash/user_session.dart';

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
          final theme = FluentTheme.of(context);
          return ScaffoldPage(
            header: PageHeader(
              title: Row(
                children: [
                  Icon(
                    FluentIcons.view_dashboard,
                    size: 28,
                    color: theme.accentColor,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'لوحة المعلومات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              commandBar: Row(
                children: [
                  if (state.currencyId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[160]
                            : Colors.grey[30],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[150]
                              : Colors.grey[40],
                        ),
                      ),
                      child: Text(
                        'العملة الرئيسية: ${state.currencyId}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      FluentIcons.refresh,
                      size: 16,
                      color: theme.accentColor,
                    ),
                    onPressed: state.isLoading ? null : state.refresh,
                  ),
                ],
              ),
            ),
            content: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardViewNotifier state) {
    if (state.isLoading) {
      return const Center(child: ProgressRing());
    }

    if (state.status == DashboardStatus.error) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.error, size: 40, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? 'حدث خطأ أثناء تحميل البيانات',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Button(
                  onPressed: state.refresh,
                  child: const Text('حاول مجدداً'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 4 Summary Cards
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: state.summaryCards
                .map((card) => _buildSummaryCard(card, isDark))
                .toList(),
          ),
          const SizedBox(height: 28),

          // Charts Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Financial Analysis Chart
              Expanded(
                flex: 2,
                child: Card(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('التحليل المالي للشهور الحالية'),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 280,
                        child:
                            state.chartPointsRevenues.isEmpty &&
                                state.chartPointsExpenses.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا توجد بيانات كافية للرسم البياني.',
                                ),
                              )
                            : BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: state.maxChartValue * 1.2,
                                  barTouchData: BarTouchData(enabled: true),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                              final month = value.toInt();
                                              return SideTitleWidget(
                                                meta: meta,
                                                space: 8,
                                                child: Text(
                                                  _getMonthName(month),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 60,
                                        getTitlesWidget: (value, meta) {
                                          return SideTitleWidget(
                                            meta: meta,
                                            child: Text(
                                              value.toStringAsFixed(0),
                                              style: const TextStyle(
                                                fontSize: 9,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: const FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: state.chartMonths.map((month) {
                                    final rev =
                                        state.monthlyRevenues[month] ?? 0.0;
                                    final exp =
                                        state.monthlyExpenses[month] ?? 0.0;
                                    return BarChartGroupData(
                                      x: month,
                                      barRods: [
                                        BarChartRodData(
                                          toY: rev,
                                          color: Colors.green,
                                          width: 14,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        BarChartRodData(
                                          toY: exp,
                                          color: Colors.red,
                                          width: 14,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem('الإيرادات', Colors.green),
                          const SizedBox(width: 24),
                          _buildLegendItem('المصروفات', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Account Distribution
              Expanded(
                flex: 1,
                child: Card(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('توزيع الأصول'),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 280,
                        child: state.assetDistribution.isEmpty
                            ? const Center(child: Text('لا توجد أصول لعرضها.'))
                            : PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 50,
                                  sections: state.assetDistribution.entries.map(
                                    (entry) {
                                      final percentage =
                                          entry.value /
                                          state.totalAssetSum *
                                          100;
                                      return PieChartSectionData(
                                        color: _getRandomColorForIndex(
                                          entry.key.hashCode,
                                        ),
                                        value: entry.value,
                                        title:
                                            '${percentage.toStringAsFixed(0)}%',
                                        radius: 60,
                                        titleStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      // Labels
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.assetDistribution.entries.map((entry) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getRandomColorForIndex(
                                    entry.key.hashCode,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${entry.key}: ${entry.value.toStringAsFixed(0)} ${state.currencyId}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Quick Actions
          _buildSectionTitle('الوصول السريع'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: state
                .quickActions(context)
                .map((action) => _buildQuickAction(action, theme))
                .toList(),
          ),
          const SizedBox(height: 28),

          // Alerts & Recent Transactions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notifications / Warnings
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('آخر التنبيهات والأحداث'),
                    const SizedBox(height: 12),
                    _buildNotifications(state.notifications),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Recent Transactions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('آخر المعاملات المالية'),
                    const SizedBox(height: 12),
                    _buildRecentTransactions(state.recentTransactions),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  Color _getRandomColorForIndex(int index) {
    final colors = [
      const Color(0xFF0078D4),
      const Color(0xFF107C41),
      const Color(0xFFD83B01),
      const Color(0xFF8764B8),
      const Color(0xFF00B7C3),
      const Color(0xFFF7630C),
    ];
    return colors[index.abs() % colors.length];
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSummaryCard(DashboardSummaryCard card, bool isDark) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE5E5E5),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: card.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(card.icon, size: 24, color: card.color),
          ),
          const SizedBox(height: 16),
          Text(
            card.title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (card.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              card.subtitle!,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAction(DashboardQuickAction action, FluentThemeData theme) {
    return HoverButton(
      onPressed: action.onTap,
      builder: (context, states) {
        final isHovered = states.contains(WidgetState.hovered);
        return Container(
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isHovered
                ? (theme.brightness == Brightness.dark
                      ? Colors.grey[150]
                      : Colors.grey[30])
                : (theme.brightness == Brightness.dark
                      ? const Color(0xFF2C2C2C)
                      : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered
                  ? theme.accentColor
                  : (theme.brightness == Brightness.dark
                        ? const Color(0xFF3C3C3C)
                        : const Color(0xFFE5E5E5)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 24, color: theme.accentColor),
              const SizedBox(height: 10),
              Text(
                action.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotifications(List<DashboardNotification> notifications) {
    if (notifications.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('لا توجد إشعارات جديدة.')),
        ),
      );
    }

    return Column(
      children: notifications.map((notification) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(notification.icon, size: 22, color: notification.color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: notification.color,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(fontSize: 13),
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
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('لا توجد معاملات حديثة.')),
        ),
      );
    }

    return Column(
      children: transactions.map((transaction) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E5E5).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      transaction.subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                transaction.amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction.amount.startsWith('-')
                      ? Colors.red
                      : Colors.green,
                  fontSize: 15,
                ),
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
  final _getExchangePrices = sl<GetExchangePricesUseCase>();

  DashboardStatus status = DashboardStatus.initial;
  String? errorMessage;
  DashboardSummary? summary;
  String? currencyId;
  List<DashboardNotification> notifications = [];
  List<DashboardTransaction> recentTransactions = [];

  // Chart data
  Map<int, double> monthlyRevenues = {};
  Map<int, double> monthlyExpenses = {};
  List<int> chartMonths = [];
  Map<String, double> assetDistribution = {};
  double totalAssetSum = 0.0;

  bool get isLoading => status == DashboardStatus.loading;

  List<FlSpot> get chartPointsRevenues => monthlyRevenues.entries
      .map((e) => FlSpot(e.key.toDouble(), e.value))
      .toList();

  List<FlSpot> get chartPointsExpenses => monthlyExpenses.entries
      .map((e) => FlSpot(e.key.toDouble(), e.value))
      .toList();

  double get maxChartValue {
    double maxVal = 0.0;
    for (final v in monthlyRevenues.values) {
      if (v > maxVal) maxVal = v;
    }
    for (final v in monthlyExpenses.values) {
      if (v > maxVal) maxVal = v;
    }
    return maxVal == 0.0 ? 1000.0 : maxVal;
  }

  List<DashboardSummaryCard> get summaryCards {
    if (summary == null) return [];
    final curr = currencyId ?? '';
    return [
      DashboardSummaryCard(
        icon: FluentIcons.money,
        title: 'إجمالي الأصول',
        value: summary!.totalAssets,
        subtitle: 'القيمة الحالية للأصول بـ $curr',
        color: Colors.green,
        currencySymbol: curr,
      ),
      DashboardSummaryCard(
        icon: FluentIcons.decline_call,
        title: 'إجمالي الالتزامات',
        value: summary!.totalLiabilities,
        subtitle: 'المبالغ المستحقة بـ $curr',
        color: Colors.red,
        currencySymbol: curr,
      ),
      DashboardSummaryCard(
        icon: FluentIcons.bank,
        title: 'صافي التدفق',
        value: summary!.netCashFlow,
        subtitle: 'الفارق بين الإيرادات والمصروفات بـ $curr',
        color: const Color(0xFF0178D4),
        currencySymbol: curr,
      ),
      DashboardSummaryCard(
        icon: FluentIcons.chart,
        title: 'إجمالي الإيرادات',
        value: summary!.totalRevenue,
        subtitle: 'المجموع الفعلي للإيرادات بـ $curr',
        color: const Color(0xFFFFC107),
        currencySymbol: curr,
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
      final session = sl<UserSession>();
      final periodCurrency = session.currentPeriodCurrencyId;
      currencyId = periodCurrency;

      final mainResult = await _getMainAccounts();
      final subResult = await _getSubAccounts();
      final entriesResult = await _getJournalEntries();
      final exchangePricesResult = await _getExchangePrices();

      final mainAccounts = mainResult.getOrElse((_) => []);
      final subAccounts = subResult.getOrElse((_) => []);
      final allEntries = entriesResult.getOrElse((_) => []);
      final exchangePrices = exchangePricesResult.getOrElse((_) => []);

      final mainAccountsMap = {for (var acc in mainAccounts) acc.id: acc};
      final subAccountsMap = {for (var sub in subAccounts) sub.id: sub};

      // Map rates
      final ratesMap = <String, double>{};
      for (final rate in exchangePrices) {
        ratesMap['${rate.fromCurrencyId}_${rate.toCurrencyId}'] = rate.price;
      }

      double convert(double amount, String fromCurrency, String toCurrency) {
        if (fromCurrency == toCurrency) return amount;
        final key = '${fromCurrency}_$toCurrency';
        if (ratesMap.containsKey(key)) {
          return amount * ratesMap[key]!;
        }
        final reverseKey = '${toCurrency}_$fromCurrency';
        if (ratesMap.containsKey(reverseKey)) {
          final rate = ratesMap[reverseKey]!;
          if (rate != 0) {
            return amount / rate;
          }
        }
        return amount; // fallback
      }

      double totalAssets = 0.0;
      double totalLiabilities = 0.0;
      double totalRevenue = 0.0;
      double totalExpenses = 0.0;
      assetDistribution.clear();

      for (final sub in subAccounts) {
        final parent = mainAccountsMap[sub.mainAccountId];
        if (parent != null) {
          final group = parent.mainAccountType.accountType;
          final netBalance = sub.incrementBalance - sub.decrementBalance;
          final convertedNet = convert(
            netBalance,
            sub.currencyId,
            periodCurrency,
          );

          if (group == MainAccountGroup.assets) {
            totalAssets += convertedNet;
            assetDistribution[sub.accountName] =
                (assetDistribution[sub.accountName] ?? 0.0) +
                convertedNet.abs();
          } else if (group == MainAccountGroup.liabilities) {
            final convertedLiab = convert(
              sub.decrementBalance - sub.incrementBalance,
              sub.currencyId,
              periodCurrency,
            );
            totalLiabilities += convertedLiab;
          } else if (group == MainAccountGroup.revenues) {
            final convertedRev = convert(
              sub.decrementBalance - sub.incrementBalance,
              sub.currencyId,
              periodCurrency,
            );
            totalRevenue += convertedRev;
          } else if (group == MainAccountGroup.expenses) {
            totalExpenses += convertedNet;
          }
        }
      }

      totalAssetSum = assetDistribution.values.fold(
        0.0,
        (sum, val) => sum + val,
      );

      summary = DashboardSummary(
        totalAssets: totalAssets,
        totalLiabilities: totalLiabilities,
        netCashFlow: totalRevenue - totalExpenses,
        totalRevenue: totalRevenue,
      );

      // Group monthly analytics (Revenues and Expenses)
      monthlyRevenues.clear();
      monthlyExpenses.clear();
      final now = DateTime.now();
      final recentMonths = List.generate(6, (i) {
        final date = DateTime(now.year, now.month - i, 1);
        return date.month;
      }).reversed.toList();
      chartMonths = recentMonths;

      for (final month in chartMonths) {
        monthlyRevenues[month] = 0.0;
        monthlyExpenses[month] = 0.0;
      }

      for (final entry in allEntries) {
        final entryMonth = entry.createdAt.month;
        if (chartMonths.contains(entryMonth)) {
          for (final item in entry.items) {
            final subAcc = subAccountsMap[item.accountId];
            if (subAcc != null) {
              final parent = mainAccountsMap[subAcc.mainAccountId];
              if (parent != null) {
                final group = parent.mainAccountType.accountType;
                final amountInPeriodCurrency = convert(
                  item.amount,
                  item.currencyId,
                  periodCurrency,
                );
                if (group == MainAccountGroup.revenues) {
                  monthlyRevenues[entryMonth] =
                      (monthlyRevenues[entryMonth] ?? 0.0) +
                      amountInPeriodCurrency;
                } else if (group == MainAccountGroup.expenses) {
                  monthlyExpenses[entryMonth] =
                      (monthlyExpenses[entryMonth] ?? 0.0) +
                      amountInPeriodCurrency;
                }
              }
            }
          }
        }
      }

      final listNotifications = <DashboardNotification>[];
      for (final sub in subAccounts) {
        if (sub.balanceMax != null) {
          final balance = (sub.incrementBalance - sub.decrementBalance).abs();
          if (balance > sub.balanceMax!) {
            listNotifications.add(
              DashboardNotification(
                title: 'تجاوز الحد الأقصى',
                message:
                    'الحساب "${sub.accountName}" تجاوز الحد الأقصى المسموح به.',
                icon: FluentIcons.warning,
                color: Colors.orange,
              ),
            );
          }
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
        final isNegative = entry.baseAmount < 0;
        final prefix = isNegative ? '-' : '+';
        return DashboardTransaction(
          title: entry.description ?? entry.referenceNumber,
          subtitle:
              'قيد يومية - ${DateFormat('yyyy-MM-dd HH:mm').format(entry.createdAt)}',
          amount:
              '$prefix ${entry.baseAmount.abs().toStringAsFixed(2)} ${entry.currencyId}',
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
    required String currencySymbol,
  }) : value = _formatValue(value, currencySymbol);

  static String _formatValue(double amount, String currencySymbol) {
    return '${AppMoneyFormatter.formatDouble(amount)} $currencySymbol';
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
