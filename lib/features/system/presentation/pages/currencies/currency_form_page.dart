import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
import 'package:flowcash/features/system/presentation/bloc/currencies/currency_form_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
class CurrencyFormPage extends StatefulWidget {
  const CurrencyFormPage({super.key, this.initialValue});

  final CurrencyEntity? initialValue;

  @override
  State<CurrencyFormPage> createState() => _CurrencyFormPageState();
}

class _CurrencyFormPageState extends State<CurrencyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _symbolController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.initialValue?.id ?? '');
    _nameController = TextEditingController(text: widget.initialValue?.name ?? '');
    _symbolController = TextEditingController(text: widget.initialValue?.symbol ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return BlocProvider(
      create: (_) => CurrencyFormBloc(
        initialValue: widget.initialValue,
        insertCurrencyUseCase: GetIt.instance<InsertCurrencyUseCase>(),
        updateCurrencyUseCase: GetIt.instance<UpdateCurrencyUseCase>(),
      ),
      child: BlocListener<CurrencyFormBloc, CurrencyFormState>(
        listener: (context, state) {
          if (state.isSuccess && state.savedEntity != null) {
            Navigator.of(context).pop(state.savedEntity);
          }
        },
        child: fluent.ContentDialog(
          title: fluent.Text(widget.initialValue == null ? 'إضافة عملة' : 'تعديل عملة'),
          
          content: BlocBuilder<CurrencyFormBloc, CurrencyFormState>(
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    fluent.InfoLabel(
                      label: 'المعرف',
                      child: fluent.TextFormBox(
                        controller: _idController,
                        placeholder: 'مثال: YER',
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.lock12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال معرف العملة';
                          }
                          return null;
                        },
                        onChanged: (value) => context.read<CurrencyFormBloc>().add(
                              CurrencyFormIdChanged(value),
                            ),
                        enabled: widget.initialValue == null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'الاسم',
                      child: fluent.TextFormBox(
                        controller: _nameController,
                        placeholder: 'مثال: ريال يمني',
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.text_field),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال اسم العملة';
                          }
                          return null;
                        },
                        onChanged: (value) => context.read<CurrencyFormBloc>().add(
                              CurrencyFormNameChanged(value),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'الرمز',
                      child: fluent.TextFormBox(
                        controller: _symbolController,
                        placeholder: 'مثال: ر.ي أو ر.س',
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.label),
                        ),
                        onChanged: (value) => context.read<CurrencyFormBloc>().add(
                              CurrencyFormSymbolChanged(value),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.ToggleSwitch(
                      content: const fluent.Text('افتراضي'),
                      checked: state.isDefault,
                      onChanged: (value) => context.read<CurrencyFormBloc>().add(
                            CurrencyFormIsDefaultChanged(value),
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
            BlocBuilder<CurrencyFormBloc, CurrencyFormState>(
              builder: (context, state) {
                return fluent.FilledButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          if (!_formKey.currentState!.validate()) return;
                          context.read<CurrencyFormBloc>().add(const CurrencyFormSubmitted());
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: fluent.ProgressRing(strokeWidth: 2),
                        )
                      : const fluent.Text('حفظ'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
