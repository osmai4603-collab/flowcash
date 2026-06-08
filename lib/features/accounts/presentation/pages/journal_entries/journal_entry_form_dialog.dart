import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';

// Entities
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/features/accounts/domain/repositories/sub_account_repository.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';

// Bloc
import 'package:flowcash/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_state.dart';

// Widgets
import 'package:flowcash/features/accounts/presentation/widgets/journal_item_row_form.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class JournalEntryFormDialog extends StatefulWidget {
  final JournalEntryEntity? entry;

  const JournalEntryFormDialog({super.key, this.entry});

  @override
  State<JournalEntryFormDialog> createState() => _JournalEntryFormDialogState();
}

class _JournalEntryFormDialogState extends State<JournalEntryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
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
    super.dispose();
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
          debugPrint(
            'Form status changed: ${state.status}, error: ${state.errorMessage}',
          );
          if (state.status == JournalEntryFormStatus.success) {
            Navigator.of(context).pop(true);
          }
          if (state.errorMessage != null &&
              state.errorMessage!.isNotEmpty &&
              state.status == JournalEntryFormStatus.failure) {
            fluent.displayInfoBar(
              context,
              builder: (context, close) => fluent.InfoBar(
                title: const fluent.Text('تنبيه'),
                content: fluent.Text(state.errorMessage!),
              ),
            );
          }
          if (state.editingEntry != null && _descController.text.isEmpty) {
            _descController.text = state.description;
          }
        },
        builder: (context, state) {
          final bloc = context.read<JournalEntryFormBloc>();
          final isEditing = state.editingEntry != null;
          final CurrencyEntity? selectedCurrency = state.currencySelected;

          if (state.status == JournalEntryFormStatus.loading &&
              state.editingEntry != null &&
              state.items.isEmpty) {
            return Material(
              type: MaterialType.transparency,
              child: fluent.ContentDialog(
                title: Row(
                  children: [
                    fluent.Icon(
                      isEditing
                          ? fluent.FluentIcons.edit_note
                          : fluent.FluentIcons.task_add,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    fluent.Text(
                      isEditing ? 'جاري تحميل القيد' : 'جاري إعداد القيد',
                    ),
                  ],
                ),
                content: JournalEntryFormShimmer(),
                actions: [
                  fluent.Button(
                    onPressed: null,
                    child: const fluent.Text('إلغاء'),
                  ),
                  fluent.FilledButton(
                    onPressed: null,
                    child: const SizedBox(
                      height: 20,
                      width: 20,
                      child: fluent.ProgressRing(
                        strokeWidth: 2,
                        activeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ShimmerLoadingWidget(
            canShimmer: state.status == JournalEntryFormStatus.loading,
            freezeScreen: state.status == JournalEntryFormStatus.loading,
            period: const Duration(milliseconds: 900),
            child: fluent.ContentDialog(
              constraints: BoxConstraints(maxWidth: 800, minWidth: 800),
              title: Row(
                children: [
                  fluent.Icon(
                    isEditing
                        ? fluent.FluentIcons.edit_note
                        : fluent.FluentIcons.task_add,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  fluent.Text(
                    isEditing ? 'تعديل قيد يومية' : 'إنشاء قيد يومية جديد',
                  ),
                ],
              ),
              content: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    // 1. Header inputs (Description, Date, Currency, Exchange Rate)
                    _buildJournalEntryHeader(
                      bloc,
                      state,
                      context,
                      selectedCurrency,
                    ),
                    const SizedBox(height: 20),

                    // Debit Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(40),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const fluent.Text(
                            'المدينون',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          fluent.FilledButton(
                            onPressed: () => bloc.add(
                              const AddJournalItemField(JournalItemSide.debit),
                            ),
                            child: const fluent.Text('إضافة بند مدين'),
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
                                      (it) => it.side == JournalItemSide.debit,
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
                                  const fluent.Text(
                                    'الدائنون',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  fluent.FilledButton(
                                    onPressed: () => bloc.add(
                                      const AddJournalItemField(
                                        JournalItemSide.credit,
                                      ),
                                    ),
                                    // icon: const fluent.Icon(fluent.FluentIcons.add,
                                    // ),
                                    child: const fluent.Text('إضافة بند دائن'),
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
                                      (it) => it.side == JournalItemSide.credit,
                                    )
                                    .toList();
                                return Column(
                                  children: List.generate(creditItems.length, (
                                    sideIdx,
                                  ) {
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
                                                side: JournalItemSide.credit,
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
                                  }),
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
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Balanced indicator status
                          Row(
                            children: [
                              fluent.Icon(
                                state.isBalanced
                                    ? fluent.FluentIcons.skype_circle_check
                                    : fluent.FluentIcons.warning,
                                color: state.isBalanced
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              fluent.Text(
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
                              fluent.Text(
                                'إجمالي المدين: ${state.totalDebit.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 24),
                              fluent.Text(
                                'إجمالي الدائن: ${state.totalCredit.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              if (!state.isBalanced) ...[
                                const SizedBox(width: 24),
                                fluent.Text(
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
                fluent.Button(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const fluent.Text('إلغاء'),
                ),
                fluent.FilledButton(
                  onPressed:
                      state.status == JournalEntryFormStatus.loading ||
                          !state.isBalanced
                      ? null
                      : () {
                          final isValid =
                              _formKey.currentState?.validate() ?? true;
                          if (!isValid) return;
                          bloc.add(const SubmitJournalEntryForm());
                        },
                  child: state.status == JournalEntryFormStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: fluent.ProgressRing(
                            strokeWidth: 2,
                            activeColor: Colors.white,
                          ),
                        )
                      : const fluent.Text('حفظ القيد'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Row _buildJournalEntryHeader(
    JournalEntryFormBloc bloc,
    JournalEntryFormState state,
    BuildContext context,
    CurrencyEntity? selectedCurrency,
  ) {
    return Row(
      children: [
        // Description
        Expanded(
          flex: 3,
          child: fluent.InfoLabel(
            label: 'البيان العام للقيد',
            child: fluent.TextFormBox(
              controller: _descController,
              placeholder: 'البيان العام للقيد',
              prefix: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: fluent.Icon(fluent.FluentIcons.note_pinned),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'البيان العام للقيد مطلوب'
                  : null,
              onChanged: (val) => bloc.add(JournalEntryDescriptionChanged(val)),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Date Picker
        Expanded(
          flex: 2,
          child: fluent.InfoLabel(
            label: 'التاريخ',
            child: FormField<DateTime>(
              initialValue: state.date,
              validator: (value) => value == null ? 'التاريخ مطلوب' : null,
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fluent.DatePicker(
                      contentPadding: EdgeInsets.all(5.5),
                      selected: state.date,
                      onChanged: (val) {
                        field.didChange(val);
                        context.read<JournalEntryFormBloc>().add(
                          JournalEntryDateChanged(val),
                        );
                      },
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 8.0),
                        child: fluent.Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            // child: fluent.Row(
            //   mainAxisAlignment:
            //       MainAxisAlignment.spaceBetween,
            //   children: [
            //     fluent.Text(
            //       formattedDate,
            //       style: const TextStyle(
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //     const fluent.Icon(
            //       fluent.FluentIcons.calendar_settings,
            //     ),
            //   ],
            // ),
          ),
        ),
        const SizedBox(width: 12),

        // Currency
        Expanded(
          flex: 2,
          child: fluent.InfoLabel(
            label: 'العملة',
            child: state.isLoadingCurrencies
                ? fluent.Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        fluent.ProgressRing(
                          strokeWidth: 2,
                          activeColor: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        fluent.Text('جاري تحميل العملات...'),
                      ],
                    ),
                  )
                : state.currencies.isEmpty
                ? fluent.Text('لا توجد عملات متاحة')
                : FormField<String>(
                    initialValue: state.currencySelected?.id,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'العملة مطلوبة' : null,
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          fluent.ComboBox<CurrencyEntity>(
                            value: selectedCurrency,
                            placeholder: const fluent.Text('اختر العملة'),
                            isExpanded: true,
                            icon: const fluent.Icon(fluent.FluentIcons.money),
                            items: state.currencies
                                .map(
                                  (
                                    currency,
                                  ) => fluent.ComboBoxItem<CurrencyEntity>(
                                    value: currency,
                                    child: fluent.Text(
                                      '${currency.name} (${currency.symbol})',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (currency) {
                              if (currency != null) {
                                field.didChange(currency.id);
                                bloc.add(
                                  JournalEntryCurrencyChanged(currency, 1.0),
                                );
                              }
                            },
                          ),
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 6.0,
                                left: 8.0,
                              ),
                              child: fluent.Text(
                                field.errorText!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class JournalEntryFormShimmer extends StatelessWidget {
  const JournalEntryFormShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
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
    );
  }
}
