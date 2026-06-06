import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/enums/accounting_inventory_type_enum.dart';
import 'package:flowcash/core/usecases/accounting_period_repository_usecases.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/financial_periods/financial_period_form_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
class FinancialPeriodFormPage extends StatefulWidget {
  const FinancialPeriodFormPage({super.key, this.initialValue});

  final AccountingPeriodEntity? initialValue;

  @override
  State<FinancialPeriodFormPage> createState() => _FinancialPeriodFormPageState();
}

class _FinancialPeriodFormPageState extends State<FinancialPeriodFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _currencyController;
  late final TextEditingController _balanceController;
  late final TextEditingController _lastPeriodController;
  late final TextEditingController _inventoryTypeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue?.periodName ?? '');
    _currencyController = TextEditingController(text: widget.initialValue?.currencyId ?? '');
    _balanceController = TextEditingController(
      text: widget.initialValue?.balance.toStringAsFixed(2) ?? '0.00',
    );
    _lastPeriodController = TextEditingController(
      text: widget.initialValue?.lastPeriodId?.toString() ?? '',
    );
    _inventoryTypeController = TextEditingController(
      text: widget.initialValue?.inventoryType?.displayName() ?? AccountingInventoryType.values.first.displayName(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _balanceController.dispose();
    _lastPeriodController.dispose();
    _inventoryTypeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate, ValueChanged<DateTime?> onDateSelected) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      onDateSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinancialPeriodFormBloc(
        initialValue: widget.initialValue,
        insertAccountingPeriodUseCase: GetIt.instance<InsertAccountingPeriodUseCase>(),
        updateAccountingPeriodUseCase: GetIt.instance<UpdateAccountingPeriodUseCase>(),
      ),
      child: BlocListener<FinancialPeriodFormBloc, FinancialPeriodFormState>(
        listener: (context, state) {
          if (state.isSuccess && state.savedEntity != null) {
            Navigator.of(context).pop(state.savedEntity);
          }
        },
        child: fluent.ContentDialog(
          constraints: BoxConstraints(maxWidth: 400, minWidth: 400),
          title: fluent.Text(widget.initialValue == null ? 'إضافة فترة مالية' : 'تعديل فترة مالية'),
          
          content: BlocBuilder<FinancialPeriodFormBloc, FinancialPeriodFormState>(
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    fluent.InfoLabel(
                      label: 'اسم الفترة',
                      child: fluent.TextFormBox(
                        controller: _nameController,
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال اسم الفترة';
                          }
                          return null;
                        },
                        onChanged: (value) => context.read<FinancialPeriodFormBloc>().add(
                              FinancialPeriodFormNameChanged(value),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _selectDate(
                              context,
                              state.dateOfStartPeriod,
                              (date) {
                                if (date != null) {
                                  context.read<FinancialPeriodFormBloc>().add(
                                        FinancialPeriodFormStartDateChanged(date),
                                      );
                                }
                              },
                            ),
                            child: fluent.Text('من التاريخ: ${state.dateOfStartPeriod.toIso8601String().split('T').first}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _selectDate(
                              context,
                              state.dateOfEndPeriod ?? state.dateOfStartPeriod,
                              (date) {
                                context.read<FinancialPeriodFormBloc>().add(
                                      FinancialPeriodFormEndDateChanged(date),
                                    );
                              },
                            ),
                            child: fluent.Text('إلى التاريخ: ${state.dateOfEndPeriod != null ? state.dateOfEndPeriod!.toIso8601String().split('T').first : 'لم يتم التحديد'}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'العملة',
                      child: fluent.TextFormBox(
                        controller: _currencyController,
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.currency),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال رمز العملة';
                          }
                          return null;
                        },
                        onChanged: (value) => context.read<FinancialPeriodFormBloc>().add(
                              FinancialPeriodFormCurrencyChanged(value),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'معرف الفترة السابقة',
                      child: fluent.TextFormBox(
                        controller: _lastPeriodController,
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.link),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => context.read<FinancialPeriodFormBloc>().add(
                              FinancialPeriodFormLastPeriodIdChanged(value),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'الرصيد',
                      child: fluent.TextFormBox(
                        controller: _balanceController,
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال الرصيد';
                          }
                          if (double.tryParse(value.replaceAll(',', '.')) == null) {
                            return 'الرجاء إدخال قيمة رقمية صحيحة';
                          }
                          return null;
                        },
                        onChanged: (value) => context.read<FinancialPeriodFormBloc>().add(
                              FinancialPeriodFormBalanceChanged(value),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'نوع الجرد',
                      child: fluent.AutoSuggestBox<AccountingInventoryType>.form(
                        controller: _inventoryTypeController,
                        items: AccountingInventoryType.values.map((inventoryType) {
                          return fluent.AutoSuggestBoxItem<AccountingInventoryType>(
                            value: inventoryType,
                            label: inventoryType.displayName(),
                          );
                        }).toList(),
                        leadingIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.product),
                        ),
                        placeholder: 'حدد نوع الجرد',
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'الرجاء اختيار نوع الجرد';
                          }
                          return null;
                        },
                        onSelected: (item) {
                          _inventoryTypeController.text = item.label;
                          context.read<FinancialPeriodFormBloc>().add(
                                FinancialPeriodFormInventoryTypeChanged(item.value!),
                              );
                        },
                        noResultsFoundBuilder: (_) => const fluent.Text('لا توجد أنواع جرد'),
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      fluent.Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
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
                context.read<FinancialPeriodFormBloc>().add(const FinancialPeriodFormSubmitted());
              },
              child: BlocBuilder<FinancialPeriodFormBloc, FinancialPeriodFormState>(
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
