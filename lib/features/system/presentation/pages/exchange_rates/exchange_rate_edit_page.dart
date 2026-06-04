import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/currencies/domain/entities/exchange_price_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';

class ExchangeRateEditDialog extends StatefulWidget {
  const ExchangeRateEditDialog({super.key, required this.exchangePrice});

  final ExchangePriceEntity exchangePrice;

  @override
  State<ExchangeRateEditDialog> createState() => _ExchangeRateEditDialogState();
}

class _ExchangeRateEditDialogState extends State<ExchangeRateEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  UpdateExchangePriceUseCase get _updateUseCase => GetIt.instance<UpdateExchangePriceUseCase>();

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.exchangePrice.price.toString();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null) {
      setState(() {
        _errorMessage = 'الرجاء إدخال سعر صالح';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final updatedEntity = widget.exchangePrice.copyWith(price: price);
    final result = await _updateUseCase(updatedEntity);

    result.match(
      (failure) {
        setState(() {
          _isSaving = false;
          _errorMessage = failure.message;
        });
      },
      (entity) {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('تعديل سعر الصرف'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'من ${widget.exchangePrice.fromCurrencyId}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'إلى ${widget.exchangePrice.toCurrencyId}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'سعر الصرف',
                      
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال سعر الصرف';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'الرجاء إدخال قيمة رقمية صحيحة';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ التغيير'),
        ),
      ],
    );
  }
}
