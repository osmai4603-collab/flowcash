import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/features/accounts/presentation/blocs/account_statement/account_statement_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/account_statement/account_statement_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/account_statement/account_statement_state.dart';

import 'dart:io';
import 'package:flowcash/core/enums/journal_status_enum.dart';
import 'package:flowcash/core/formatters/date_formatter.dart';
import 'package:flowcash/core/theme/styles.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class AccountStatementPage extends StatefulWidget {
  final SubAccountEntity? subAccount;

  const AccountStatementPage({super.key, this.subAccount});

  @override
  State<AccountStatementPage> createState() => _AccountStatementPageState();
}

class _AccountStatementPageState extends State<AccountStatementPage> {
  late AccountStatementBloc _bloc;

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  Map<int, TableColumnWidth> getWidths() {
    return {
      0: const FixedColumnWidth(35),
      1: FixedColumnWidth(isDesktop ? 100 : 77),
      2: const FlexColumnWidth(0.40),
      3: const FlexColumnWidth(0.20),
      4: const FlexColumnWidth(0.20),
      5: const FlexColumnWidth(0.20),
    };
  }

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.instance<AccountStatementBloc>();
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
                      if (widget.subAccount == null) {
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

                      return Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.surfaceContainerHighest,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Information Card
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer.withAlpha(40),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      fluent.Text(
                                        'كشف حساب: ${state.subAccount!.accountName}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      fluent.Text(
                                        'رقم الحساب: ${state.subAccount!.accountNumber} | النوع: ${state.subAccount!.subAccountType.name}',
                                        style: TextStyle(
                                          color: colors.onSurface.withAlpha(
                                            150,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      fluent.Text(
                                        'الرصيد الافتتاحي: ${state.openingBalance.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      fluent.Text(
                                        'العملة: ${widget.subAccount?.currencyId ?? "عملة غير محددة"}',
                                        style: TextStyle(
                                          color: colors.onSurface.withAlpha(
                                            150,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Ledger Headers
                            fluent.Table(
                              border: fluent.TableBorder.all(
                                width: 0.5,
                                color: colors.outline,
                              ),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              columnWidths: getWidths(),
                              children: [
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: fluent.Text(
                                        'No',
                                        textAlign: TextAlign.center,
                                        style: colors.bodyStrong.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: fluent.Text(
                                        'التاريخ',
                                        textAlign: TextAlign.center,
                                        style: colors.bodyStrong.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: fluent.Text(
                                        'البيان التفصيلي',
                                        textAlign: TextAlign.center,
                                        style: colors.bodyStrong.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: fluent.Text(
                                        widget
                                                .subAccount
                                                ?.subAccountType
                                                .mainAccountType
                                                .incrementName ??
                                            'مدين',
                                        style: colors.bodyStrong.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: fluent.Text(
                                        widget
                                                .subAccount
                                                ?.subAccountType
                                                .mainAccountType
                                                .decrementName ??
                                            'دائن',
                                        style: colors.bodyStrong.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade900,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: fluent.Text(
                                        'الرصيد',
                                        textAlign: TextAlign.center,
                                        style: colors.bodyStrong.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Expanded(child: buildListView(context, state)),
                          ],
                        ),
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

  Widget buildListView(BuildContext context, AccountStatementState state) {
    final colors = AppStyle.of(context);
    if (state.items.isEmpty) {
      return Center(
        child: fluent.Text(
          'لا توجد معاملات مسجلة في هذه الفترة',
          style: colors.bodyLarge,
        ),
      );
    }
    final length = state.items.length;
    final style = colors.bodyStrong;

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
      final amount = item.amount;
      if (item.journalStatus == JournalStatus.increment) {
        totalDebit += amount;
      } else {
        totalCredit += amount;
      }
    }

    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (_, index) {
        final item = state.items[index];
        final entry = state.entries[item.entryId];
        if (index + 1 == length) {
          return Column(
            children: [
              buildInkWell(index, item, entry, balances[index], context),
              fluent.GestureDetector(
                onTap: () {},
                child: fluent.Table(
                  border: fluent.TableBorder.all(
                    width: 0.5,
                    color: colors.outline,
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: getWidths(),
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
                          textDirection: TextDirection.ltr,
                          
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
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                        TextWidget(
                          text: AppMoneyFormatter.formatDouble(balances[index]),
                        alignment: Alignment.center,
                        padding: Paddings.xsmallAll,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                            fontWeight: FontWeight.bold,
                            color: balances[index] >= 0
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return buildInkWell(index, item, entry, balances[index], context);
      },
    );
  }

  Widget buildInkWell(
    int index,
    JournalItemEntity item,
    JournalEntryEntity? entry,
    double balance,
    BuildContext context,
  ) {
    final colors = AppStyle.of(context);
    final style = colors.bodyStrong;
    return GestureDetector(
      onTap: () {},
      child: ColoredBox(
        color: index % 2 == 0
            ? Colors.transparent
            : colors.surfaceContainerHighest,
        child: fluent.Table(
          border: fluent.TableBorder.all(width: 0.5, color: colors.outline),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: getWidths(),
          children: [
            TableRow(
              children: [
                fluent.Text(
                  '${index + 1}',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: style,
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: fluent.Text(
                    AppDateFormatter.toDateString(
                      entry?.createdAt ?? DateTime.now(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: fluent.Text(
                    item.lineDescription ?? entry?.description ?? '',
                    style: style,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                item.journalStatus == JournalStatus.increment
                    ? TextWidget(
                        text: AppMoneyFormatter.formatDouble(item.amount),
                        alignment: Alignment.centerRight,
                        padding: Paddings.xsmallAll,
                        style: style.copyWith(
                          color: Colors.green.shade900
                        ),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox(height: 1),
                item.journalStatus == JournalStatus.decrement
                    ? TextWidget(
                        text: AppMoneyFormatter.formatDouble(item.amount),
                        alignment: Alignment.centerRight,
                        padding: Paddings.xsmallAll,
                        style: style.copyWith(
                          color: Colors.red.shade900
                        ),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox(height: 1),
                TextWidget(
                  text: AppMoneyFormatter.formatDouble(balance),
                  alignment: Alignment.centerRight,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.end,
                  style: style.copyWith(
                    fontWeight: FontWeight.bold,
                    color: balance >= 0
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                  ),
                  padding: Paddings.xsmallAll,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
