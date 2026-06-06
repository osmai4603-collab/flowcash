import 'package:flowcash/features/accounts/presentation/pages/accounts_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/sub_account_repository.dart';
import 'package:flowcash/features/accounts/presentation/blocs/account_statement/account_statement_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/account_statement/account_statement_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/account_statement/account_statement_state.dart';

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
    final result = await GetIt.instance<SubAccountRepository>().getSubAccountsSimple(query: '');
    result.fold(
      (_) {},
      (list) {
        if (mounted) {
          setState(() {
            _subAccountsList = list;
            if (_pendingSubAccountId != null) {
              _selectAndFetchAccount(_pendingSubAccountId!);
              _pendingSubAccountId = null;
            }
          });
        }
      },
    );
  }

  void _selectAndFetchAccount(int subAccountId) {
    final account = _subAccountsList.firstWhere(
      (acc) => acc.id == subAccountId,
      orElse: () => null as dynamic,
    );
    if (account != null) {
      setState(() {
        _selectedAccount = account;
        if (_autocompleteController != null) {
          _autocompleteController!.text = '${account.accountNumber} - ${account.accountName}';
        }
      });
      _bloc.add(LoadAccountStatement(
        subAccountId: subAccountId,
        startDate: _startDate,
        endDate: _endDate,
      ));
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
                            return _subAccountsList.where((acc) =>
                                acc.accountName.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                acc.accountNumber.contains(textEditingValue.text));
                          },
                          displayStringForOption: (option) => '${option.accountNumber} - ${option.accountName}',
                          onSelected: (option) {
                            setState(() {
                              _selectedAccount = option;
                            });
                          },
                          fieldViewBuilder: (context, fieldTextEditingController, focusNode, onFieldSubmitted) {
                            _autocompleteController = fieldTextEditingController;
                            if (_selectedAccount != null && fieldTextEditingController.text.isEmpty) {
                              fieldTextEditingController.text = '${_selectedAccount!.accountNumber} - ${_selectedAccount!.accountName}';
                            }
                            return TextField(
                              controller: fieldTextEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'اختر الحساب الفرعي',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(fluent.FluentIcons.personalize),
                                suffixIcon: _selectedAccount != null
                                    ? IconButton(
                                        icon: const Icon(fluent.FluentIcons.clear),
                                        onPressed: () {
                                          fieldTextEditingController.clear();
                                          setState(() {
                                            _selectedAccount = null;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Start Date
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'من تاريخ',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(fluent.FluentIcons.calendar_settings),
                              suffixIcon: _startDate != null
                                  ? IconButton(
                                      icon: const Icon(fluent.FluentIcons.clear, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _startDate = null;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            child: fluent.Text(
                              _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'الكل',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // End Date
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'إلى تاريخ',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(fluent.FluentIcons.calendar_settings),
                              suffixIcon: _endDate != null
                                  ? IconButton(
                                      icon: const Icon(fluent.FluentIcons.clear, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _endDate = null;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            child: fluent.Text(
                              _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'الكل',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Submit Button
                      ElevatedButton.icon(
                        onPressed: _selectedAccount == null
                            ? null
                            : () {
                                _bloc.add(LoadAccountStatement(
                                      subAccountId: _selectedAccount!.id,
                                      startDate: _startDate,
                                      endDate: _endDate,
                                    ));
                              },
                        icon: const Icon(fluent.FluentIcons.receipt_processing),
                        label: const fluent.Text('عرض الكشف'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                              Icon(fluent.FluentIcons.search, size: 72, color: theme.colorScheme.onSurface.withAlpha(50)),
                              const SizedBox(height: 16),
                              fluent.Text(
                                'يرجى تحديد حساب فرعي وتاريخ ثم النقر على عرض الكشف',
                                style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withAlpha(150)),
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
                          child: fluent.Text('خطأ في تحميل كشف الحساب: ${state.errorMessage}',
                              style: const TextStyle(color: Colors.red, fontSize: 16)),
                        );
                      }

                      // Compute summaries
                      double totalDebit = 0.0;
                      double totalCredit = 0.0;
                      for (final item in state.items) {
                        totalDebit += item.debit;
                        totalCredit += item.credit;
                      }

                      double runningBalance = state.openingBalance;

                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor.withAlpha(50)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Information Card
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withAlpha(40),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      fluent.Text(
                                        'كشف حساب: ${state.subAccount!.accountName}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      fluent.Text(
                                        'رقم الحساب: ${state.subAccount!.accountNumber} | النوع: ${state.subAccount!.subAccountType.name}',
                                        style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      fluent.Text(
                                        'الرصيد الافتتاحي: ${state.openingBalance.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      fluent.Text(
                                        'العملة: ${_selectedAccount?.currencyName ?? "عملة غير محددة"}',
                                        style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Ledger Headers
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: theme.dividerColor.withAlpha(100))),
                                color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                              ),
                              child: Row(
                                children: const [
                                  Expanded(flex: 2, child: fluent.Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: fluent.Text('الرقم المرجعي', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 4, child: fluent.Text('البيان التفصيلي', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Expanded(flex: 2, child: fluent.Text('مدين (وارد)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                                  Expanded(flex: 2, child: fluent.Text('دائن (صادر)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                                  Expanded(flex: 2, child: fluent.Text('الرصيد التراكمي', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                                ],
                              ),
                            ),

                            // Ledger Scrollable Data Rows
                            Expanded(
                              child: state.items.isEmpty
                                  ? const Center(child: fluent.Text('لا توجد معاملات مسجلة في هذه الفترة'))
                                  : ListView.builder(
                                      itemCount: state.items.length,
                                      itemBuilder: (context, idx) {
                                        final item = state.items[idx];
                                        final entry = state.entries[item.entryId];
                                        final dateStr = entry != null
                                            ? DateFormat('yyyy-MM-dd').format(entry.createdAt)
                                            : '-';
                                        final refNum = entry?.referenceNumber ?? '-';

                                        // Update running balance
                                        runningBalance += (item.debit - item.credit);

                                        return Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                          decoration: BoxDecoration(
                                            border: Border(bottom: BorderSide(color: theme.dividerColor.withAlpha(30))),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(flex: 2, child: fluent.Text(dateStr)),
                                              Expanded(flex: 2, child: fluent.Text(refNum, style: const TextStyle(fontFamily: 'monospace'))),
                                              Expanded(flex: 4, child: fluent.Text(item.lineDescription ?? entry?.description ?? '')),
                                              Expanded(
                                                flex: 2,
                                                child: fluent.Text(
                                                  item.debit > 0 ? item.debit.toStringAsFixed(2) : '-',
                                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                                                  textAlign: TextAlign.end,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: fluent.Text(
                                                  item.credit > 0 ? item.credit.toStringAsFixed(2) : '-',
                                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                                  textAlign: TextAlign.end,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: fluent.Text(
                                                  runningBalance.toStringAsFixed(2),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: runningBalance >= 0 ? Colors.green : Colors.red,
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

                            // Total Summary Footer Row
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant.withAlpha(50),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                                border: Border(top: BorderSide(color: theme.dividerColor.withAlpha(100))),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  fluent.Text(
                                    'إجمالي الفترة:  مدين: ${totalDebit.toStringAsFixed(2)}  |  دائن: ${totalCredit.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  fluent.Text(
                                    'الرصيد الختامي: ${runningBalance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: runningBalance >= 0 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}
