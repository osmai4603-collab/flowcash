import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/enums/accounting_inventory_type_enum.dart';
import 'package:flowcash/core/usecases/accounting_period_repository_usecases.dart';
import 'package:flowcash/features/system/domain/entities/accounting_period_entity.dart';
import 'package:flowcash/features/system/presentation/bloc/financial_periods/financial_period_form_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, FluentIcons, ProgressRing;
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _balanceController.dispose();
    _lastPeriodController.dispose();
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
        child: ContentDialog(
          constraints: BoxConstraints(maxWidth: 400, minWidth: 400),
          title: Text(widget.initialValue == null ? 'إضافة فترة مالية' : 'تعديل فترة مالية'),
          
          content: BlocBuilder<FinancialPeriodFormBloc, FinancialPeriodFormState>(
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الفترة',
                        prefixIcon: Icon(FluentIcons.title),
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
                            child: Text('من التاريخ: ${state.dateOfStartPeriod.toIso8601String().split('T').first}'),
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
                            child: Text('إلى التاريخ: ${state.dateOfEndPeriod != null ? state.dateOfEndPeriod!.toIso8601String().split('T').first : 'لم يتم التحديد'}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _currencyController,
                      decoration: const InputDecoration(
                        labelText: 'العملة',
                        prefixIcon: Icon(FluentIcons.currency),
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastPeriodController,
                      decoration: const InputDecoration(
                        labelText: 'معرف الفترة السابقة',
                        prefixIcon: Icon(FluentIcons.link),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => context.read<FinancialPeriodFormBloc>().add(
                            FinancialPeriodFormLastPeriodIdChanged(value),
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _balanceController,
                      decoration: const InputDecoration(
                        labelText: 'الرصيد',
                        prefixIcon: Icon(FluentIcons.money),
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
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AccountingInventoryType>(
                      initialValue: state.inventoryType,
                      decoration: const InputDecoration(
                        labelText: 'نوع الجرد',
                        prefixIcon: Icon(FluentIcons.product),
                      ),
                      items: AccountingInventoryType.values.map((inventoryType) {
                        return DropdownMenuItem(
                          value: inventoryType,
                          child: Text(inventoryType.displayName()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<FinancialPeriodFormBloc>().add(
                                FinancialPeriodFormInventoryTypeChanged(value),
                              );
                        }
                      },
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
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
                          child: ProgressRing(strokeWidth: 2),
                        )
                      : const Text('حفظ');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
