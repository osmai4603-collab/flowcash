import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
import 'package:flowcash/features/system/presentation/bloc/currencies/currency_form_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, FluentIcons, ProgressRing;
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
        child: ContentDialog(
          title: Text(widget.initialValue == null ? 'إضافة عملة' : 'تعديل عملة'),
          
          content: BlocBuilder<CurrencyFormBloc, CurrencyFormState>(
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: 'المعرف',
                        prefixIcon: Icon(FluentIcons.lock12),
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'الاسم',
                        prefixIcon: Icon(FluentIcons.text_field),
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _symbolController,
                      decoration: const InputDecoration(
                        labelText: 'الرمز',
                        prefixIcon: Icon(FluentIcons.label),
                      ),
                      onChanged: (value) => context.read<CurrencyFormBloc>().add(
                            CurrencyFormSymbolChanged(value),
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fullSymbolController,
                      decoration: const InputDecoration(
                        labelText: 'الرمز الكامل',
                        prefixIcon: Icon(FluentIcons.important),
                      ),
                      onChanged: (value) => context.read<CurrencyFormBloc>().add(
                            CurrencyFormFullSymbolChanged(value),
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'البلد',
                        prefixIcon: Icon(FluentIcons.public_folder),
                      ),
                      onChanged: (value) => context.read<CurrencyFormBloc>().add(
                            CurrencyFormCountryChanged(value),
                          ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('محدد'),
                      value: state.selected,
                      onChanged: (value) => context.read<CurrencyFormBloc>().add(
                            CurrencyFormSelectedChanged(value),
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
                context.read<CurrencyFormBloc>().add(const CurrencyFormSubmitted());
              },
              child: BlocBuilder<CurrencyFormBloc, CurrencyFormState>(
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
