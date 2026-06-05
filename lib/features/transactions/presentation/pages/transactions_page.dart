import 'package:fluent_ui/fluent_ui.dart';

class TransactionsDashboard extends StatefulWidget {
  const TransactionsDashboard({super.key});

  @override
  State<TransactionsDashboard> createState() => _TransactionsDashboardState();
}

class _TransactionsDashboardState extends State<TransactionsDashboard> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'فواتير المبيعات',
    'فواتير المشتريات',
    'المرتجعات',
    'المصروفات والإيرادات',
    'سندات القبض والصرف',
    'الإيداعات والسحوبات',
    'التقارير المالية',
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
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
          onChanged: (index) => setState(() => _selectedIndex = index),
          displayMode: PaneDisplayMode.top,
          items: List<NavigationPaneItem>.generate(
            _titles.length,
            (i) => PaneItem(
              icon: const Icon(FluentIcons.document),
              title: Text(_titles[i]),
              body: _TransactionsPlaceholder(title: _titles[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionsPlaceholder extends StatelessWidget {
  final String title;

  const _TransactionsPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          // elevation: 4,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(16),
          // ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.typography.display,
                ),
                const SizedBox(height: 16),
                const Text(
                  'هذا القسم قيد الإنشاء. سيتم إضافة واجهات إدارة البيانات وبطاقات التفاصيل ضمن هذه التبويبات.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
