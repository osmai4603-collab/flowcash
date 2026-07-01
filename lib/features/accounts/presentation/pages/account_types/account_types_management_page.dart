import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flowcash/core/enums/main_account_type_enum.dart';
import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class AccountTypesManagementPage extends StatefulWidget {
  const AccountTypesManagementPage({super.key});

  @override
  State<AccountTypesManagementPage> createState() =>
      _AccountTypesManagementPageState();
}

class _AccountTypesManagementPageState
    extends State<AccountTypesManagementPage> {
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
            text: const fluent.Text(
              'أنواع الحسابات الرئيسية (Main Account Types)',
            ),
            body: _buildMainTypesTable(context),
          ),
          fluent.Tab(
            text: const fluent.Text(
              'أنواع الحسابات الفرعية (Sub Account Types)',
            ),
            body: _buildSubTypesTable(context),
          ),
        ],
      ),
    );
  }

  Map<int, TableWidgetColumnWidth> _getMainTypesColumnWidths() {
    return {
      0: const FlexTableWidgetColumnWidth(2, alignment: AlignmentDirectional.centerStart),
      1: const FlexTableWidgetColumnWidth(4, alignment: AlignmentDirectional.centerStart),
      2: const FlexTableWidgetColumnWidth(3, alignment: AlignmentDirectional.centerStart),
      3: const FlexTableWidgetColumnWidth(2, alignment: AlignmentDirectional.centerStart),
      4: const FlexTableWidgetColumnWidth(2, alignment: AlignmentDirectional.centerStart),
      5: const FlexTableWidgetColumnWidth(3, alignment: AlignmentDirectional.centerStart),
    };
  }

  Map<int, TableWidgetColumnWidth> _getSubTypesColumnWidths() {
    return {
      0: const FlexTableWidgetColumnWidth(4, alignment: AlignmentDirectional.centerStart),
      1: const FlexTableWidgetColumnWidth(4, alignment: AlignmentDirectional.centerStart),
      2: const FlexTableWidgetColumnWidth(4, alignment: AlignmentDirectional.centerStart),
      3: const FlexTableWidgetColumnWidth(3, alignment: AlignmentDirectional.centerStart),
      4: const FlexTableWidgetColumnWidth(2, alignment: AlignmentDirectional.centerStart),
    };
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
            child: TableWidget<MainAccountType>(
              columns: _getMainTypesColumnWidths(),
              header: const [
                'رقم النوع',
                'الاسم المعروض',
                'المجموعة',
                'حالة الزيادة',
                'حالة النقصان',
                'نوع الفترة',
              ],
              items: types,
              rowColor: theme.colorScheme.surface,
              builder: (context, type, index) => [
                Text(
                  type.accountNumber,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                fluent.Text(type.displayName()),
                Material(
                  type: MaterialType.transparency,
                  child: Chip(
                    label: fluent.Text(
                      type.accountType.displayName(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: theme
                        .colorScheme
                        .primaryContainer
                        .withAlpha(50),
                  ),
                ),
                fluent.Text(
                  type.incrementName,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                fluent.Text(
                  type.decrementName,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                fluent.Text(
                  type.isPeriodPermanent
                      ? 'دائمة (Permanent)'
                      : 'مؤقتة (Temporary)',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
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
            child: TableWidget<SubAccountType>(
              columns: _getSubTypesColumnWidths(),
              header: const [
                'الاسم المفرد',
                'الاسم الجمع',
                'الحساب الرئيسي الأب',
                'نوع الشخص',
                'نوع الحساب',
              ],
              items: types,
              rowColor: theme.colorScheme.surface,
              builder: (context, type, index) => [
                fluent.Text(type.accountName),
                fluent.Text(type.totalName),
                fluent.Text(type.mainAccountType.displayName()),
                fluent.Text(
                  type.personType.name,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: Chip(
                    label: fluent.Text(
                      type.isDefault ? 'افتراضي' : 'مخصص',
                      style: TextStyle(
                        fontSize: 11,
                        color: type.isDefault
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    backgroundColor:
                        (type.isDefault
                                ? Colors.green
                                : Colors.orange)
                            .withAlpha(30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
