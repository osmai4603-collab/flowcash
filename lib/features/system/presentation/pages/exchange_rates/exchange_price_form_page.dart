import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';
import 'package:flowcash/features/system/presentation/bloc/exchange_rates/exchange_price_form_bloc.dart';

class ExchangePriceFormPage extends StatefulWidget {
  const ExchangePriceFormPage({super.key, this.initialValue});

  final ExchangePriceEntity? initialValue;

  @override
  State<ExchangePriceFormPage> createState() => _ExchangePriceFormPageState();
}

class _ExchangePriceFormPageState extends State<ExchangePriceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fromCurrencyController;
  late final TextEditingController _toCurrencyController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _fromCurrencyController = TextEditingController(text: widget.initialValue?.fromCurrencyId ?? '');
    _toCurrencyController = TextEditingController(text: widget.initialValue?.toCurrencyId ?? '');
    _priceController = TextEditingController(text: widget.initialValue?.price.toString() ?? '');
  }

  @override
  void dispose() {
    _fromCurrencyController.dispose();
    _toCurrencyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExchangePriceFormBloc(
        initialValue: widget.initialValue,
        insertExchangePriceUseCase: GetIt.instance<InsertExchangePriceUseCase>(),
        updateExchangePriceUseCase: GetIt.instance<UpdateExchangePriceUseCase>(),
      ),
      child: BlocListener<ExchangePriceFormBloc, ExchangePriceFormState>(
        listener: (context, state) {
          if (state.isSuccess && state.savedEntity != null) {
            Navigator.of(context).pop(state.savedEntity);
          }
        },
        child: AlertDialog(
          title: Text(widget.initialValue == null ? 'إضافة سعر صرف' : 'تعديل سعر صرف'),
          scrollable: true,
          content: BlocBuilder<ExchangePriceFormBloc, ExchangePriceFormState>(
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _fromCurrencyController,
                      decoration: const InputDecoration(
                        labelText: 'من العملة',
                        prefixIcon: Icon(Icons.arrow_back),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال رمز العملة المرسلة';
                        }
                        return null;
                      },
                      onChanged: (value) => context.read<ExchangePriceFormBloc>().add(
                            ExchangePriceFromCurrencyChanged(value),
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _toCurrencyController,
                      decoration: const InputDecoration(
                        labelText: 'إلى العملة',
                        prefixIcon: Icon(Icons.arrow_forward),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال رمز العملة المستقبلة';
                        }
                        return null;
                      },
                      onChanged: (value) => context.read<ExchangePriceFormBloc>().add(
                            ExchangePriceToCurrencyChanged(value),
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'سعر الصرف',
                        prefixIcon: Icon(Icons.price_check),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال سعر الصرف';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'الرجاء إدخال قيمة رقمية';
                        }
                        return null;
                      },
                      onChanged: (value) => context.read<ExchangePriceFormBloc>().add(
                            ExchangePriceValueChanged(value),
                          ),
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
                if (!_formKey.currentState!.validate()) return;
                context.read<ExchangePriceFormBloc>().add(const ExchangePriceFormSubmitted());
              },
              child: BlocBuilder<ExchangePriceFormBloc, ExchangePriceFormState>(
                builder: (context, state) {
                  return state.isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
