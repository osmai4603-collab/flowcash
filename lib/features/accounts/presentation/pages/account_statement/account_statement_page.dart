import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/features/accounts/presentation/pages/accounts_dashboard.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/sub_account_repository.dart';
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
  const AccountStatementPage({super.key});

  @override
  State<AccountStatementPage> createState() => _AccountStatementPageState();
}

class _AccountStatementPageState extends State<AccountStatementPage> {
  late AccountStatementBloc _bloc;
  SubAccountSimpleEntity? _selectedAccount;
  DateTime? _startDate;
  DateTime? _endDate;
  List<SubAccountSimpleEntity> _subAccountsList = [];
  final _searchController = TextEditingController();
  TextEditingController? _autocompleteController;
  int? _pendingSubAccountId;

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
    _loadSubAccounts();
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubAccounts() async {
    final result = await GetIt.instance<SubAccountRepository>()
        .getSubAccountsSimple(query: '');
    result.fold((_) {}, (list) {
      if (mounted) {
        setState(() {
          _subAccountsList = list;
          if (_pendingSubAccountId != null) {
            _selectAndFetchAccount(_pendingSubAccountId!);
            _pendingSubAccountId = null;
          }
        });
      }
    });
  }

  void _selectAndFetchAccount(int subAccountId) {
    SubAccountSimpleEntity? account;
    try {
      account = _subAccountsList.firstWhere((acc) => acc.id == subAccountId);
    } catch (_) {
      account = null;
    }

    if (account != null) {
      final selectedAccount = account;
      setState(() {
        _selectedAccount = selectedAccount;
        if (_autocompleteController != null) {
          _autocompleteController!.text =
              '${selectedAccount.accountNumber} - ${selectedAccount.accountName}';
        }
      });
      _bloc.add(
        LoadAccountStatement(
          subAccountId: subAccountId,
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final notifier = Provider.of<AccountsTabNotifier>(context, listen: true);
      if (notifier.selectedSubAccountId != null) {
        final subAccountId = notifier.selectedSubAccountId!;
        notifier.clearSelectedSubAccountId();

        if (_subAccountsList.isNotEmpty) {
          _selectAndFetchAccount(subAccountId);
        } else {
          _pendingSubAccountId = subAccountId;
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Filter Bar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      // Sub-account Selector (Autocomplete)
                      Expanded(
                        flex: 3,
                        child: Autocomplete<SubAccountSimpleEntity>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _subAccountsList;
                            }
                            return _subAccountsList.where(
                              (acc) =>
                                  acc.accountName.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ) ||
                                  acc.accountNumber.contains(
                                    textEditingValue.text,
                                  ),
                            );
                          },
                          displayStringForOption: (option) =>
                              '${option.accountNumber} - ${option.accountName}',
                          onSelected: (option) {
                            setState(() {
                              _selectedAccount = option;
                            });
                          },
                          fieldViewBuilder:
                              (
                                context,
                                fieldTextEditingController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                _autocompleteController =
                                    fieldTextEditingController;
                                if (_selectedAccount != null &&
                                    fieldTextEditingController.text.isEmpty) {
                                  fieldTextEditingController.text =
                                      '${_selectedAccount!.accountNumber} - ${_selectedAccount!.accountName}';
                                }
                                return fluent.TextBox(
                                  controller: fieldTextEditingController,
                                  focusNode: focusNode,
                                  placeholder: 'اختر الحساب الفرعي',
                                  prefix: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: fluent.Icon(
                                      fluent.FluentIcons.personalize,
                                    ),
                                  ),
                                  suffix: _selectedAccount != null
                                      ? fluent.IconButton(
                                          icon: const fluent.Icon(
                                            fluent.FluentIcons.clear,
                                          ),
                                          onPressed: () {
                                            fieldTextEditingController.clear();
                                            setState(() {
                                              _selectedAccount = null;
                                            });
                                          },
                                        )
                                      : null,
                                  onSubmitted: (_) => onFieldSubmitted(),
                                );
                              },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Start Date
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6.0),
                              child: fluent.Text('من تاريخ'),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: fluent.DatePicker(
                                    selected: _startDate,
                                    onChanged: (value) {
                                      setState(() {
                                        _startDate = value;
                                      });
                                    },
                                    startDate: DateTime(2020),
                                    endDate: DateTime(2030),
                                  ),
                                ),
                                if (_startDate != null) ...[
                                  const SizedBox(width: 6),
                                  fluent.IconButton(
                                    icon: const fluent.Icon(
                                      fluent.FluentIcons.clear,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _startDate = null;
                                      });
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // End Date
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6.0),
                              child: fluent.Text('إلى تاريخ'),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: fluent.DatePicker(
                                    selected: _endDate,
                                    onChanged: (value) {
                                      setState(() {
                                        _endDate = value;
                                      });
                                    },
                                    startDate: DateTime(2020),
                                    endDate: DateTime(2030),
                                  ),
                                ),
                                if (_endDate != null) ...[
                                  const SizedBox(width: 6),
                                  fluent.IconButton(
                                    icon: const fluent.Icon(
                                      fluent.FluentIcons.clear,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _endDate = null;
                                      });
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Submit Button
                      fluent.FilledButton(
                        onPressed: _selectedAccount == null
                            ? null
                            : () {
                                _bloc.add(
                                  LoadAccountStatement(
                                    subAccountId: _selectedAccount!.id,
                                    startDate: _startDate,
                                    endDate: _endDate,
                                  ),
                                );
                              },
                        child: Row(
                          spacing: Spacings.xsmall,
                          children: [
                            const fluent.Icon(
                              fluent.FluentIcons.receipt_processing,
                            ),
                            const fluent.Text('عرض الكشف'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Main Statement Content
                Expanded(
                  child: BlocBuilder<AccountStatementBloc, AccountStatementState>(
                    builder: (context, state) {
                      if (state.status == AccountStatementStatus.initial) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              fluent.Icon(
                                fluent.FluentIcons.search,
                                size: 72,
                                color: theme.colorScheme.onSurface.withAlpha(
                                  50,
                                ),
                              ),
                              const SizedBox(height: 16),
                              fluent.Text(
                                'يرجى تحديد حساب فرعي وتاريخ ثم النقر على عرض الكشف',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    150,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
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

                      // Compute summaries
                      double totalDebit = 0.0;
                      double totalCredit = 0.0;
                      for (final item in state.items) {
                        final amount = item.debit > 0
                            ? item.debit
                            : item.credit;
                        if (item.journalStatus == JournalStatus.debit) {
                          totalDebit += amount;
                        } else {
                          totalCredit += amount;
                        }
                      }

                      double runningBalance = state.openingBalance;

                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.dividerColor.withAlpha(50),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Information Card
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withAlpha(40),
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
                                          color: theme.colorScheme.onSurface
                                              .withAlpha(150),
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
                                        'العملة: ${_selectedAccount?.currencyName ?? "عملة غير محددة"}',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface
                                              .withAlpha(150),
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
                                color: theme.colorScheme.outline,
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
                                        style: Styles.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: fluent.Text(
                                        'التاريخ',
                                        textAlign: TextAlign.center,
                                        style: Styles.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: fluent.Text(
                                        'البيان التفصيلي',
                                        textAlign: TextAlign.center,
                                        style: Styles.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: fluent.Text(
                                        'مدين (وارد)',
                                        style: Styles.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: fluent.Text(
                                        'دائن (صادر)',
                                        style: Styles.bodySmall.copyWith(
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
                                        style: Styles.bodySmall.copyWith(
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
    if (state.items.isEmpty) {
      return Center(
        child: fluent.Text(
          'لا توجد معاملات مسجلة في هذه الفترة',
          style: Styles.bodyLarge,
        ),
      );
    }
    final length = state.items.length;
    final style = Styles.bodySmall;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Pre-compute the list of balances for running balance:
    final balances = <double>[];
    double balanceTemp = state.openingBalance;
    for (final item in state.items) {
      final amount = item.debit > 0 ? item.debit : item.credit;
      final displayedDebit = item.journalStatus == JournalStatus.debit
          ? amount
          : 0.0;
      final displayedCredit = item.journalStatus == JournalStatus.credit
          ? amount
          : 0.0;
      balanceTemp += (displayedDebit - displayedCredit);
      balances.add(balanceTemp);
    }

    // Compute totals for the summary row:
    double totalDebit = 0.0;
    double totalCredit = 0.0;
    for (final item in state.items) {
      final amount = item.debit > 0 ? item.debit : item.credit;
      if (item.journalStatus == JournalStatus.debit) {
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
              InkWell(
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
                          text: totalDebit.toStringAsFixed(2),
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        TextWidget(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          text: totalCredit.toStringAsFixed(2),
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                        TextWidget(
                          text: balances[index].toStringAsFixed(2),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = Styles.bodySmall;
    final amount = item.debit > 0 ? item.debit : item.credit;

    final dateStr = entry != null
        ? AppDateFormatter.convertDateTimeToString(entry.createdAt)
        : '-';
    final dayName = entry != null
        ? AppDateFormatter.weekNameInFullArabic[entry.createdAt.weekday] ?? ''
        : '';

    return InkWell(
      onTap: () {},
      child: ColoredBox(
        color: index % 2 == 0
            ? Colors.transparent
            : colors.tertiary.withAlpha(20),
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
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      fluent.Text(dayName, style: style),
                      fluent.Text(dateStr, style: style),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: fluent.Text(
                    item.lineDescription ?? entry?.description ?? '',
                    style: style,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                item.journalStatus == JournalStatus.debit
                    ? TextWidget(
                        text: amount.toStringAsFixed(2),
                        style: style.copyWith(
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox(height: 1),
                item.journalStatus == JournalStatus.credit
                    ? TextWidget(
                        text: amount.toStringAsFixed(2),
                        style: style.copyWith(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox(height: 1),
                TextWidget(
                  text: balance.toStringAsFixed(2),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.end,
                  style: style.copyWith(
                    fontWeight: FontWeight.bold,
                    color: balance >= 0
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
