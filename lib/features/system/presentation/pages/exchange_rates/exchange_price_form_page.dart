import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';
import 'package:flowcash/features/system/presentation/bloc/exchange_rates/exchange_price_form_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class ExchangePriceFormPage extends StatefulWidget {
  const ExchangePriceFormPage({super.key, this.initialValue});

  final ExchangePriceEntity? initialValue;

  @override
  State<ExchangePriceFormPage> createState() => _ExchangePriceFormPageState();
}

class _ExchangePriceFormPageState extends State<ExchangePriceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final GetCurrenciesUseCase _getCurrenciesUseCase;

  final List<CurrencyEntity> _currencies = [];
  CurrencyEntity? _selectedFromCurrency;
  CurrencyEntity? _selectedToCurrency;
  bool _isLoadingCurrencies = true;

  @override
  void initState() {
    super.initState();
    _getCurrenciesUseCase = GetIt.instance<GetCurrenciesUseCase>();
    _priceController = TextEditingController(
      text: widget.initialValue?.price.toString() ?? '',
    );
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    final result = await _getCurrenciesUseCase.call();

    result.fold(
      (failure) {
        setState(() {
          _isLoadingCurrencies = false;
        });
      },
      (currencies) {
        CurrencyEntity? findCurrency(String id) {
          try {
            return currencies.firstWhere((currency) => currency.id == id);
          } catch (_) {
            return null;
          }
        }

        setState(() {
          _currencies
            ..clear()
            ..addAll(currencies);
          _selectedFromCurrency = widget.initialValue == null
              ? null
              : findCurrency(widget.initialValue!.fromCurrencyId);
          _selectedToCurrency = widget.initialValue == null
              ? null
              : findCurrency(widget.initialValue!.toCurrencyId);
          _isLoadingCurrencies = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExchangePriceFormBloc(
        initialValue: widget.initialValue,
        insertExchangePriceUseCase:
            GetIt.instance<InsertExchangePriceUseCase>(),
        updateExchangePriceUseCase:
            GetIt.instance<UpdateExchangePriceUseCase>(),
      ),
      child: Builder(
        builder: (blocContext) {
          return BlocListener<ExchangePriceFormBloc, ExchangePriceFormState>(
            listener: (context, state) {
              if (state.isSuccess && state.savedEntity != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop(state.savedEntity);
                });
              }
            },
            child: fluent.ContentDialog(
              title: fluent.Text(
                widget.initialValue == null ? 'إضافة سعر صرف' : 'تعديل سعر صرف',
              ),

              content: BlocBuilder<ExchangePriceFormBloc, ExchangePriceFormState>(
                builder: (context, state) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: fluent.InfoLabel(
                                label: 'من العملة',
                                child: _isLoadingCurrencies
                                    ? fluent.Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14.0,
                                          horizontal: 12.0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Row(
                                          children: const [
                                            fluent.ProgressRing(strokeWidth: 2),
                                            SizedBox(width: 8),
                                            fluent.Text(
                                              'جارٍ تحميل العملات...',
                                            ),
                                          ],
                                        ),
                                      )
                                    : _currencies.isEmpty
                                    ? const fluent.Text('لا توجد عملات متاحة')
                                    : fluent.ComboboxFormField<CurrencyEntity>(
                                        items: _currencies
                                            .map(
                                              (currency) =>
                                                  fluent.ComboBoxItem<
                                                    CurrencyEntity
                                                  >(
                                                    value: currency,
                                                    child: fluent.Text(
                                                      '${currency.name} (${currency.symbol})',
                                                    ),
                                                  ),
                                            )
                                            .toList(),
                                        value: _selectedFromCurrency,
                                        placeholder: const fluent.Text(
                                          'اختر العملة المرسلة',
                                        ),
                                        isExpanded: true,
                                        validator: (value) {
                                          if (value == null) {
                                            return 'الرجاء اختيار العملة المرسلة';
                                          }
                                          return null;
                                        },
                                        onChanged: widget.initialValue != null
                                            ? null
                                            : (currency) {
                                                setState(() {
                                                  _selectedFromCurrency =
                                                      currency;
                                                });
                                                context
                                                    .read<
                                                      ExchangePriceFormBloc
                                                    >()
                                                    .add(
                                                      ExchangePriceFromCurrencyChanged(
                                                        currency?.id ?? '',
                                                      ),
                                                    );
                                              },
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: fluent.InfoLabel(
                                label: 'إلى العملة',
                                child: _isLoadingCurrencies
                                    ? fluent.Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14.0,
                                          horizontal: 12.0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Row(
                                          children: const [
                                            fluent.ProgressRing(strokeWidth: 2),
                                            SizedBox(width: 8),
                                            fluent.Text(
                                              'جارٍ تحميل العملات...',
                                            ),
                                          ],
                                        ),
                                      )
                                    : _currencies.isEmpty
                                    ? const fluent.Text('لا توجد عملات متاحة')
                                    : fluent.ComboboxFormField<CurrencyEntity>(
                                        items: _currencies
                                            .map(
                                              (currency) =>
                                                  fluent.ComboBoxItem<
                                                    CurrencyEntity
                                                  >(
                                                    value: currency,
                                                    child: fluent.Text(
                                                      '${currency.name} (${currency.symbol})',
                                                    ),
                                                  ),
                                            )
                                            .toList(),
                                        value: _selectedToCurrency,
                                        placeholder: const fluent.Text(
                                          'اختر العملة المستقبلة',
                                        ),
                                        isExpanded: true,
                                        validator: (value) {
                                          if (value == null) {
                                            return 'الرجاء اختيار العملة المستقبلة';
                                          }
                                          return null;
                                        },
                                        onChanged: widget.initialValue != null
                                            ? null
                                            : (currency) {
                                                setState(() {
                                                  _selectedToCurrency =
                                                      currency;
                                                });
                                                context
                                                    .read<
                                                      ExchangePriceFormBloc
                                                    >()
                                                    .add(
                                                      ExchangePriceToCurrencyChanged(
                                                        currency?.id ?? '',
                                                      ),
                                                    );
                                              },
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        fluent.InfoLabel(
                          label: 'سعر الصرف',
                          child: fluent.TextFormBox(
                            autofocus: true,
                            textInputAction: fluent.TextInputAction.send,
                            onEditingComplete: () => _onSaveButtonClicked(blocContext),
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            //
                            textDirection: .ltr,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال سعر الصرف';
                              }
                              if (double.tryParse(value.trim()) == null) {
                                return 'الرجاء إدخال قيمة رقمية';
                              }
                              return null;
                            },
                            onChanged: (value) => context
                                .read<ExchangePriceFormBloc>()
                                .add(ExchangePriceValueChanged(value)),
                          ),
                        ),
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          fluent.Text(
                            state.errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
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
                  onPressed: () => Navigator.of(blocContext).pop(),
                  child: const fluent.Text('إلغاء'),
                ),
                fluent.FilledButton(
                  onPressed: () => _onSaveButtonClicked(blocContext),
                  child:
                      BlocBuilder<
                        ExchangePriceFormBloc,
                        ExchangePriceFormState
                      >(
                        bloc: blocContext.read<ExchangePriceFormBloc>(),
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
          );
        },
      ),
    );
  }

  void _onSaveButtonClicked(BuildContext blocContext) {
    if (!_formKey.currentState!.validate()) return;
    blocContext.read<ExchangePriceFormBloc>().add(
      const ExchangePriceFormSubmitted(),
    );
  }
}
