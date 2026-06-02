import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';

// Entities
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/sub_account_repository.dart';

// Bloc
import 'package:flowcash/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_state.dart';

// Widgets
import 'package:flowcash/features/accounts/presentation/widgets/journal_item_row_form.dart';

class JournalEntryFormDialog extends StatefulWidget {
  final JournalEntryEntity? entry;

  const JournalEntryFormDialog({super.key, this.entry});

  @override
  State<JournalEntryFormDialog> createState() => _JournalEntryFormDialogState();
}

class _JournalEntryFormDialogState extends State<JournalEntryFormDialog> {
  final _descController = TextEditingController();
  final _exPriceController = TextEditingController(text: '1.0');
  List<SubAccountSimpleEntity> _subAccounts = [];

  @override
  void initState() {
    super.initState();
    // Load sub-accounts for autocomplete search
    GetIt.instance<SubAccountRepository>().getSubAccountsSimple(query: '').then(
      (res) {
        res.fold((_) {}, (list) {
          if (mounted) {
            setState(() {
              _subAccounts = list;
            });
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _exPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    JournalEntryFormBloc bloc,
    DateTime currentDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != currentDate) {
      bloc.add(JournalEntryDateChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) =>
          GetIt.instance<JournalEntryFormBloc>()
            ..add(InitJournalEntryForm(editingEntry: widget.entry)),
      child: BlocConsumer<JournalEntryFormBloc, JournalEntryFormState>(
        listener: (context, state) {
          debugPrint('Form status changed: ${state.status}, error: ${state.errorMessage}');
          if (state.status == JournalEntryFormStatus.success) {
            Navigator.of(context).pop(true);
          }
          if (state.errorMessage != null &&
              state.errorMessage!.isNotEmpty && state.status == JournalEntryFormStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.editingEntry != null && _descController.text.isEmpty) {
            _descController.text = state.description;
            _exPriceController.text = state.exPrice.toString();
          }
        },
        builder: (context, state) {
          final bloc = context.read<JournalEntryFormBloc>();
          final isEditing = state.editingEntry != null;
          final formattedDate = DateFormat('yyyy-MM-dd').format(state.date);

          if (state.status == JournalEntryFormStatus.loading &&
              state.editingEntry != null &&
              state.items.isEmpty) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note : Icons.add_task,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? 'جاري تحميل القيد' : 'جاري إعداد القيد',
                  ),
                ],
              ),
              content: AppShimmer(
                child: SizedBox(
                  width: 800,
                  height: 380,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      ShimmerPlaceholder(height: 48),
                      SizedBox(height: 16),
                      ShimmerPlaceholder(height: 48),
                      SizedBox(height: 16),
                      ShimmerPlaceholder(height: 48),
                      SizedBox(height: 16),
                      ShimmerPlaceholder(height: 140),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: null, child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: null,
                  child: const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          }

          return ShimmerLoadingWidget(
            canShimmer: state.status == JournalEntryFormStatus.loading,
            freezeScreen: state.status == JournalEntryFormStatus.loading,
            period: const Duration(milliseconds: 900),
            child: AlertDialog(
            title: Row(
              children: [
                Icon(
                  isEditing ? Icons.edit_note : Icons.add_task,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  isEditing ? 'تعديل قيد يومية' : 'إنشاء قيد يومية جديد',
                ),
              ],
            ),
            content: SizedBox(
              width: 800,
              height: 550,
              child: Column(
                children: [
                  // 1. Header inputs (Description, Date, Currency, Exchange Rate)
                  Row(
                    children: [
                      // Description
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            labelText: 'البيان العام للقيد',
                            
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          onChanged: (val) =>
                              bloc.add(JournalEntryDescriptionChanged(val)),
                        ),
                      ),
                      const SizedBox(width: 12),
      
                      // Date Picker
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () =>
                              _selectDate(context, bloc, state.date),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'التاريخ',
                              
                              prefixIcon: Icon(
                                Icons.calendar_month_outlined,
                              ),
                            ),
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
      
                      // Currency
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: state.currencyId,
                          decoration: const InputDecoration(
                            labelText: 'العملة',
                            
                            prefixIcon: Icon(Icons.monetization_on_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '1',
                              child: Text('ريال يمني'),
                            ),
                            DropdownMenuItem(
                              value: '2',
                              child: Text('ريال سعودي'),
                            ),
                            DropdownMenuItem(
                              value: '3',
                              child: Text('دولار أمريكي'),
                            ),
                          ],
                          onChanged: (currId) {
                            if (currId != null) {
                              final rate = currId == '1'
                                  ? 1.0
                                  : (currId == '2' ? 150.0 : 600.0);
                              _exPriceController.text = rate.toString();
                              bloc.add(
                                JournalEntryCurrencyChanged(currId, rate),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
      
                      // Exchange Price
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _exPriceController,
                          enabled: state.currencyId != '1',
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                          decoration: const InputDecoration(
                            labelText: 'سعر الصرف',
                            
                            prefixIcon: Icon(Icons.attach_money_outlined),
                          ),
                          onChanged: (val) {
                            final rate = double.tryParse(val) ?? 1.0;
                            bloc.add(
                              JournalEntryCurrencyChanged(
                                state.currencyId,
                                rate,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
      
                  // Debit Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(
                        40,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المدينون',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () => bloc.add(
                            const AddJournalItemField(
                              JournalItemSide.debit,
                            ),
                          ),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('إضافة بند مدين'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
      
                  // Items grouped by side
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Debit items list
                          Builder(
                            builder: (ctx) {
                              final debitItems = state.items
                                  .where(
                                    (it) =>
                                        it.side == JournalItemSide.debit,
                                  )
                                  .toList();
                              return Column(
                                children: List.generate(debitItems.length, (
                                  sideIdx,
                                ) {
                                  final item = debitItems[sideIdx];
                                  return JournalItemRowForm(
                                    index: sideIdx,
                                    draft: item,
                                    side: JournalItemSide.debit,
                                    subAccounts: _subAccounts,
                                    canDelete: debitItems.length > 1,
                                    onChanged:
                                        ({
                                          accountId,
                                          accountName,
                                          debit,
                                          credit,
                                          lineDescription,
                                        }) {
                                          bloc.add(
                                            JournalItemFieldChanged(
                                              side: JournalItemSide.debit,
                                              index: sideIdx,
                                              accountId: accountId,
                                              accountName: accountName,
                                              debit: debit,
                                              lineDescription:
                                                  lineDescription,
                                            ),
                                          );
                                        },
                                    onDelete: () => bloc.add(
                                      RemoveJournalItemField(
                                        JournalItemSide.debit,
                                        sideIdx,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
      
                          const SizedBox(height: 12),
      
                          // Credit section header and add button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'الدائنون',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => bloc.add(
                                    const AddJournalItemField(
                                      JournalItemSide.credit,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                  ),
                                  label: const Text('إضافة بند دائن'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
      
                          // Credit items list
                          Builder(
                            builder: (ctx) {
                              final creditItems = state.items
                                  .where(
                                    (it) =>
                                        it.side == JournalItemSide.credit,
                                  )
                                  .toList();
                              return Column(
                                children: List.generate(
                                  creditItems.length,
                                  (sideIdx) {
                                    final item = creditItems[sideIdx];
                                    return JournalItemRowForm(
                                      index: sideIdx,
                                      draft: item,
                                      side: JournalItemSide.credit,
                                      subAccounts: _subAccounts,
                                      canDelete: creditItems.length > 1,
                                      onChanged:
                                          ({
                                            accountId,
                                            accountName,
                                            debit,
                                            credit,
                                            lineDescription,
                                          }) {
                                            bloc.add(
                                              JournalItemFieldChanged(
                                                side:
                                                    JournalItemSide.credit,
                                                index: sideIdx,
                                                accountId: accountId,
                                                accountName: accountName,
                                                credit: credit,
                                                lineDescription:
                                                    lineDescription,
                                              ),
                                            );
                                          },
                                      onDelete: () => bloc.add(
                                        RemoveJournalItemField(
                                          JournalItemSide.credit,
                                          sideIdx,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
      
                  // 3. Footer totals summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withAlpha(50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Balanced indicator status
                        Row(
                          children: [
                            Icon(
                              state.isBalanced
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: state.isBalanced
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.isBalanced
                                  ? 'القيد متزن'
                                  : 'القيد غير متزن',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: state.isBalanced
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
      
                        // Totals summary display
                        Row(
                          children: [
                            Text(
                              'إجمالي المدين: ${state.totalDebit.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Text(
                              'إجمالي الدائن: ${state.totalCredit.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            if (!state.isBalanced) ...[
                              const SizedBox(width: 24),
                              Text(
                                'الفرق: ${state.difference.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed:
                    state.status == JournalEntryFormStatus.loading ||
                        !state.isBalanced
                    ? null
                    : () => bloc.add(const SubmitJournalEntryForm()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: state.status == JournalEntryFormStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('حفظ القيد'),
              ),
            ],
            ),
          );
        },
      ),
    );
  }
}
