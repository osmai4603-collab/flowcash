import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';
import 'package:flowcash/features/system/presentation/bloc/defaults/default_value_form_cubit.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class DefaultValueFormPage extends StatefulWidget {
  final ValueEntity? initialValue;

  const DefaultValueFormPage({super.key, this.initialValue});

  @override
  State<DefaultValueFormPage> createState() => _DefaultValueFormPageState();
}

class _DefaultValueFormPageState extends State<DefaultValueFormPage> {
  final _formKey = GlobalKey<FormState>();
  late ValueType _selectedType;
  late TextEditingController _valueController;

  final List<CurrencyEntity> _currencies = [];
  bool _isLoadingCurrencies = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialValue?.valueType ?? ValueType.values.first;
    _valueController = TextEditingController(
      text:
          widget.initialValue?.value?.toString() ?? _selectedType.defaultValue,
    );
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    setState(() {
      _isLoadingCurrencies = true;
    });
    final result = await GetIt.instance<GetCurrenciesUseCase>().call();
    result.fold(
      (failure) {
        setState(() {
          _isLoadingCurrencies = false;
        });
      },
      (currencies) {
        setState(() {
          _currencies
            ..clear()
            ..addAll(currencies);
          _isLoadingCurrencies = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DefaultValueFormCubit(initial: widget.initialValue),
      child: BlocListener<DefaultValueFormCubit, DefaultValueFormState>(
        listener: (context, state) {
          if (state is DefaultValueFormSuccess) {
            Navigator.of(context).pop(state.value);
          }
        },
        child: fluent.ContentDialog(
          constraints: const BoxConstraints(maxWidth: 400, minWidth: 400),
          title: fluent.Text(
            widget.initialValue == null ? 'إضافة قيمة' : 'تعديل قيمة',
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  fluent.InfoLabel(
                    label: 'نوع القيمة',
                    child: fluent.ComboboxFormField<ValueType>(
                      value: _selectedType,
                      isExpanded: true,
                      items: ValueType.values.map((e) {
                        return fluent.ComboBoxItem<ValueType>(
                          value: e,
                          child: fluent.Text(e.displayName()),
                        );
                      }).toList(),
                      placeholder: const fluent.Text('حدد نوع القيمة'),
                      validator: (value) {
                        if (value == null) {
                          return 'الرجاء اختيار نوع القيمة';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                            _valueController.text = _selectedType.defaultValue;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  fluent.InfoLabel(
                    label: 'القيمة',
                    child: _buildValueInputField(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            fluent.Button(
              onPressed: () => Navigator.of(context).pop(),
              child: const fluent.Text('إلغاء'),
            ),
            fluent.FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                final value = ValueEntity(
                  id:
                      widget.initialValue?.id ??
                      DateTime.now().millisecondsSinceEpoch,
                  value: _valueController.text,
                  valueType: _selectedType,
                );
                context.read<DefaultValueFormCubit>().submit(value);
              },
              child: const fluent.Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueInputField() {
    if (_selectedType == ValueType.defaultCurrency) {
      if (_isLoadingCurrencies) {
        return const SizedBox(
          height: 32,
          child: Center(child: fluent.ProgressRing(strokeWidth: 2)),
        );
      }
      return fluent.ComboboxFormField<String>(
        value: _currencies.any((c) => c.id.toString() == _valueController.text)
            ? _valueController.text
            : (_currencies.isNotEmpty ? _currencies.first.id.toString() : null),
        isExpanded: true,
        items: _currencies.map((currency) {
          return fluent.ComboBoxItem<String>(
            value: currency.id.toString(),
            child: fluent.Text('${currency.name} (${currency.symbol})'),
          );
        }).toList(),
        placeholder: const fluent.Text('اختر العملة'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء اختيار العملة';
          }
          return null;
        },
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _valueController.text = value;
            });
          }
        },
      );
    } else if (_selectedType == ValueType.databaseVersion) {
      return fluent.ComboboxFormField<String>(
        value: ['1', '2', '3', '4', '5'].contains(_valueController.text)
            ? _valueController.text
            : '1',
        isExpanded: true,
        items: ['1', '2', '3', '4', '5'].map((v) {
          return fluent.ComboBoxItem<String>(value: v, child: fluent.Text(v));
        }).toList(),
        placeholder: const fluent.Text('اختر إصدار قاعدة البيانات'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء اختيار الإصدار';
          }
          return null;
        },
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _valueController.text = value;
            });
          }
        },
      );
    } else if (_selectedType == ValueType.pageFormat) {
      return fluent.ComboboxFormField<String>(
        value:
            ['a4', 'a5', 'letter'].contains(_valueController.text.toLowerCase())
            ? _valueController.text.toLowerCase()
            : 'a4',
        isExpanded: true,
        items: ['a4', 'a5', 'letter'].map((v) {
          return fluent.ComboBoxItem<String>(
            value: v,
            child: fluent.Text(v.toUpperCase()),
          );
        }).toList(),
        placeholder: const fluent.Text('اختر تنسيق الصفحة'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء اختيار تنسيق الصفحة';
          }
          return null;
        },
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _valueController.text = value;
            });
          }
        },
      );
    }

    return fluent.TextFormBox(
      controller: _valueController,
      prefix: const Padding(
        padding: EdgeInsets.all(8.0),
        child: fluent.Icon(fluent.FluentIcons.number),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'الرجاء إدخال قيمة' : null,
    );
  }
}
