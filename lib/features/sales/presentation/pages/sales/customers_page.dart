import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flowcash/core/datasources/implementations/person_local_data_source_impl.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/features/sales/presentation/pages/customers/customer_form_page.dart';
import 'package:flowcash/features/injection_container.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final searchController = TextEditingController();
  final _dataSource = PersonLocalDataSourceImpl(sl<SqliteDatabase>());

  bool _isLoading = true;
  List<PersonEntity> _persons = [];
  List<PersonEntity> _filteredPersons = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(_updateFilter);
    _loadCustomers();
  }

  @override
  void dispose() {
    searchController.removeListener(_updateFilter);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final allPersons = await _dataSource.get();
      setState(() {
        _persons = allPersons;
      });
      _updateFilter();
    } catch (_) {
      setState(() {
        _persons = [];
        _filteredPersons = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateFilter() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      _filteredPersons = query.isEmpty
          ? _persons
          : _persons.where((person) {
              return person.personName.toLowerCase().contains(query) ||
                  (person.phoneNumber?.toLowerCase().contains(query) ?? false) ||
                  (person.address?.toLowerCase().contains(query) ?? false) ||
                  (person.email?.toLowerCase().contains(query) ?? false);
            }).toList();
    });
  }

  Future<void> _onRefreshPressed() async {
    await _loadCustomers();
  }

  Future<void> _onAddCustomerPressed() async {
    final newCustomer = await fluent.showDialog<PersonEntity>(
      context: context,
      builder: (_) => const CustomerFormPage(),
    );
    if (newCustomer != null) {
      await _dataSource.insert(newCustomer);
      await _loadCustomers();
    }
  }

  Widget _buildCustomerTable() {
    final borderColor = Colors.grey.shade300;
    if (_filteredPersons.isEmpty) {
      return Center(
        child: fluent.Text(
          _persons.isEmpty ? 'لا يوجد عملاء مسجلين' : 'لا يوجد عملاء مطابقين للبحث',
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: fluent.Table(
        border: TableBorder.all(width: 0.5, color: borderColor),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FixedColumnWidth(40),
          1: FixedColumnWidth(180),
          2: FixedColumnWidth(130),
          3: FixedColumnWidth(220),
          4: FixedColumnWidth(220),
          5: FixedColumnWidth(120),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('No', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('اسم العميل', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('الهاتف', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('العنوان', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('البريد الإلكتروني', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('النوع', textAlign: TextAlign.center),
              ),
            ],
          ),
          ..._filteredPersons.asMap().entries.map((entry) {
            final index = entry.key;
            final person = entry.value;
            final rowColor = index.isOdd ? Colors.grey.shade50 : null;
            return TableRow(
              decoration: BoxDecoration(color: rowColor),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text('${index + 1}', textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(person.personName, overflow: TextOverflow.ellipsis),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(person.phoneNumber ?? '-', overflow: TextOverflow.ellipsis),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(person.address ?? '-', overflow: TextOverflow.ellipsis),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(person.email ?? '-', overflow: TextOverflow.ellipsis),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(person.personType.displayName(), textAlign: TextAlign.center),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      header: fluent.PageHeader(
        title: Row(
          children: const [
            fluent.Icon(fluent.FluentIcons.people, size: 20),
            SizedBox(width: 10),
            fluent.Text('العملاء'),
          ],
        ),
        commandBar: Row(
          children: [
            fluent.FilledButton(
              onPressed: _onAddCustomerPressed,
              child: const Row(
                children: [
                  fluent.Icon(fluent.FluentIcons.add),
                  SizedBox(width: 8),
                  fluent.Text('إضافة عميل جديد'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            fluent.Tooltip(
              message: 'إعادة تحميل العملاء',
              child: fluent.IconButton(
                icon: const fluent.Icon(fluent.FluentIcons.refresh),
                onPressed: _onRefreshPressed,
              ),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: fluent.TextBox(
                    controller: searchController,
                    prefix: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: fluent.Icon(fluent.FluentIcons.search),
                    ),
                    placeholder: 'ابحث عن عميل هنا',
                  ),
                ),
                const SizedBox(width: 12),
                fluent.Text(
                  _filteredPersons.length.toString(),
                  style: fluent.TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const fluent.Text('نتيجة'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: fluent.ProgressRing())
                  : _buildCustomerTable(),
            ),
          ],
        ),
      ),
    );
  }
}
