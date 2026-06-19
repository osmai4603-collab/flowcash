import 'dart:io';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/core/theme/paddings.dart';

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

class WeightUnitDataPage extends StatefulWidget {
  final CategoryPropertyEntity property;
  final UnitEntity? unit;

  const WeightUnitDataPage({super.key, required this.property, this.unit});

  @override
  State<WeightUnitDataPage> createState() => _WeightUnitDataPageState();
}

class _WeightUnitDataPageState extends State<WeightUnitDataPage> {
  final _formKey = GlobalKey<FormState>();
  final weightController = TextEditingController();
  List<String> measuresUnits = ['كيلو', 'جرام', 'مل'];
  String measureUnitSelected = 'كيلو';
  MainCategoryEntity? category;
  bool _isDataChanged = false;

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  double get currentWeight {
    return double.tryParse(weightController.text.replaceAll(',', '')) ?? 0.0;
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
    weightController.text = AppMoneyFormatter.formatDouble(state.initialWeight);
  }

  @override
  void dispose() {
    weightController.dispose();
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

  void _onSaveButtonClicked() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.read<UnitFormBloc>().add(
      SaveUnitFormEvent(
        UnitEntity.weight(
          id: widget.unit?.id ?? 0,
          weight: currentWeight,
          unitName: measureUnitSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.of(context);
    return BlocBuilder<UnitFormBloc, UnitFormState>(
      builder: (context, state) {
        final isLoading =
            state.status == UnitFormStatus.initial ||
            state.status == UnitFormStatus.loading ||
            state.status == UnitFormStatus.saving;
        final isSaving = state.status == UnitFormStatus.saving;
        return PopScope(
          canPop: !_isDataChanged,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _onBackPressed();
          },
          child: fluent.ContentDialog(
            constraints: const BoxConstraints(maxWidth: 350),
            content: Padding(
              padding: Paddings.mediumAll,
              child: ShimmerLoadingWidget(
                canShimmer: isLoading,
                freezeScreen: isSaving,
                period: const Duration(milliseconds: 900),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            children: [
                              fluent.Tooltip(
                                message: 'رجوع',
                                child: fluent.IconButton(
                                  icon: const fluent.Icon(
                                    fluent.FluentIcons.back,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              TextWidget(
                                text:
                                    'ادخال ${widget.property.propertyName} ${category?.unitName ?? 'حبة'}',
                                alignment: Alignment.center,
                                expanded: true,
                              ),
                              fluent.Tooltip(
                                message: 'حفظ البيانات',
                                child: fluent.IconButton(
                                  icon: const fluent.Icon(
                                    fluent.FluentIcons.save,
                                  ),
                                  onPressed: _onSaveButtonClicked,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: fluent.TextFormBox(
                                textInputAction: TextInputAction.next,
                                controller: weightController,
                                textDirection: TextDirection.ltr,
                                keyboardType: TextInputType.number,
                                style: Styles.labelMedium,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'\d+\.?\d*'),
                                  ),
                                ],
                                cursorHeight: 20.0,
                                onChanged: (_) => _markChanged(),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'يرجى إدخال الوزن';
                                  }
                                  final parsed =
                                      double.tryParse(
                                        value.replaceAll(',', ''),
                                      ) ??
                                      0.0;
                                  if (parsed <= 0) {
                                    return 'يجب أن يكون الوزن أكبر من صفر';
                                  }
                                  return null;
                                },
                                placeholder: 'ادخل الوزن',
                                placeholderStyle: Styles.labelMedium.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                                prefix: fluent.Icon(
                                  fluent.FluentIcons.light_weight,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: fluent.ComboboxFormField<String>(
                                value: measureUnitSelected,
                                placeholder: const fluent.Text('حدد الوحدة'),
                                disabledPlaceholder: const fluent.Text(
                                  'لا يوجد وحدات معرفة',
                                ),
                                items: measuresUnits.map((String value) {
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
              ),
            ),
          ),
        );
      },
    );
  }
}
