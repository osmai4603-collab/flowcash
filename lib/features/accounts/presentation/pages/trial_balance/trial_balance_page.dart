import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/presentation/blocs/trial_balance/trial_balance_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/trial_balance/trial_balance_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/trial_balance/trial_balance_state.dart';

class TrialBalancePage extends StatefulWidget {
  const TrialBalancePage({super.key});

  @override
  State<TrialBalancePage> createState() => _TrialBalancePageState();
}

class _TrialBalancePageState extends State<TrialBalancePage> {
  DateTime? _startDate;
  DateTime? _endDate;

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
          GetIt.instance<TrialBalanceBloc>()..add(const LoadTrialBalance()),
      child: Builder(
        builder: (context) {
          return BlocBuilder<TrialBalanceBloc, TrialBalanceState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 1. Filter & Status Header Bar
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
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'من تاريخ',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(
                                    Icons.date_range_outlined,
                                  ),
                                  suffixIcon: _startDate != null
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
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
                                child: Text(
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
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'إلى تاريخ',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(
                                    Icons.date_range_outlined,
                                  ),
                                  suffixIcon: _endDate != null
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
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
                                child: Text(
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
                              context.read<TrialBalanceBloc>().add(
                                LoadTrialBalance(
                                  startDate: _startDate,
                                  endDate: _endDate,
                                ),
                              );
                            },
                            icon: const Icon(Icons.compare_arrows),
                            label: const Text('تحديث الميزان'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
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
                            icon: const Icon(Icons.refresh),
                            tooltip: 'إعادة تحميل البيانات',
                            onPressed: () {
                              context.read<TrialBalanceBloc>().add(
                                LoadTrialBalance(
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

                    // 2. Trial Balance Content
                    Expanded(
                      child: state.status == TrialBalanceStatus.loading
                          ? const Center(child: CircularProgressIndicator())
                          : state.status == TrialBalanceStatus.failure
                          ? Center(
                              child: Text(
                                'خطأ في تحميل ميزان المراجعة: ${state.errorMessage}',
                              ),
                            )
                          : _buildTrialBalanceTable(context, state),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTrialBalanceTable(
    BuildContext context,
    TrialBalanceState state,
  ) {
    final theme = Theme.of(context);

    // Map main accounts to their corresponding MainAccountGroup
    final mainAccountsMap = {for (var acc in state.mainAccounts) acc.id: acc};

    // Group subaccounts by MainAccountGroup
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

    // Compute totals
    double grandTotalDebit = 0.0;
    double grandTotalCredit = 0.0;

    final groupSummaries = <MainAccountGroup, Map<String, double>>{};

    for (final group in MainAccountGroup.values) {
      double groupDebit = 0.0;
      double groupCredit = 0.0;

      final subs = groupData[group] ?? [];
      for (final sub in subs) {
        final bal =
            state.subaccountBalances[sub.id] ?? {'debit': 0.0, 'credit': 0.0};
        groupDebit += bal['debit']!;
        groupCredit += bal['credit']!;
      }

      groupSummaries[group] = {'debit': groupDebit, 'credit': groupCredit};
      grandTotalDebit += groupDebit;
      grandTotalCredit += groupCredit;
    }

    final isBalanced = (grandTotalDebit - grandTotalCredit).abs() < 0.01;

    return Container(
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
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withAlpha(80),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'رقم الحساب',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    'اسم الحساب',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'النوع',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'أرصدة مدينة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'أرصدة دائنة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable tree rows
          Expanded(
            child: ListView.builder(
              itemCount: MainAccountGroup.values.length,
              itemBuilder: (context, groupIdx) {
                final group = MainAccountGroup.values[groupIdx];
                final subs = groupData[group] ?? [];
                final summary = groupSummaries[group]!;

                if (subs.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group Header Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 16.0,
                      ),
                      color: theme.colorScheme.primaryContainer.withAlpha(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            group.displayName(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Subaccount rows
                    ...subs.map((sub) {
                      final bal =
                          state.subaccountBalances[sub.id] ??
                          {'debit': 0.0, 'credit': 0.0};
                      if (bal['debit'] == 0 && bal['credit'] == 0) {
                        return const SizedBox.shrink(); // Hide zero balance accounts in trial balance
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
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
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Text(
                                  sub.accountNumber,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(flex: 5, child: Text(sub.accountName)),
                            Expanded(
                              flex: 2,
                              child: Text(
                                sub.subAccountType.name,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    120,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                bal['debit']! > 0
                                    ? bal['debit']!.toStringAsFixed(2)
                                    : '-',
                                style: const TextStyle(color: Colors.green),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                bal['credit']! > 0
                                    ? bal['credit']!.toStringAsFixed(2)
                                    : '-',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Group Subtotal Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(20),
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor.withAlpha(60),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 10,
                            child: Text(
                              'إجمالي المجموعة',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              summary['debit']! > 0
                                  ? summary['debit']!.toStringAsFixed(2)
                                  : '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              summary['credit']! > 0
                                  ? summary['credit']!.toStringAsFixed(2)
                                  : '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Grand Total Footer
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
              border: Border(
                top: BorderSide(color: theme.dividerColor, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                // Verification status indicators
                Row(
                  children: [
                    Icon(
                      isBalanced ? Icons.check_circle : Icons.error,
                      color: isBalanced ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isBalanced ? 'الميزان متوازن' : 'الميزان غير متوازن',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isBalanced ? Colors.green : Colors.red,
                      ),
                    ),
                    if (!isBalanced) ...[
                      const SizedBox(width: 12),
                      Text(
                        'الفرق: ${(grandTotalDebit - grandTotalCredit).abs().toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                const Spacer(),

                // Totals
                Text(
                  'الإجمالي العام:  مدين: ${grandTotalDebit.toStringAsFixed(2)}  |  دائن: ${grandTotalCredit.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
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
