import 'package:flutter/material.dart' hide Tab;
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class AccountTypesManagementPage extends StatefulWidget {
  const AccountTypesManagementPage({super.key});

  @override
  State<AccountTypesManagementPage> createState() => _AccountTypesManagementPageState();
}

class _AccountTypesManagementPageState extends State<AccountTypesManagementPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      padding: EdgeInsets.zero,
      content: fluent.TabView(
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
        closeButtonVisibility: fluent.CloseButtonVisibilityMode.never,
        tabs: [
          fluent.Tab(
            text: const fluent.Text('أنواع الحسابات الرئيسية (Main Account Types)'),
            body: _buildMainTypesTable(context),
          ),
          fluent.Tab(
            text: const fluent.Text('أنواع الحسابات الفرعية (Sub Account Types)'),
            body: _buildSubTypesTable(context),
          ),
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
            child: fluent.Text(
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
                          Expanded(flex: 2, child: fluent.Text('رقم النوع', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 4, child: fluent.Text('الاسم المعروض', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 3, child: fluent.Text('المجموعة', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: fluent.Text('حالة الزيادة', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: fluent.Text('حالة النقصان', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 3, child: fluent.Text('نوع الفترة', style: TextStyle(fontWeight: FontWeight.bold))),
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
                              child: fluent.Text(
                                type.accountNumber,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(flex: 4, child: fluent.Text(type.displayName())),
                            Expanded(
                              flex: 3,
                            child: Material(
                              type: MaterialType.transparency,
                              child: Chip(
                                label: fluent.Text(type.accountType.displayName(), style: const TextStyle(fontSize: 12)),
                                backgroundColor: theme.colorScheme.primaryContainer.withAlpha(50),
                              ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: fluent.Text(
                                type.incrementName,
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: fluent.Text(
                                type.decrementName,
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: fluent.Text(
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
            child: fluent.Text(
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
                          Expanded(flex: 4, child: fluent.Text('الاسم المفرد', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 4, child: fluent.Text('الاسم الجمع', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 4, child: fluent.Text('الحساب الرئيسي الأب', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 3, child: fluent.Text('نوع الشخص', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: fluent.Text('نوع الحساب', style: TextStyle(fontWeight: FontWeight.bold))),
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
                            Expanded(flex: 4, child: fluent.Text(type.accountName)),
                            Expanded(flex: 4, child: fluent.Text(type.totalName)),
                            Expanded(flex: 4, child: fluent.Text(type.mainAccountType.displayName())),
                            Expanded(
                              flex: 3,
                              child: fluent.Text(
                                type.personType.name,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Material(
                              type: MaterialType.transparency,
                              child: Chip(
                                label: fluent.Text(
                                  type.isDefault ? 'افتراضي' : 'مخصص',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: type.isDefault ? Colors.green : Colors.orange,
                                  ),
                                ),
                                backgroundColor: (type.isDefault ? Colors.green : Colors.orange).withAlpha(30),
                              ),
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
