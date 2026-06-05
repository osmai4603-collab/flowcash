import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/system/domain/entities/value_entity.dart';
import 'package:flowcash/core/enums/value_type_enum.dart';
import 'package:flowcash/features/system/presentation/bloc/defaults/default_value_form_cubit.dart';

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, FluentIcons;
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

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialValue?.valueType ?? ValueType.values.first;
    _valueController = TextEditingController(text: widget.initialValue?.value?.toString() ?? _selectedType.defaultValue);
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
        child: ContentDialog(
          constraints: const BoxConstraints(maxWidth: 500, minWidth: 500),
          title: Text(widget.initialValue == null ? 'إضافة قيمة' : 'تعديل قيمة'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ValueType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(labelText: 'نوع القيمة', prefixIcon: Icon(FluentIcons.category_classification)),
                    items: ValueType.values
                        .map((e) => DropdownMenuItem(value: e, child: Text(e.displayName())))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _selectedType = v;
                        if (_valueController.text.isEmpty) {
                          _valueController.text = v.defaultValue;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _valueController,
                    decoration: const InputDecoration(labelText: 'القيمة', prefixIcon: Icon(FluentIcons.number)),
                    validator: (v) => (v == null || v.isEmpty) ? 'الرجاء إدخال قيمة' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                final value = ValueEntity(
                  id: widget.initialValue?.id ?? DateTime.now().millisecondsSinceEpoch,
                  value: _valueController.text,
                  valueType: _selectedType,
                );
                context.read<DefaultValueFormCubit>().submit(value);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
