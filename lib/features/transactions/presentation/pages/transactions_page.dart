import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<Tab> _tabs = [
    Tab(text: 'فواتير المبيعات'),
    Tab(text: 'فواتير المشتريات'),
    Tab(text: 'المرتجعات'),
    Tab(text: 'المصروفات والإيرادات'),
    Tab(text: 'سندات القبض والصرف'),
    Tab(text: 'الإيداعات والسحوبات'),
    Tab(text: 'التقارير المالية'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المعاملات المالية'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: _tabs,
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
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _TransactionsPlaceholder(title: 'فواتير المبيعات'),
            _TransactionsPlaceholder(title: 'فواتير المشتريات'),
            _TransactionsPlaceholder(title: 'المرتجعات'),
            _TransactionsPlaceholder(title: 'المصروفات والإيرادات'),
            _TransactionsPlaceholder(title: 'سندات القبض والصرف'),
            _TransactionsPlaceholder(title: 'الإيداعات والسحوبات'),
            _TransactionsPlaceholder(title: 'التقارير المالية'),
          ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
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
