import 'dart:io';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';

import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowcash/core/theme/styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_state.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

import '../../../../../core/theme_fluent/app_colors.dart';

class LinearMeterUnitDataPage extends StatefulWidget {
  final CategoryPropertyEntity property;
  final UnitEntity? unit;
  const LinearMeterUnitDataPage({super.key, required this.property, this.unit});

  @override
  State<LinearMeterUnitDataPage> createState() =>
      _LinearMeterUnitDataPageState();
}

class _LinearMeterUnitDataPageState extends State<LinearMeterUnitDataPage> {
  CategoryPropertyEntity get property => widget.property;
  final _formKey = GlobalKey<FormState>();
  final lengthController = TextEditingController();
  MainCategoryEntity? category;
  List<String> measuresUnits = ['متر', 'سم', 'مل'];
  String measureUnitSelected = 'متر';
  bool _isDataChanged = false;

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  double get currentLength {
    return double.tryParse(lengthController.text.replaceAll(',', '')) ?? 0.0;
  }

  @override
  void dispose() {
    lengthController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_isDataChanged) {
      setState(() => _isDataChanged = true);
    }
  }

  void _onBackPressed() async {
    if (!_isDataChanged) {
      if (context.mounted) Navigator.pop(context);
      return;
    }
    final sure = await makeSure(
      context: context,
      title: 'تأكيد الخروج',
      content: 'هل تريد الخروج؟ سيتم فقدان البيانات غير المحفوظة',
    );
    if (sure && context.mounted) {
      setState(() => _isDataChanged = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<UnitFormBloc>().state;
    category = state.category;
    measuresUnits = state.measuresUnits.isNotEmpty
        ? state.measuresUnits
        : measuresUnits;
    measureUnitSelected = state.measureUnitSelected.isNotEmpty
        ? state.measureUnitSelected
        : measureUnitSelected;
    lengthController.text = AppMoneyFormatter.formatDouble(state.initialLength);
  }

  void _onSaveButtonClicked() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.read<UnitFormBloc>().add(
      SaveUnitFormEvent(
        UnitEntity.linearMeter(
          id: widget.unit?.id ?? 0,
          propertyId: widget.unit?.propertyId ?? widget.property.id,
          length: currentLength,
          unitName: measureUnitSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    return BlocBuilder<UnitFormBloc, UnitFormState>(
      builder: (context, state) {
        final isSaving = state.status == UnitFormStatus.saving;
        final isEditing = widget.unit?.id != null && widget.unit?.id != 0;

        return PopScope(
          canPop: !_isDataChanged,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _onBackPressed();
          },
          child: fluent.ContentDialog(
            constraints: const BoxConstraints(maxWidth: 400),
            title: Row(
              children: [
                fluent.Icon(
                  isEditing
                      ? fluent.FluentIcons.edit_note
                      : fluent.FluentIcons.add_work,
                  color: colors.primary,
                ),
                const SizedBox(width: 10),
                fluent.Text(
                  isEditing
                      ? 'تعديل ${widget.property.propertyName}'
                      : 'إضافة ${widget.property.propertyName} جديدة',
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  spacing: Spacings.medium,
                  children: [
                    TextWidget(
                      text:
                          'ادخال ${widget.property.propertyName} حبة',
                      alignment: Alignment.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: fluent.TextFormBox(
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onSaveButtonClicked(),
                            controller: lengthController,
                            // enabled: !isSaving,
                            textDirection: TextDirection.ltr,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'\d+\.?\d*'),
                              ),
                            ],
                            onChanged: (_) => _markChanged(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'يرجى إدخال ال${widget.property.propertyName}';
                              }
                              final parsed =
                                  double.tryParse(
                                    value.replaceAll(',', ''),
                                  ) ??
                                  0.0;
                              if (parsed <= 0) {
                                return 'يجب أن يكون ال${widget.property.propertyName} أكبر من صفر';
                              }
                              return null;
                            },
                            placeholder: 'ادخل ال${widget.property.propertyName}',
                            prefix: fluent.Icon(
                              Icons.fitness_center,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: fluent.ComboboxFormField<String>(
                            value: measureUnitSelected,
                            placeholder: const fluent.Text('حدد الوحدة'),
                            // enabled: !isSaving,
                            items: isSaving ? [] : measuresUnits.map((String value) {
                              return fluent.ComboBoxItem<String>(
                                value: value,
                                child: fluent.Text(
                                  value,
                                  style: Styles.titleMedium,
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  measureUnitSelected = newValue;
                                  _markChanged();
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى اختيار الوحدة';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              fluent.Button(
                onPressed: _onBackPressed,
                child: const fluent.Text('إلغاء'),
              ),
              fluent.FilledButton(
                onPressed: isSaving ? null : _onSaveButtonClicked,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: fluent.ProgressRing(
                          strokeWidth: 2,
                          activeColor: Colors.white,
                        ),
                      )
                    : const fluent.Text('حفظ'),
              ),
            ],
          ),
        );
      },
    );
  }
}
