import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/accounts/presentation/blocs/account_statement/account_statement_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/account_statement/account_statement_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/account_statement/account_statement_state.dart';

import 'dart:io';
import 'package:flowcash/core/enums/journal_status_enum.dart';
import 'package:flowcash/core/formatters/date_formatter.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:provider/provider.dart';
import 'package:flowcash/features/accounts/presentation/pages/accounts_dashboard.dart';

class AccountStatementPage extends StatefulWidget {
  final SubAccountEntity? subAccount;

  const AccountStatementPage({super.key, this.subAccount});

  @override
  State<AccountStatementPage> createState() => _AccountStatementPageState();
}

class _AccountStatementPageState extends State<AccountStatementPage> {
  late AccountStatementBloc _bloc;
  int? _lastLoadedSubAccountId;

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Map<int, TableWidgetColumnWidth> getWidths() {
    return {
      0: FixedTableWidgetColumnWidth(35, alignment: Alignment.center),
      1: FixedTableWidgetColumnWidth(isDesktop ? 100 : 77, alignment: Alignment.center),
      2: const FlexTableWidgetColumnWidth(0.40, alignment: AlignmentDirectional.centerStart),
      3: const FlexTableWidgetColumnWidth(0.20, alignment: Alignment.center),
      4: const FlexTableWidgetColumnWidth(0.20, alignment: Alignment.center),
      5: const FlexTableWidgetColumnWidth(0.20, alignment: AlignmentDirectional.centerEnd),
    };
  }

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.instance<AccountStatementBloc>();
    _lastLoadedSubAccountId = widget.subAccount?.id;
    if (widget.subAccount != null) {
      _bloc.add(LoadAccountStatement(subAccountId: widget.subAccount!.id));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);

    // Attempt to read AccountsTabNotifier if it exists in the ancestor context
    AccountsTabNotifier? tabNotifier;
    try {
      tabNotifier = Provider.of<AccountsTabNotifier>(context, listen: true);
    } catch (_) {
      // not available
    }

    if (tabNotifier != null && tabNotifier.selectedSubAccountId != null) {
      final notifierId = tabNotifier.selectedSubAccountId!;
      if (notifierId != _lastLoadedSubAccountId) {
        _lastLoadedSubAccountId = notifierId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _bloc.add(LoadAccountStatement(subAccountId: notifierId));
        });
      }
    }

    return BlocProvider.value(
      value: _bloc,
      child: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // 2. Main Statement Content
                Expanded(
                  child: BlocBuilder<AccountStatementBloc, AccountStatementState>(
                    builder: (context, state) {
                      final activeSubAccount =
                          state.subAccount ?? widget.subAccount;
                      if (activeSubAccount == null) {
                        return Center(
                          child: fluent.Text(
                            'لم يتم تمرير حساب فرعي لعرض كشف الحساب.',
                            style: TextStyle(
                              fontSize: 16,
                              color: colors.onSurface.withAlpha(150),
                            ),
                          ),
                        );
                      }

                      if (state.status == AccountStatementStatus.initial) {
                        return const Center(child: fluent.ProgressRing());
                      }

                      if (state.status == AccountStatementStatus.loading) {
                        return const Center(child: fluent.ProgressRing());
                      }

                      if (state.status == AccountStatementStatus.failure) {
                        return Center(
                          child: fluent.Text(
                            'خطأ في تحميل كشف الحساب: ${state.errorMessage}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      if (state.items.isEmpty) {
                        return Column(
                          children: [
                            _buildTableHeader(colors, activeSubAccount),
                            Expanded(
                              child: Center(
                                child: fluent.Text(
                                  'لا توجد معاملات مسجلة في هذه الفترة',
                                  style: colors.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // Pre-compute the list of balances for running balance:
                      final balances = <double>[];
                      double balanceTemp = state.openingBalance;
                      for (final item in state.items) {
                        final amount = item.amount;
                        final displayedDebit = item.journalStatus == JournalStatus.increment
                            ? amount
                            : 0.0;
                        final displayedCredit = item.journalStatus == JournalStatus.decrement
                            ? amount
                            : 0.0;
                        balanceTemp += (displayedDebit - displayedCredit);
                        balances.add(balanceTemp);
                      }

                      // Compute totals for the summary row:
                      double totalDebit = 0.0;
                      double totalCredit = 0.0;
                      for (final item in state.items) {
                        item.journalStatus == JournalStatus.increment
                            ? totalDebit += item.amountExPriceHistory
                            : totalCredit += item.amountExPriceHistory;
                      }

                      final lastBalance = balances.isNotEmpty ? balances.last : 0.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table with header + items
                          Expanded(
                            child: TableWidget<JournalItemEntity>(
                              columns: getWidths(),
                              header: [
                                'No',
                                'التاريخ',
                                'البيان التفصيلي',
                                activeSubAccount
                                    .subAccountType
                                    .mainAccountType
                                    .incrementName,
                                activeSubAccount
                                    .subAccountType
                                    .mainAccountType
                                    .decrementName,
                                'الرصيد',
                              ],
                              items: state.items,
                              rowColor: colors.surfaceContainerHighest,
                              paintRowColorWhen: (item, index) => index % 2 != 0,
                              builder: (context, item, index) {
                                final entry = state.entries[item.entryId];
                                final balance = balances[index];
                                final style = colors.bodyStrong.copyWith(fontSize: 12.50);

                                return [
                                  fluent.Text(
                                    '${index + 1}',
                                    textAlign: TextAlign.center,
                                    textDirection: .ltr,
                                    style: style,
                                  ),
                                  fluent.Text(
                                    AppDateFormatter.toDateString(
                                      entry?.createdAt ?? DateTime.now(),
                                    ),
                                    textDirection: .ltr,
                                  ),
                                  fluent.Text(
                                    item.lineDescription ?? entry?.description ?? '',
                                    style: style,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  item.journalStatus == JournalStatus.increment
                                      ? TextWidget(
                                          text: AppMoneyFormatter.formatDouble(item.amount),
                                          alignment: Alignment.centerRight,
                                          padding: Paddings.xsmallAll,
                                          style: style.copyWith(color: Colors.green.shade900),
                                          textDirection: .ltr,
                                          textAlign: TextAlign.center,
                                        )
                                      : const SizedBox(height: 1),
                                  item.journalStatus == JournalStatus.decrement
                                      ? TextWidget(
                                          text: AppMoneyFormatter.formatDouble(item.amount),
                                          alignment: Alignment.centerRight,
                                          padding: Paddings.xsmallAll,
                                          style: style.copyWith(color: Colors.red.shade900),
                                          textDirection: .ltr,
                                          textAlign: TextAlign.center,
                                        )
                                      : const SizedBox(height: 1),
                                  TextWidget(
                                    text: AppMoneyFormatter.formatDouble(balance),
                                    alignment: Alignment.centerRight,
                                    textDirection: .ltr,
                                    textAlign: TextAlign.end,
                                    style: style.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: balance >= 0
                                          ? Colors.green.shade900
                                          : Colors.red.shade900,
                                    ),
                                    padding: Paddings.xsmallAll,
                                  ),
                                ];
                              },
                            ),
                          ),

                          // Summary footer row
                          _buildSummaryFooter(colors, totalDebit, totalCredit, lastBalance),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Header-only widget shown when items are empty
  Widget _buildTableHeader(AppStyle colors, SubAccountEntity activeSubAccount) {
    return TableWidget<Never>(
      columns: getWidths(),
      header: [
        'No',
        'التاريخ',
        'البيان التفصيلي',
        activeSubAccount.subAccountType.mainAccountType.incrementName,
        activeSubAccount.subAccountType.mainAccountType.decrementName,
        'الرصيد',
      ],
      items: const [],
      builder: (context, item, index) => [],
    );
  }

  /// Fixed summary footer row below the table
  Widget _buildSummaryFooter(
    AppStyle colors,
    double totalDebit,
    double totalCredit,
    double lastBalance,
  ) {
    final style = colors.bodyStrong.copyWith(fontSize: 12.50);
    return fluent.Table(
      border: fluent.TableBorder.all(
        width: 0.5,
        color: colors.outline,
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FixedColumnWidth(35),
        1: FixedColumnWidth(isDesktop ? 100 : 77),
        2: const FlexColumnWidth(0.40),
        3: const FlexColumnWidth(0.20),
        4: const FlexColumnWidth(0.20),
        5: const FlexColumnWidth(0.20),
      },
      children: [
        TableRow(
          children: [
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            fluent.Text(
              'الاجمالي',
              textAlign: TextAlign.center,
              style: style.copyWith(fontWeight: FontWeight.bold),
            ),
            TextWidget(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              text: AppMoneyFormatter.formatDouble(totalDebit),
              textDirection: .ltr,
              textAlign: TextAlign.center,
              style: style.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            TextWidget(
              alignment: Alignment.center,
              padding: Paddings.xsmallAll,
              text: AppMoneyFormatter.formatDouble(totalCredit),
              textDirection: .ltr,
              textAlign: TextAlign.center,
              style: style.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade900,
              ),
            ),
            TextWidget(
              text: AppMoneyFormatter.formatDouble(lastBalance),
              alignment: Alignment.center,
              padding: Paddings.xsmallAll,
              textDirection: .ltr,
              textAlign: TextAlign.center,
              style: style.copyWith(
                fontWeight: FontWeight.bold,
                color: lastBalance >= 0
                    ? Colors.green.shade900
                    : Colors.red.shade900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
