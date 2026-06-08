import 'dart:io';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
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

class MeterUnitDataPage extends StatefulWidget {
  final UnitEntity? unit;
  final CategoryPropertyEntity property;

  const MeterUnitDataPage({super.key, this.unit, required this.property});

  @override
  State<MeterUnitDataPage> createState() => _MeterUnitDataPageState();
}

class _MeterUnitDataPageState extends State<MeterUnitDataPage> {
  final _formKey = GlobalKey<FormState>();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final thicknessController = TextEditingController();

  MainCategoryEntity? category;
  bool _isDataChanged = false;

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    final state = context.read<UnitFormBloc>().state;
    category = state.category;
    lengthController.text = AppMoneyFormatter.formatDouble(state.initialLength);
    widthController.text = AppMoneyFormatter.formatDouble(state.initialWidth);
    thicknessController.text = AppMoneyFormatter.formatDouble(
      state.initialThickness,
    );
    if (widget.property.unitType.isSquareMeterWidthStatic) {
      lengthController.text = '1';
    }
  }

  @override
  void dispose() {
    lengthController.dispose();
    widthController.dispose();
    thicknessController.dispose();
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

    final length = double.tryParse(lengthController.text) ?? 0;
    final width = double.tryParse(widthController.text) ?? 0;
    final thickness = double.tryParse(thicknessController.text) ?? 1;

    final UnitEntity unit;
    final existingId = widget.unit?.id ?? 0;
    final propertyId = widget.unit?.propertyId ?? widget.property.id;

    switch (widget.property.unitType) {
      case UnitType.squareMeter:
      case UnitType.cubitMeter:
        unit = UnitEntity.cubitMeter(
          id: existingId,
          length: length,
          width: width,
          thickness: thickness,
          propertyId: propertyId,
        );
        break;
      case SquareMeterStaticUnitType():
        unit = UnitEntity.squareMeterStatic(
          id: existingId,
          length: length,
          width: width,
          propertyId: propertyId,
        );
        break;
      case UnitType.squareMeterWidthStatic:
        unit = UnitEntity.squareMeterWidthStatic(
          id: existingId,
          width: width,
          propertyId: propertyId,
        );
        break;
      default:
        unit = UnitEntity.cubitMeter(
          id: existingId,
          length: length,
          width: width,
          thickness: thickness,
          propertyId: propertyId,
        );
    }

    context.read<UnitFormBloc>().add(SaveUnitFormEvent(unit));
  }

  @override
  Widget build(BuildContext context) {
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
            content: SizedBox(
              width: 400.0,
              child: Padding(
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
                          Row(
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
                                    'ادخال ${widget.property.propertyName} ${category?.unitName ?? 'حبة'} بالمتر',
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
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: buildLengthWidget(
                                  'طول',
                                  lengthController,
                                  true,
                                  false,
                                  (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'يرجى إدخال الطول';
                                    }
                                    final parsed =
                                        double.tryParse(value) ?? 0.0;
                                    if (parsed <= 0) {
                                      return 'يجب أن يكون أكبر من صفر';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: buildLengthWidget(
                                  'عرض',
                                  widthController,
                                  widget
                                      .property
                                      .unitType
                                      .isSquareMeterWidthStatic,
                                  widget.property.unitType.hasSquareMeter,
                                  (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'يرجى إدخال العرض';
                                    }
                                    final parsed =
                                        double.tryParse(value) ?? 0.0;
                                    if (parsed <= 0) {
                                      return 'يجب أن يكون أكبر من صفر';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (widget.property.unitType.isCubitMeter)
                            const SizedBox(height: 10),
                          if (widget.property.unitType.isCubitMeter)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: buildLengthWidget(
                                    'سمك',
                                    thicknessController,
                                    false,
                                    true,
                                    (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'يرجى إدخال السمك';
                                      }
                                      final parsed =
                                          double.tryParse(value) ?? 0.0;
                                      if (parsed <= 0) {
                                        return 'يجب أن يكون أكبر من صفر';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(child: SizedBox(height: 40)),
                              ],
                            ),
                        ],
                      ),
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

  Widget buildLengthWidget(
    String title,
    TextEditingController controller,
    bool autoFocus,
    bool isDoneAction,
    String? Function(String?)? validator,
  ) {
    final colors = ColorScheme.of(context);
    return TextFormField(
      textInputAction: isDoneAction
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: (value) {
        if (isDoneAction) {
          _onSaveButtonClicked();
        } else {
          FocusScope.of(context).nextFocus();
        }
      },
      controller: controller,
      onChanged: (_) => _markChanged(),
      autofocus: autoFocus,
      textDirection: TextDirection.ltr,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      textAlignVertical: isDesktop
          ? TextAlignVertical.center
          : TextAlignVertical.bottom,
      style: Styles.labelMedium,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'\d+\.?\d*')),
      ],
      validator: validator,
      cursorHeight: 20.0,
      decoration: InputDecoration(
        hintText: 'ادخل ال$title',
        hintStyle: Styles.titleSmall.copyWith(color: colors.onSurfaceVariant),
        labelText: 'ال$title',
        labelStyle: Styles.titleMedium.copyWith(color: colors.primary),
        prefixIcon: fluent.Icon(
          fluent.FluentIcons.light_weight,
          color: colors.primary,
        ),
      ),
    );
  }
}
