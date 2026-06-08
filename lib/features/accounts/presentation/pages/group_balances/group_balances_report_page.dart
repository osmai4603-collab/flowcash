import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/presentation/blocs/group_balances/group_balances_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/group_balances/group_balances_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/group_balances/group_balances_state.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class GroupBalancesReportPage extends StatefulWidget {
  const GroupBalancesReportPage({super.key});

  @override
  State<GroupBalancesReportPage> createState() =>
      _GroupBalancesReportPageState();
}

class _GroupBalancesReportPageState extends State<GroupBalancesReportPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  MainAccountGroup? _selectedGroupFilter;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) =>
          GetIt.instance<GroupBalancesBloc>()..add(const LoadGroupBalances()),
      child: Builder(
        builder: (context) {
          return BlocBuilder<GroupBalancesBloc, GroupBalancesState>(
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        children: [
                          // 1. Date Range Toolbar
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.dividerColor.withAlpha(50),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Start Date
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _selectDate(context, true),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'من تاريخ',
                                        border: const OutlineInputBorder(),
                                        prefixIcon: const Icon(
                                          fluent.FluentIcons.calendar_settings,
                                        ),
                                        suffixIcon: _startDate != null
                                            ? IconButton(
                                                icon: const Icon(
                                                  fluent.FluentIcons.clear,
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _startDate = null;
                                                  });
                                                },
                                              )
                                            : null,
                                      ),
                                      child: fluent.Text(
                                        _startDate != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(_startDate!)
                                            : 'البداية',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // End Date
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _selectDate(context, false),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'إلى تاريخ',
                                        border: const OutlineInputBorder(),
                                        prefixIcon: const Icon(
                                          fluent.FluentIcons.calendar_settings,
                                        ),
                                        suffixIcon: _endDate != null
                                            ? IconButton(
                                                icon: const Icon(
                                                  fluent.FluentIcons.clear,
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _endDate = null;
                                                  });
                                                },
                                              )
                                            : null,
                                      ),
                                      child: fluent.Text(
                                        _endDate != null
                                            ? DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(_endDate!)
                                            : 'النهاية',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Load button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<GroupBalancesBloc>().add(
                                      LoadGroupBalances(
                                        startDate: _startDate,
                                        endDate: _endDate,
                                      ),
                                    );
                                  },
                                  icon: const Icon(fluent.FluentIcons.chart),
                                  label: const fluent.Text('عرض التقرير'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Refresh Button
                                IconButton(
                                  icon: const Icon(fluent.FluentIcons.refresh),
                                  tooltip: 'إعادة تحميل البيانات',
                                  onPressed: () {
                                    context.read<GroupBalancesBloc>().add(
                                      LoadGroupBalances(
                                        startDate: _startDate,
                                        endDate: _endDate,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2. Main Content
                          Expanded(
                            child: state.status == GroupBalancesStatus.loading
                                ? const Center(child: fluent.ProgressRing())
                                : state.status == GroupBalancesStatus.failure
                                ? Center(
                                    child: fluent.Text(
                                      'خطأ في تحميل التقرير: ${state.errorMessage}',
                                    ),
                                  )
                                : _buildReportContent(context, state),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, GroupBalancesState state) {
    final theme = Theme.of(context);

    // Map main accounts to their corresponding MainAccountGroup
    final mainAccountsMap = {for (var acc in state.mainAccounts) acc.id: acc};

    // Calculate summaries for cards
    final groupData = <MainAccountGroup, List<SubAccountEntity>>{};
    for (final group in MainAccountGroup.values) {
      groupData[group] = [];
    }

    for (final sub in state.subAccounts) {
      final parent = mainAccountsMap[sub.mainAccountId];
      if (parent != null) {
        final group = parent.mainAccountType.accountType;
        groupData[group]?.add(sub);
      }
    }

    final groupSummaries = <MainAccountGroup, Map<String, dynamic>>{};

    for (final group in MainAccountGroup.values) {
      double totalDebit = 0.0;
      double totalCredit = 0.0;
      final subs = groupData[group] ?? [];

      for (final sub in subs) {
        final bal =
            state.subaccountBalances[sub.id] ?? {'debit': 0.0, 'credit': 0.0};
        totalDebit += bal['debit']!;
        totalCredit += bal['credit']!;
      }

      groupSummaries[group] = {
        'debit': totalDebit,
        'credit': totalCredit,
        'count': subs.length,
      };
    }

    // Filter accounts list for detailed table based on selected card
    final displayedSubs = <SubAccountEntity>[];
    for (final group in MainAccountGroup.values) {
      if (_selectedGroupFilter == null || _selectedGroupFilter == group) {
        displayedSubs.addAll(groupData[group] ?? []);
      }
    }

    return Column(
      children: [
        // Group Summary Cards Row
        Row(
          children: MainAccountGroup.values.map((group) {
            final summary = groupSummaries[group]!;
            final debit = summary['debit'] as double;
            final credit = summary['credit'] as double;
            final count = summary['count'] as int;
            final net = debit - credit;

            final isSelected = _selectedGroupFilter == group;

            return Expanded(
              child: Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      if (_selectedGroupFilter == group) {
                        _selectedGroupFilter = null; // Clear filter
                      } else {
                        _selectedGroupFilter = group;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            fluent.Text(
                              group.displayName(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              fluent.FluentIcons.folder,
                              color: theme.colorScheme.primary.withAlpha(180),
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        fluent.Text(
                          '$count حسابات فرعية',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withAlpha(120),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        fluent.Text(
                          net.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: net >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Detail Table Title
        Row(
          children: [
            Icon(fluent.FluentIcons.list, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            fluent.Text(
              _selectedGroupFilter == null
                  ? 'تفاصيل أرصدة جميع المجموعات'
                  : 'تفاصيل أرصدة مجموعة: ${_selectedGroupFilter!.displayName()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_selectedGroupFilter != null)
              fluent.Button(
                onPressed: () {
                  setState(() {
                    _selectedGroupFilter = null;
                  });
                },
                child: const fluent.Text('عرض الكل'),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Detail Table List
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor.withAlpha(50)),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                      50,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor.withAlpha(80),
                      ),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: fluent.Text(
                          'رقم الحساب',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: fluent.Text(
                          'اسم الحساب',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: fluent.Text(
                          'المجموعة الرئيسية',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: fluent.Text(
                          'مدين (وارد)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: fluent.Text(
                          'دائن (صادر)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: fluent.Text(
                          'صافي الرصيد',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),

                // Table Items
                Expanded(
                  child: displayedSubs.isEmpty
                      ? const Center(
                          child: fluent.Text('لا توجد حسابات فرعية لعرضها'),
                        )
                      : ListView.builder(
                          itemCount: displayedSubs.length,
                          itemBuilder: (context, index) {
                            final sub = displayedSubs[index];
                            final bal =
                                state.subaccountBalances[sub.id] ??
                                {'debit': 0.0, 'credit': 0.0};
                            final debit = bal['debit']!;
                            final credit = bal['credit']!;
                            final net = debit - credit;

                            final parent = mainAccountsMap[sub.mainAccountId];
                            final groupName =
                                parent?.mainAccountType.accountType
                                    .displayName() ??
                                '';

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: theme.dividerColor.withAlpha(20),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: fluent.Text(
                                      sub.accountNumber,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: fluent.Text(sub.accountName),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: fluent.Text(
                                      groupName,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withAlpha(120),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: fluent.Text(
                                      debit > 0
                                          ? debit.toStringAsFixed(2)
                                          : '-',
                                      style: const TextStyle(
                                        color: Colors.green,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: fluent.Text(
                                      credit > 0
                                          ? credit.toStringAsFixed(2)
                                          : '-',
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: fluent.Text(
                                      net.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: net >= 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
