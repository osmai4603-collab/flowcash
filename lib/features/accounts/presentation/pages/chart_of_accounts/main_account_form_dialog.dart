import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

// Enums
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';

// Entities
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';

// Bloc
import 'package:flowcash/features/accounts/presentation/blocs/main_account_form/main_account_form_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/main_account_form/main_account_form_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/main_account_form/main_account_form_state.dart';

class MainAccountFormDialog extends StatefulWidget {
  final MainAccountGroup group;
  final MainAccountEntity? mainAccount;

  const MainAccountFormDialog({
    super.key,
    this.mainAccount,
    required this.group,
  });

  @override
  State<MainAccountFormDialog> createState() => _MainAccountFormDialogState();
}

class _MainAccountFormDialogState extends State<MainAccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => GetIt.instance<MainAccountFormBloc>()
        ..add(
          InitMainAccountForm(
            editingAccount: widget.mainAccount,
            group: widget.group,
          ),
        ),
      child: BlocConsumer<MainAccountFormBloc, MainAccountFormState>(
        listener: (context, state) {
          if (state.status == MainAccountFormStatus.success) {
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
          if (state.editingAccount != null && _nameController.text.isEmpty) {
            _nameController.text = state.accountName;
          }
        },
        builder: (context, state) {
          final bloc = context.read<MainAccountFormBloc>();
          final isEditing = state.editingAccount != null;

          return fluent.ContentDialog(
            title: Row(
              children: [
                fluent.Icon(
                  isEditing
                      ? fluent.FluentIcons.edit_note
                      : fluent.FluentIcons.add_work,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                fluent.Text(
                  isEditing ? 'تعديل حساب رئيسي' : 'إضافة حساب رئيسي جديد',
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 450,
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: Spacings.medium,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Account Name
                      fluent.InfoLabel(
                        label: 'اسم الحساب الرئيسي',
                        child: fluent.TextFormBox(
                          placeholder: 'ادخل اسم الحساب الرئيسي',
                          autofocus: widget.mainAccount == null,
                          enabled: state.canEnabledFields,
                          controller: _nameController,
                          prefix: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: fluent.Icon(
                              fluent.FluentIcons.account_activity,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الرجاء إدخال اسم الحساب الرئيسي';
                            }
                            return null;
                          },
                          onChanged: (value) =>
                              bloc.add(MainAccountNameChanged(value)),
                        ),
                      ),

                      Row(
                        crossAxisAlignment: .start,
                        spacing: Spacings.medium,
                        children: [
                          Expanded(
                            child: FormField<MainAccountGroup>(
                              key: ValueKey(state.selectedGroup),
                              initialValue: state.selectedGroup,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) => value == null
                                  ? 'مطلوب اختيار مجموعة الحساب'
                                  : null,
                              builder: (field) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    fluent.InfoLabel(
                                      label: 'مجموعة الحساب العامة',
                                      child: fluent.ComboBox<MainAccountGroup>(
                                        value: state.selectedGroup,
                                        placeholder: const fluent.Text(
                                          'اختر مجموعة الحساب',
                                        ),
                                        disabledPlaceholder:
                                            const fluent.Text(
                                              'غير متاح للتعديل',
                                            ),
                                        isExpanded: true,
                                        icon: const fluent.Icon(
                                          fluent.FluentIcons.chevron_down,
                                        ),
                                        items: isEditing
                                            ? state.selectedGroup == null
                                                  ? []
                                                  : [
                                                      fluent.ComboBoxItem(
                                                        value: state
                                                            .selectedGroup,
                                                        child: fluent.Text(
                                                          state.selectedGroup!
                                                              .displayName(),
                                                        ),
                                                      ),
                                                    ]
                                            : MainAccountGroup.values.map((
                                                group,
                                              ) {
                                                return fluent.ComboBoxItem(
                                                  value: group,
                                                  child: fluent.Text(
                                                    group.displayName(),
                                                  ),
                                                );
                                              }).toList(),
                                        onChanged: isEditing
                                            ? null
                                            : (group) {
                                                if (group != null) {
                                                  field.didChange(group);
                                                  bloc.add(
                                                    MainAccountGroupChanged(
                                                      group,
                                                    ),
                                                  );
                                                }
                                              },
                                      ),
                                    ),
                                    if (field.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 6,
                                        ),
                                        child: fluent.Text(
                                          field.errorText!,
                                          style: TextStyle(
                                            color: theme.colorScheme.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: FormField<MainAccountType>(
                              key: ValueKey(state.selectedType),
                              initialValue: state.selectedType,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) => value == null
                                  ? 'مطلوب اختيار نوع الحساب'
                                  : null,
                              builder: (field) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    fluent.InfoLabel(
                                      label: 'نوع الحساب الرئيسي',
                                      child: fluent.ComboBox<MainAccountType>(
                                        value: state.selectedType,
                                        placeholder: const fluent.Text(
                                          'اختر نوع الحساب الرئيسي',
                                        ),
                                        disabledPlaceholder:
                                            const fluent.Text(
                                              'حدد مجموعة أولاً',
                                            ),
                                        isExpanded: true,
                                        icon: const fluent.Icon(
                                          fluent.FluentIcons.chevron_down,
                                        ),
                                        items: state.selectedGroup == null
                                            ? []
                                            : MainAccountType.whereMainAccount(
                                                state.selectedGroup!,
                                              ).map((type) {
                                                return fluent.ComboBoxItem(
                                                  value: type,
                                                  child: fluent.Text(
                                                    type.displayName(),
                                                  ),
                                                );
                                              }).toList(),
                                        onChanged: (type) {
                                          if (type != null) {
                                            field.didChange(type);
                                            bloc.add(
                                              MainAccountTypeChanged(type),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    if (field.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 6,
                                        ),
                                        child: fluent.Text(
                                          field.errorText!,
                                          style: TextStyle(
                                            color: theme.colorScheme.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      FormField<CurrencyEntity?>(
                        key: ValueKey(state.selectedCurrency?.id ?? ''),
                        initialValue: state.selectedCurrency,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) =>
                            value == null ? 'مطلوب اختيار العملة' : null,
                        builder: (field) {
                          final currencyItems = state.currencies
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
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              fluent.InfoLabel(
                                label: 'العملة الافتراضية',
                                child: fluent.ComboBox<CurrencyEntity>(
                                  value: state.selectedCurrency,
                                  placeholder: const fluent.Text(
                                    'اختر العملة الافتراضية',
                                  ),
                                  disabledPlaceholder: const fluent.Text(
                                    'لا توجد عملات متاحة',
                                  ),
                                  isExpanded: true,
                                  icon: const fluent.Icon(
                                    fluent.FluentIcons.chevron_down,
                                  ),
                                  items: currencyItems,
                                  onChanged: (CurrencyEntity? currency) {
                                    if (currency != null) {
                                      field.didChange(currency);
                                      bloc.add(
                                        MainAccountCurrencyChanged(currency),
                                      );
                                    }
                                  },
                                ),
                              ),
                              if (field.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: fluent.Text(
                                    field.errorText!,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      // Account Number Info

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
                                isEditing
                                    ? 'رقم الحساب الحالي:'
                                    : 'رقم الحساب المتولد تلقائياً:',
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
                onPressed: state.status == MainAccountFormStatus.loading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          bloc.add(const SubmitMainAccountForm());
                        }
                      },
                child: state.status == MainAccountFormStatus.loading
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
