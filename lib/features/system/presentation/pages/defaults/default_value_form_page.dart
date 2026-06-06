import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';
import 'package:flowcash/features/system/presentation/bloc/defaults/default_value_form_cubit.dart';

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
  late TextEditingController _typeController;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialValue?.valueType ?? ValueType.values.first;
    _typeController = TextEditingController(text: _selectedType.displayName());
    _valueController = TextEditingController(text: widget.initialValue?.value?.toString() ?? _selectedType.defaultValue);
  }

  @override
  void dispose() {
    _typeController.dispose();
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
          title: fluent.Text(widget.initialValue == null ? 'إضافة قيمة' : 'تعديل قيمة'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  fluent.InfoLabel(
                    label: 'نوع القيمة',
                    child: fluent.AutoSuggestBox<ValueType>.form(
                      controller: _typeController,
                      items: ValueType.values.map((e) {
                        return fluent.AutoSuggestBoxItem<ValueType>(
                          value: e,
                          label: e.displayName(),
                        );
                      }).toList(),
                      leadingIcon: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: fluent.Icon(fluent.FluentIcons.category_classification),
                      ),
                      placeholder: 'حدد نوع القيمة',
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'الرجاء اختيار نوع القيمة';
                        }
                        return null;
                      },
                      onSelected: (item) {
                        _typeController.text = item.label;
                        setState(() {
                          _selectedType = item.value!;
                          if (_valueController.text.isEmpty) {
                            _valueController.text = _selectedType.defaultValue;
                          }
                        });
                      },
                      noResultsFoundBuilder: (_) => const fluent.Text('لا توجد قيم'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  fluent.InfoLabel(
                    label: 'القيمة',
                    child: fluent.TextFormBox(
                      controller: _valueController,
                      prefix: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: fluent.Icon(fluent.FluentIcons.number),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'الرجاء إدخال قيمة' : null,
                    ),
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
                  id: widget.initialValue?.id ?? DateTime.now().millisecondsSinceEpoch,
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
}
