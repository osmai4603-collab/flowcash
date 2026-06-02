import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// Enums
import 'package:flowcash/core/enums/main_account_group_enum.dart';

// Bloc & Navigation
import 'package:flowcash/features/accounts/presentation/blocs/chart_of_accounts/chart_of_accounts_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/chart_of_accounts/chart_of_accounts_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/chart_of_accounts/chart_of_accounts_state.dart';
import 'package:flowcash/features/accounts/presentation/pages/accounts_page.dart';
import 'package:provider/provider.dart';

// Entities
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

// Widgets
import 'package:flowcash/features/accounts/presentation/widgets/account_group_section.dart';
import 'package:flowcash/features/accounts/presentation/widgets/main_account_row.dart';
import 'package:flowcash/features/accounts/presentation/widgets/sub_account_row.dart';

// Dialogs
import 'main_account_form_dialog.dart';
import 'sub_account_form_dialog.dart';

class ChartOfAccountsPage extends StatelessWidget {
  const ChartOfAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<ChartOfAccountsBloc>()
            ..add(const LoadChartOfAccounts()),
      child: const _ChartOfAccountsContent(),
    );
  }
}

class _ChartOfAccountsContent extends StatefulWidget {
  const _ChartOfAccountsContent();

  @override
  State<_ChartOfAccountsContent> createState() =>
      _ChartOfAccountsContentState();
}

class _ChartOfAccountsContentState extends State<_ChartOfAccountsContent> {
  final Set<int> _expandedMainAccountIds = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(theme, context),

          // 📊 Table Header Row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(60),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(4),
                3: FlexColumnWidth(2),
                4: FixedColumnWidth(90),
                5: FixedColumnWidth(90),
                6: FixedColumnWidth(90),
                7: FixedColumnWidth(80),
                8: FixedColumnWidth(120),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: const Text(
                        'رقم الحساب',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: const Text(
                        'اسم الحساب',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: const Text(
                        'نوع الحساب',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: const Text(
                        'المدين',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: const Text(
                        'الدائن',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: const Text(
                        'الصافي',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: const Text(
                        'العملة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: const Text(
                        'الإجراءات',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🏛️ Chart Tree View
          Expanded(
            child: BlocBuilder<ChartOfAccountsBloc, ChartOfAccountsState>(
              builder: (context, state) {
                if (state.status == ChartOfAccountsStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ChartOfAccountsStatus.failure) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? 'حدث خطأ غير متوقع',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // Filter & Sort Groups & Main Accounts
                final groupsToRender = state.selectedGroup != null
                    ? [state.selectedGroup!]
                    : MainAccountGroup.values;

                final listItems = <Widget>[];

                for (final group in groupsToRender) {
                  // Filter main accounts for this group
                  final groupMainAccs = state.mainAccounts.where((m) {
                    final isSameGroup = m.mainAccountType.accountType == group;
                    if (!isSameGroup) return false;

                    if (_searchQuery.isNotEmpty) {
                      return m.accountName.contains(_searchQuery) ||
                          m.accountNumber.contains(_searchQuery);
                    }
                    return true;
                  }).toList();

                  // Sort by account number
                  groupMainAccs.sort(
                    (a, b) => a.accountNumber.compareTo(b.accountNumber),
                  );

                  if (groupMainAccs.isEmpty && _searchQuery.isNotEmpty) {
                    continue;
                  }

                  // Render Group Header
                  listItems.add(
                    AccountGroupSection(
                      group: group,
                      mainAccounts: groupMainAccs,
                    ),
                  );

                  // Render Main Accounts & Sub Accounts
                  for (final mainAcc in groupMainAccs) {
                    final isExpanded = _expandedMainAccountIds.contains(
                      mainAcc.id,
                    );

                    listItems.add(
                      MainAccountRow(
                        mainAccount: mainAcc,
                        isExpanded: isExpanded,
                        onToggleExpand: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedMainAccountIds.remove(mainAcc.id);
                            } else {
                              _expandedMainAccountIds.add(mainAcc.id);
                            }
                          });
                        },
                        onAddSubAccount: () =>
                            _showSubAccountDialog(context, mainAcc.id),
                        onEdit: () => _showMainAccountDialog(
                          context,
                          mainAccount: mainAcc,
                        ),
                        onDelete: () {
                          context.read<ChartOfAccountsBloc>().add(
                            DeleteMainAccount(mainAcc.id),
                          );
                        },
                      ),
                    );

                    // Render Sub Accounts if expanded
                    if (isExpanded) {
                      final children = state.subAccounts
                          .where((s) => s.mainAccountId == mainAcc.id)
                          .toList();
                      // Sort by account number
                      children.sort(
                        (a, b) => a.accountNumber.compareTo(b.accountNumber),
                      );

                      for (final subAcc in children) {
                        listItems.add(
                          SubAccountRow(
                            subAccount: subAcc,
                            onEdit: () => _showSubAccountDialog(
                              context,
                              mainAcc.id,
                              subAccount: subAcc,
                            ),
                            onDelete: () {
                              context.read<ChartOfAccountsBloc>().add(
                                DeleteSubAccount(subAcc.id),
                              );
                            },
                            onViewStatement: () {
                              Provider.of<AccountsTabNotifier>(
                                context,
                                listen: false,
                              ).navigateToAccountStatement(subAcc.id);
                            },
                          ),
                        );
                      }

                      if (children.isEmpty) {
                        listItems.add(
                          Container(
                            padding: const EdgeInsets.all(12),
                            alignment: Alignment.center,
                            child: Text(
                              'لا توجد حسابات فرعية مضافة بعد لهذا الحساب.',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withAlpha(
                                  120,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  }
                }

                if (listItems.isEmpty) {
                  return const Center(
                    child: Text('لا توجد حسابات مطابقة للبحث الحالي.'),
                  );
                }

                return ListView(children: listItems);
              },
            ),
          ),
        ],
      ),
    );
  }

  Container _buildHeader(ThemeData theme, BuildContext context) {
    return Container(
      // height: 40.0,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث برقم الحساب أو الاسم...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withAlpha(40),
                    filled: true,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
              ),
              BlocBuilder<ChartOfAccountsBloc, ChartOfAccountsState>(
                builder: (context, state) {
                  return DropdownButton<MainAccountGroup?>(
                    value: state.selectedGroup,
                    hint: const Text('كل المجموعات'),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<MainAccountGroup?>(
                        value: null,
                        child: Text('كل المجموعات'),
                      ),
                      ...MainAccountGroup.values.map(
                        (g) => DropdownMenuItem<MainAccountGroup?>(
                          value: g,
                          child: Text(g.displayName()),
                        ),
                      ),
                    ],
                    onChanged: (group) {
                      context.read<ChartOfAccountsBloc>().add(
                            FilterChartOfAccounts(group),
                          );
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _showMainAccountDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة حساب رئيسي'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<ChartOfAccountsBloc>().add(
                            const LoadChartOfAccounts(),
                          );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showMainAccountDialog(
    BuildContext context, {
    MainAccountEntity? mainAccount,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MainAccountFormDialog(mainAccount: mainAccount),
    );
    if (result == true && context.mounted) {
      context.read<ChartOfAccountsBloc>().add(const LoadChartOfAccounts());
    }
  }

  Future<void> _showSubAccountDialog(
    BuildContext context,
    int mainAccountId, {
    SubAccountEntity? subAccount,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SubAccountFormDialog(
        mainAccountId: mainAccountId,
        subAccount: subAccount,
      ),
    );
    if (result == true && context.mounted) {
      context.read<ChartOfAccountsBloc>().add(const LoadChartOfAccounts());
    }
  }
}
