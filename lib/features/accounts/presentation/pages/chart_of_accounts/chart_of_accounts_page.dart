import 'package:flowcash/core/theme/paddings.dart';
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
import 'package:provider/provider.dart';

// Dialogs
import 'main_account_form_dialog.dart';
import 'main_accounts_widget.dart';
import 'subaccounts_widget.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

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
  int? _selectedMainAccountId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // _buildHeader(theme, context),
        Expanded(
          child: BlocBuilder<ChartOfAccountsBloc, ChartOfAccountsState>(
            builder: (context, state) {
              if (state.status == ChartOfAccountsStatus.loading ||
                  state.status == ChartOfAccountsStatus.initial) {
                return const Center(child: fluent.ProgressRing());
              }

              if (state.status == ChartOfAccountsStatus.failure) {
                return Center(
                  child: fluent.Text(
                    state.errorMessage ?? 'حدث خطأ غير متوقع',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              MainAccountEntity? selectedMainAccount;
              if (_selectedMainAccountId != null) {
                for (final account in state.mainAccounts) {
                  if (account.id == _selectedMainAccountId) {
                    selectedMainAccount = account;
                    break;
                  }
                }
              }

              return Row(
                crossAxisAlignment: .start,
                children: [
                  Expanded(
                    flex: 4,
                    child: selectedMainAccount != null
                        ? SubAccountsViewWidget(
                            mainAccount: selectedMainAccount,
                            onMainAccountChanged: (mainAccount) {
                              setState(() {
                                _selectedMainAccountId = mainAccount.id;
                              });
                            },
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'اضغط على حساب رئيسي لعرض الحسابات الفرعية.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      child: MainGroupsWidget(
                        selectedMainAccount: selectedMainAccount,
                        onMainAccountSelected: (mainAccount) {
                          setState(() {
                            _selectedMainAccountId = mainAccount.id;
                          });
                        },
                        onAddMainAccount: (_) {
                          _showMainAccountDialog(context);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Removed unused tree helpers after split-screen redesign.

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
      child: ExcludeSemantics(
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
                  child: fluent.TextBox(
                    decoration: WidgetStateProperty.all(
                      BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withAlpha(80),
                        ),
                      ),
                    ),
                    prefix: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(fluent.FluentIcons.search),
                    ),

                    placeholder: 'البحث برقم الحساب أو الاسم...',

                    padding: Paddings.smallAll,
                  ),
                ),
                BlocBuilder<ChartOfAccountsBloc, ChartOfAccountsState>(
                  builder: (context, state) {
                    final title =
                        state.selectedGroup?.displayName() ?? 'كل المجموعات';
                    return SizedBox(
                      height: 40,
                      child: MenuBar(
                        children: [
                          SubmenuButton(
                            menuChildren: [
                              MenuItemButton(
                                onPressed: () {
                                  context.read<ChartOfAccountsBloc>().add(
                                    FilterChartOfAccounts(null),
                                  );
                                },
                                child: const fluent.Text('كل المجموعات'),
                              ),
                              ...MainAccountGroup.values.map(
                                (g) => MenuItemButton(
                                  onPressed: () {
                                    context.read<ChartOfAccountsBloc>().add(
                                      FilterChartOfAccounts(g),
                                    );
                                  },
                                  child: fluent.Text(g.displayName()),
                                ),
                              ),
                            ],
                            child: fluent.Text(title),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                fluent.CommandBar(
                  mainAxisAlignment: MainAxisAlignment.end,
                  primaryItems: [
                    fluent.CommandBarButton(
                      onPressed: () {
                        _showMainAccountDialog(context);
                      },
                      icon: const Icon(fluent.FluentIcons.add),
                      label: const fluent.Text('إضافة حساب رئيسي'),
                      // style: fluent.CommandBarButton.styleFrom(
                      //   backgroundColor: theme.colorScheme.primary,
                      //   foregroundColor: theme.colorScheme.onPrimary,
                      // ),
                    ),
                    fluent.CommandBarButton(
                      icon: const Icon(fluent.FluentIcons.refresh),
                      label: const fluent.Text('تحديث'),
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
      ),
    );
  }

}
