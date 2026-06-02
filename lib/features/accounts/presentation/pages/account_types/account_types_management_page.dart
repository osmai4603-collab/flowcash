import 'package:flutter/material.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';

class AccountTypesManagementPage extends StatefulWidget {
  const AccountTypesManagementPage({super.key});

  @override
  State<AccountTypesManagementPage> createState() => _AccountTypesManagementPageState();
}

class _AccountTypesManagementPageState extends State<AccountTypesManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _innerTabController;

  @override
  void initState() {
    super.initState();
    _innerTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _innerTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: theme.colorScheme.surface,
          child: TabBar(
            controller: _innerTabController,
            tabs: const [
              Tab(text: 'أنواع الحسابات الرئيسية (Main Account Types)'),
              Tab(text: 'أنواع الحسابات الفرعية (Sub Account Types)'),
            ],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: TabBarView(
        controller: _innerTabController,
        children: [
          _buildMainTypesTable(context),
          _buildSubTypesTable(context),
        ],
      ),
    );
  }

  Widget _buildMainTypesTable(BuildContext context) {
    final theme = Theme.of(context);
    final types = MainAccountType.values;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'أنواع الحسابات الرئيسية المرجعية المحددة في النظام (للعرض فقط)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor.withAlpha(50)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListView(
                  children: [
                    // Header Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                      child: Row(
                        children: const [
                          Expanded(flex: 2, child: Text('رقم النوع', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 4, child: Text('الاسم المعروض', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 3, child: Text('المجموعة', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('حالة الزيادة', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('حالة النقصان', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 3, child: Text('نوع الفترة', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Data Rows
                    ...types.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor.withAlpha(30),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                type.accountNumber,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(flex: 4, child: Text(type.displayName())),
                            Expanded(
                              flex: 3,
                              child: Chip(
                                label: Text(type.accountType.displayName(), style: const TextStyle(fontSize: 12)),
                                backgroundColor: theme.colorScheme.primaryContainer.withAlpha(50),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                type.incrementName,
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                type.decrementName,
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                type.isPeriodPermanent ? 'دائمة (Permanent)' : 'مؤقتة (Temporary)',
                                style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTypesTable(BuildContext context) {
    final theme = Theme.of(context);
    final types = SubAccountType.values;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'أنواع الحسابات الفرعية المرجعية المحددة في النظام (للعرض فقط)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor.withAlpha(50)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListView(
                  children: [
                    // Header Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                      child: Row(
                        children: const [
                          Expanded(flex: 4, child: Text('الاسم المفرد', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 4, child: Text('الاسم الجمع', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 4, child: Text('الحساب الرئيسي الأب', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 3, child: Text('نوع الشخص', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('نوع الحساب', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Data Rows
                    ...types.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor.withAlpha(30),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 4, child: Text(type.accountName)),
                            Expanded(flex: 4, child: Text(type.totalName)),
                            Expanded(flex: 4, child: Text(type.mainAccountType.displayName())),
                            Expanded(
                              flex: 3,
                              child: Text(
                                type.personType.name,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Chip(
                                label: Text(
                                  type.isDefault ? 'افتراضي' : 'مخصص',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: type.isDefault ? Colors.green : Colors.orange,
                                  ),
                                ),
                                backgroundColor: (type.isDefault ? Colors.green : Colors.orange).withAlpha(30),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
