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
  late final TextEditingController _fullSymbolController;
  late final TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.initialValue?.id ?? '');
    _nameController = TextEditingController(text: widget.initialValue?.name ?? '');
    _symbolController = TextEditingController(text: widget.initialValue?.symbol ?? '');
    _fullSymbolController = TextEditingController(text: widget.initialValue?.fullSymbol ?? '');
    _countryController = TextEditingController(text: widget.initialValue?.country ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    _fullSymbolController.dispose();
    _countryController.dispose();
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
                    fluent.InfoLabel(
                      label: 'الرمز الكامل',
                      child: fluent.TextFormBox(
                        controller: _fullSymbolController,
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.important),
                        ),
                        onChanged: (value) => context.read<CurrencyFormBloc>().add(
                              CurrencyFormFullSymbolChanged(value),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'البلد',
                      child: fluent.TextFormBox(
                        controller: _countryController,
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.public_folder),
                        ),
                        onChanged: (value) => context.read<CurrencyFormBloc>().add(
                              CurrencyFormCountryChanged(value),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.ToggleSwitch(
                      content: const fluent.Text('محدد'),
                      checked: state.selected,
                      onChanged: (value) => context.read<CurrencyFormBloc>().add(
                            CurrencyFormSelectedChanged(value),
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
                if (!_formKey.currentState!.validate()) return;
                context.read<CurrencyFormBloc>().add(const CurrencyFormSubmitted());
              },
              child: BlocBuilder<CurrencyFormBloc, CurrencyFormState>(
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
