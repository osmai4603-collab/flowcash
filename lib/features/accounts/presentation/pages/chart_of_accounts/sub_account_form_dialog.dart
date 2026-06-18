import 'package:flowcash/core/theme/spacings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';

// Enums
import 'package:flowcash/core/enums/sub_account_type_enum.dart';

// Entities
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';

// Bloc
import 'package:flowcash/features/accounts/presentation/blocs/sub_account_form/sub_account_form_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/sub_account_form/sub_account_form_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/sub_account_form/sub_account_form_state.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class SubAccountFormDialog extends StatefulWidget {
  final int mainAccountId;
  final SubAccountEntity? subAccount;

  const SubAccountFormDialog({
    super.key,
    required this.mainAccountId,
    this.subAccount,
  });

  @override
  State<SubAccountFormDialog> createState() => _SubAccountFormDialogState();
}

class _SubAccountFormDialogState extends State<SubAccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxBalanceController = TextEditingController();

  void _onSaveButtonClicked(SubAccountFormBloc bloc) {
    if (_formKey.currentState?.validate() ?? false) {
      bloc.add(const SubmitSubAccountForm());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => GetIt.instance<SubAccountFormBloc>()
        ..add(
          InitSubAccountForm(
            mainAccountId: widget.mainAccountId,
            editingSubAccount: widget.subAccount,
          ),
        ),
      child: BlocConsumer<SubAccountFormBloc, SubAccountFormState>(
        listener: (context, state) {
          if (state.status == SubAccountFormStatus.success) {
            Navigator.of(context).pop(true);
          }
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            fluent.displayInfoBar(
              context,
              builder: (context, close) => fluent.InfoBar(
                title: const fluent.Text('تنبيه'),
                content: fluent.Text(state.errorMessage!),
              ),
            );
          }
          if (state.currencyErrorMessage != null &&
              state.currencyErrorMessage!.isNotEmpty) {
            fluent.displayInfoBar(
              context,
              builder: (context, close) => fluent.InfoBar(
                title: const fluent.Text('خطأ في العملات'),
                content: fluent.Text(state.currencyErrorMessage!),
              ),
            );
          }
          if (state.editingSubAccount != null && _nameController.text.isEmpty) {
            _nameController.text = state.accountName;
            if (state.balanceMax != null) {
              _maxBalanceController.text = state.balanceMax.toString();
            }
          }
        },
        builder: (context, state) {
          final bloc = context.read<SubAccountFormBloc>();
          final isEditing = state.editingSubAccount != null;

          // if (state.status == SubAccountFormStatus.loading &&
          //     state.parentMainAccount == null) {
          //   return _SubaccountShimmer();
          // }

          return fluent.ContentDialog(
            title: Row(
              children: [
                fluent.Icon(
                  isEditing ? Icons.edit : Icons.add,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                fluent.Text(
                  isEditing ? 'تعديل حساب فرعي' : 'إضافة حساب فرعي جديد',
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 450,
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: Spacings.small,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Parent Main Account Name (Read Only)
                      if (state.parentMainAccount != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withAlpha(
                              100,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: fluent.Text(
                            'الحساب الرئيسي: ${state.parentMainAccount!.accountName} (${state.parentMainAccount!.accountNumber})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                      // Account Name
                      fluent.InfoLabel(
                        label: 'اسم الحساب الفرعي',
                        child: fluent.TextFormBox(
                          textInputAction: fluent.TextInputAction.send,
                          autofocus: widget.subAccount == null,
                          placeholder: 'ادخل اسم الحساب الفرعي',
                          controller: _nameController,
                          // prefix: const Padding(
                          //   padding: EdgeInsets.all(8.0),
                          //   child: fluent.Icon(fluent.FluentIcons.info),
                          // ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الرجاء إدخال اسم الحساب الفرعي';
                            }
                            return null;
                          },
                          onEditingComplete: () => _onSaveButtonClicked(bloc),
                          onChanged: (val) =>
                              bloc.add(SubAccountNameChanged(val)),
                        ),
                      ),

                      Row(
                        spacing: Spacings.medium,
                        children: [
                          Expanded(
                            child: fluent.InfoLabel(
                              label: 'نوع الحساب الفرعي',
                              child: fluent.ComboboxFormField<SubAccountType>(
                                key: ValueKey(state.selectedType),
                                items: state.subAccountTypes
                                    .map(
                                      (type) =>
                                          fluent.ComboBoxItem<SubAccountType>(
                                            value: type,
                                            child: fluent.Text(
                                              type.displayName(),
                                            ),
                                          ),
                                    )
                                    .toList(),
                                value: state.selectedType,
                                placeholder: const fluent.Text(
                                  'اختر نوع الحساب الفرعي',
                                ),
                                isExpanded: true,
                                validator: (value) {
                                  if (value == null) {
                                    return 'الرجاء اختيار نوع الحساب الفرعي';
                                  }
                                  return null;
                                },
                                onChanged: (type) {
                                  if (type != null) {
                                    bloc.add(SubAccountTypeChanged(type));
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: fluent.InfoLabel(
                              label: 'العملة',
                              child: fluent.ComboBox<CurrencyEntity>(
                                value: state.selectedCurrency,
                                placeholder: const fluent.Text('اختر العملة'),
                                disabledPlaceholder: const fluent.Text(
                                  'لا توجد عملات متاحة',
                                ),
                                isExpanded: true,
                                icon: const fluent.Icon(
                                  fluent.FluentIcons.chevron_down,
                                ),
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
                                    bloc.add(
                                      SubAccountCurrencyChanged(currency),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      fluent.InfoLabel(
                        label: 'الحد الأقصى للرصيد (اختياري)',
                        child: fluent.TextFormBox(
                          placeholder:
                              'ادخل الحد الأقصى للرصيد لهذا الحساب الفرعي',
                          controller: _maxBalanceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textDirection: TextDirection.ltr,
                          // prefix: const Padding(
                          //   padding: EdgeInsets.all(8.0),
                          //   child: fluent.Icon(fluent.FluentIcons.maximum_value),
                          // ),
                          onChanged: (val) {
                            final numVal = double.tryParse(val);
                            bloc.add(SubAccountBalanceMaxChanged(numVal));
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Auto-generated Account Number Info
                      if (state.accountNumber.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.colorScheme.primary.withAlpha(50),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              fluent.Text(
                                'رقم الحساب المتولد تلقائياً:',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              fluent.Text(
                                state.accountNumber,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              fluent.Button(
                onPressed: () => Navigator.of(context).pop(),
                child: const fluent.Text('إلغاء'),
              ),
              fluent.FilledButton(
                onPressed: state.status == SubAccountFormStatus.loading
                    ? null
                    : () => _onSaveButtonClicked(bloc),
                child: state.status == SubAccountFormStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: fluent.ProgressRing(
                          strokeWidth: 2,
                          activeColor: Colors.white,
                        ),
                      )
                    : const fluent.Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SubaccountShimmer extends StatelessWidget {
  const _SubaccountShimmer();

  @override
  Widget build(BuildContext context) {
    return fluent.ContentDialog(
      content: AppShimmer(
        child: SizedBox(
          width: 450,
          height: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: const [
              ShimmerPlaceholder(height: 48),
              SizedBox(height: 16),
              ShimmerPlaceholder(height: 48),
              SizedBox(height: 16),
              ShimmerPlaceholder(height: 48),
              SizedBox(height: 16),
              ShimmerPlaceholder(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
