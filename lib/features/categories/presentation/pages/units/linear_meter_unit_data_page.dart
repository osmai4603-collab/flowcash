import 'dart:io';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/spacings.dart';
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

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog;
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
          child: ContentDialog(
            constraints: const BoxConstraints(maxWidth: 400),
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
                      spacing: Spacings.medium,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              tooltip: 'رجوع',
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextWidget(
                              text:
                                  'ادخال ${widget.property.propertyName} ${category?.unitName ?? 'حبة'}',
                              alignment: Alignment.center,
                              expanded: true,
                            ),
                            IconButton(
                              icon: const Icon(Icons.save),
                              tooltip: 'حفظ البيانات',
                              onPressed: _onSaveButtonClicked,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _onSaveButtonClicked(),
                                controller: lengthController,
                                textDirection: TextDirection.ltr,
                                keyboardType: TextInputType.number,
                                textAlignVertical: isDesktop
                                    ? TextAlignVertical.top
                                    : TextAlignVertical.center,
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
                                decoration: InputDecoration(
                                  hintText:
                                      'ادخل ال${widget.property.propertyName}',
                                  hintStyle: Styles.labelMedium.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                  labelText: widget.property.propertyName,
                                  labelStyle: Styles.titleMedium.copyWith(
                                    color: colors.primary,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: colors.onSurfaceVariant,
                                      width: 0.50,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: colors.onSurfaceVariant,
                                      width: 0.20,
                                    ),
                                  ),
                                  prefixIcon: Icon(Icons.fitness_center,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: measureUnitSelected,
                                decoration: const InputDecoration(
                                  labelText: 'الوحدة',
                                  hintText: 'حدد الوحدة',
                                  prefixIcon: Icon(Icons.merge_type),
                                ),
                                items: measuresUnits.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
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
