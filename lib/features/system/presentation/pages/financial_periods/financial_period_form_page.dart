import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/enums/accounting_inventory_type_enum.dart';
import 'package:flowcash/core/usecases/accounting_period_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/financial_periods/financial_period_form_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class FinancialPeriodFormPage extends StatefulWidget {
  const FinancialPeriodFormPage({super.key, this.initialValue});

  final AccountingPeriodEntity? initialValue;

  @override
  State<FinancialPeriodFormPage> createState() =>
      _FinancialPeriodFormPageState();
}

class _FinancialPeriodFormPageState extends State<FinancialPeriodFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialValue?.periodName ?? '',
    );
    _balanceController = TextEditingController(
      text: widget.initialValue?.balance.toStringAsFixed(2) ?? '0.00',
    );
    // Data loading handled by FinancialPeriodFormBloc
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  // Data loading is handled by FinancialPeriodFormBloc

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinancialPeriodFormBloc(
        initialValue: widget.initialValue,
        getAccountingPeriodsUseCase: sl(),
        getCurrenciesUseCase: sl(),
        insertAccountingPeriodUseCase:
            GetIt.instance<InsertAccountingPeriodUseCase>(),
        updateAccountingPeriodUseCase:
            GetIt.instance<UpdateAccountingPeriodUseCase>(),
      ),
      child: BlocListener<FinancialPeriodFormBloc, FinancialPeriodFormState>(
        listener: (context, state) {
          if (state.isSuccess && state.savedEntity != null) {
            Navigator.of(context).pop(state.savedEntity);
          }
        },
        child: fluent.ContentDialog(
          constraints: BoxConstraints(maxWidth: 400, minWidth: 400),
          title: fluent.Text(
            widget.initialValue == null
                ? 'إضافة فترة مالية'
                : 'تعديل فترة مالية',
          ),

          content: BlocBuilder<FinancialPeriodFormBloc, FinancialPeriodFormState>(
            builder: (context, state) {
              CurrencyEntity? selectedCurrency;
              try {
                selectedCurrency = state.currencies.firstWhere(
                  (currency) => currency.id == state.currencyId,
                );
              } catch (_) {
                selectedCurrency = null;
              }

              return Form(
                key: _formKey,
                child: Column(
                  spacing: Spacings.small,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    fluent.InfoLabel(
                      label: 'اسم الفترة',
                      child: fluent.TextFormBox(
                        controller: _nameController,
                        placeholder: 'ادخل اسم الفترة المالية',
                        // prefix: const Padding(
                        //   padding: EdgeInsets.all(8.0),
                        //   child: fluent.Icon(fluent.FluentIcons.title),
                        // ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال اسم الفترة';
                          }
                          return null;
                        },
                        onChanged: (value) => context
                            .read<FinancialPeriodFormBloc>()
                            .add(FinancialPeriodFormNameChanged(value)),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: fluent.DatePicker(
                            header: 'من تاريخ',
                            selected: state.dateOfStartPeriod,
                            onChanged: (value) {
                              context.read<FinancialPeriodFormBloc>().add(
                                FinancialPeriodFormStartDateChanged(value),
                              );
                            },
                            startDate: DateTime(2000),
                            endDate: DateTime(2100),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: fluent.DatePicker(
                            header: 'إلى تاريخ',
                            selected: state.dateOfEndPeriod,
                            onChanged: (value) {
                              context.read<FinancialPeriodFormBloc>().add(
                                FinancialPeriodFormEndDateChanged(value),
                              );
                            },
                            startDate: DateTime(2000),
                            endDate: DateTime(2100),
                            fieldOrder: [
                              fluent.DatePickerField.day,
                              fluent.DatePickerField.month,
                              fluent.DatePickerField.year,
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
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
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        fluent.ProgressRing(strokeWidth: 2),
                                        SizedBox(width: 8),
                                        fluent.Text('جارٍ تحميل العملات...'),
                                      ],
                                    ),
                                  )
                                : state.currencies.isEmpty
                                ? const fluent.Text('لا توجد عملات متاحة')
                                : fluent.ComboboxFormField<CurrencyEntity>(
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
                                    value: selectedCurrency,
                                    placeholder: const fluent.Text(
                                      'اختر العملة',
                                    ),
                                    isExpanded: true,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'الرجاء اختيار العملة';
                                      }
                                      return null;
                                    },
                                    onChanged: (currency) {
                                      context
                                          .read<FinancialPeriodFormBloc>()
                                          .add(
                                            FinancialPeriodFormCurrencyChanged(
                                              currency?.id ?? '',
                                            ),
                                          );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: fluent.InfoLabel(
                            label: 'نوع الجرد',
                            child:
                                fluent.ComboboxFormField<
                                  AccountingInventoryType
                                >(
                                  items: AccountingInventoryType.values
                                      .map(
                                        (inventoryType) =>
                                            fluent.ComboBoxItem<
                                              AccountingInventoryType
                                            >(
                                              value: inventoryType,
                                              child: fluent.Text(
                                                inventoryType.displayName(),
                                              ),
                                            ),
                                      )
                                      .toList(),
                                  value: state.inventoryType,
                                  placeholder: const fluent.Text(
                                    'حدد نوع الجرد',
                                  ),
                                  isExpanded: true,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'الرجاء اختيار نوع الجرد';
                                    }
                                    return null;
                                  },
                                  onChanged: (inventoryType) {
                                    if (inventoryType != null) {
                                      context.read<FinancialPeriodFormBloc>().add(
                                        FinancialPeriodFormInventoryTypeChanged(
                                          inventoryType,
                                        ),
                                      );
                                    }
                                  },
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: fluent.InfoLabel(
                            label: 'الرصيد',
                            child: fluent.TextFormBox(
                              controller: _balanceController,
                              // prefix: const Padding(
                              //   padding: EdgeInsets.all(8.0),
                              //   child: fluent.Icon(fluent.FluentIcons.money),
                              // ),
                              textDirection: TextDirection.ltr,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) {
                                // Balance is optional. Empty means 0 on save.
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                if (double.tryParse(
                                      value.replaceAll(',', '.'),
                                    ) ==
                                    null) {
                                  return 'الرجاء إدخال قيمة رقمية صحيحة';
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  context.read<FinancialPeriodFormBloc>().add(
                                    FinancialPeriodFormBalanceChanged(value),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: fluent.InfoLabel(
                            label: 'الفترة السابقة',
                            child: state.isLoadingPeriods
                                ? fluent.Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14.0,
                                      horizontal: 12.0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        fluent.ProgressRing(strokeWidth: 2),
                                        SizedBox(width: 8),
                                        fluent.Text('جارٍ تحميل الفترات...'),
                                      ],
                                    ),
                                  )
                                : fluent.ComboboxFormField<String>(
                                    items: [
                                      fluent.ComboBoxItem<String>(
                                        value: '',
                                        child: const fluent.Text(
                                          'بدون فترة سابقة',
                                        ),
                                      ),
                                      ...state.periods.map(
                                        (period) => fluent.ComboBoxItem<String>(
                                          value: period.id.toString(),
                                          child: fluent.Text(
                                            '${period.periodName} (${period.id})',
                                          ),
                                        ),
                                      ),
                                    ],
                                    value: state.lastPeriodId.isEmpty
                                        ? ''
                                        : state.lastPeriodId,
                                    placeholder: const fluent.Text(
                                      'اختر الفترة السابقة (اختياري)',
                                    ),
                                    isExpanded: true,
                                    onChanged: (value) {
                                      context.read<FinancialPeriodFormBloc>().add(
                                        FinancialPeriodFormLastPeriodIdChanged(
                                          value ?? '',
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                    if (state.errorMessage != null)
                      fluent.Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          actions: [
            fluent.Button(
              onPressed: () => Navigator.of(context).pop(),
              child: const fluent.Text('إلغاء'),
            ),
            fluent.FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                context.read<FinancialPeriodFormBloc>().add(
                  const FinancialPeriodFormSubmitted(),
                );
              },
              child:
                  BlocBuilder<
                    FinancialPeriodFormBloc,
                    FinancialPeriodFormState
                  >(
                    builder: (context, state) {
                      return state.isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: fluent.ProgressRing(strokeWidth: 2),
                            )
                          : const fluent.Text('حفظ');
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
