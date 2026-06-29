import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_form/main_category_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_form/main_category_form_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_form/main_category_form_state.dart';
import 'package:flowcash/features/injection_container.dart';

import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class MainCategoryFormPage extends StatefulWidget {
  final MainCategoryEntity? category;
  const MainCategoryFormPage({super.key, this.category});

  @override
  State<MainCategoryFormPage> createState() => _MainCategoryFormPageState();
}

class _MainCategoryFormPageState extends State<MainCategoryFormPage> {
  final categoryNameController = TextEditingController();
  final unitNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final MainCategoryFormBloc _bloc;
  bool _initialized = false;
  bool _isDataChanged = false;

  UnitType unitSelected = UnitType.piece;
  CategoryDefineType categoryTypeSelected = CategoryDefineType.commodities;
  List<_PropertyModel> properties = [];

  bool get hasNotDescriptive {
    return properties.indexWhere(
              (pro) => pro.unitTypeSelected != UnitType.model,
            ) >
            -1 &&
        properties.length > 1;
  }

  List<UnitType> getPropertiesTypes(_PropertyModel currentProperty) {
    final measureUnitType = currentProperty.unitTypeSelected;
    final unitsTypes = UnitType.values
        .where((unitType) => unitType.isVisible)
        .toList();
    unitsTypes.removeWhere(
      (unitType) =>
          properties.indexWhere(
                (property) =>
                    property != currentProperty &&
                    property.unitTypeSelected == unitType,
              ) >
              -1 &&
          unitType.isMeasurable,
    );
    if (unitSelected.isLinearMeter) {
      unitsTypes.removeWhere(
        (unitType) =>
            unitType.isSquareMeter ||
            unitType.isSquareMeterStatic ||
            unitType.isCubitMeter,
      );
    }
    if (unitSelected.isSquareMeter) {
      unitsTypes.removeWhere(
        (unitType) =>
            (unitType.hasSquareMeter && !unitType.isSquareMeter) ||
            unitType.isCubitMeter,
      );
    }
    if (unitSelected.isCubitMeter) {
      unitsTypes.removeWhere(
        (unitType) => unitType.isLinearMeter || unitType.hasSquareMeter,
      );
    }
    if (properties.indexWhere(
              (property) =>
                  property != currentProperty &&
                  (property.unitTypeSelected?.isMeterMeasurable ?? false),
            ) >
            -1 &&
        !(measureUnitType?.isMeterMeasurable ?? false)) {
      unitsTypes.removeWhere((unitType) => unitType.isMeterMeasurable);
    }
    unitsTypes.removeWhere((unitType) => unitType == unitSelected);
    if (measureUnitType != null && !unitsTypes.contains(measureUnitType)) {
      unitsTypes.add(measureUnitType);
    }
    return unitsTypes;
  }

  @override
  void initState() {
    super.initState();
    _bloc = MainCategoryFormBloc(initUseCase: sl(), saveUseCase: sl());
    _bloc.add(InitMainCategoryFormEvent(
      id: widget.category?.id,
      category: widget.category,
    ));
    _initializeFromState(_bloc.state);
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    unitNameController.dispose();
    _bloc.close();
    for (var property in properties) {
      property.propertyName.dispose();
    }
    super.dispose();
  }

  void _markChanged() {
    if (_initialized && !_isDataChanged) {
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
    if (sure && mounted) {
      setState(() => _isDataChanged = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context);
      });
    }
  }

  void _initializeFromState(MainCategoryFormState state) {
    if (_initialized || state.status != MainCategoryFormStatus.ready) return;

    _initialized = true;
    categoryNameController.text = state.name;
    unitNameController.text = state.unitName;
    categoryTypeSelected = state.type;
    unitSelected = state.unitType;
    properties =
        state.properties.map((p) => _PropertyModel.fromEntity(p)).toList();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<MainCategoryFormBloc, MainCategoryFormState>(
        listener: (context, state) {
          if (state.status == MainCategoryFormStatus.ready) {
            _initializeFromState(state);
          }
          if (state.status == MainCategoryFormStatus.saved) {
            Navigator.of(context).pop(state.entity);
          }
          if (state.status == MainCategoryFormStatus.failure) {
            fluent.displayInfoBar(
              context,
              builder: (context, close) => fluent.InfoBar(
                title: const fluent.Text('تنبيه'),
                content: fluent.Text(
                  state.messageError ?? 'حدث خطأ في حفظ الصنف',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isEditing = widget.category?.id != null && widget.category?.id != 0;
          return PopScope(
            canPop: !_isDataChanged,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _onBackPressed();
            },
            child: fluent.ContentDialog(
              constraints: const BoxConstraints(maxWidth: 500),
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
                    isEditing ? 'تعديل صنف رئيسي' : 'إضافة صنف رئيسي جديد',
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                          spacing: Spacings.small,
                          children: [
                            Row(
                              spacing: Spacings.medium,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: fluent.InfoLabel(
                                    label: 'اسم الصنف',
                                    child: fluent.TextFormBox(
                                      textInputAction: TextInputAction.next,
                                      controller: categoryNameController,
                                      style: colors.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      enabled: state.status == .ready,
                                      autofocus: true,
                                      cursorHeight: 20.0,
                                      placeholder: 'ادخل اسم الصنف الرئيسي',
                                      prefix: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: const fluent.Icon(
                                          fluent.FluentIcons
                                              .category_classification,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        _markChanged();
                                        _bloc.add(
                                          MainCategoryNameChangedEvent(value),
                                        );
                                      },
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'اسم الصنف الرئيسي مطلوب';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: fluent.InfoLabel(
                                    label: 'اسم الوحدة',
                                    child: fluent.TextFormBox(
                                      textInputAction: TextInputAction.next,
                                      controller: unitNameController,
                                      style: colors.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      cursorHeight: 20.0,
                                      enabled: state.status == .ready,
                                      placeholder: 'ادخل اسم الوحدة',
                                      prefix: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: fluent.Icon(
                                          Icons.radio_button_unchecked,
                                          color: colors.primary,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        _markChanged();
                                        _bloc.add(UnitNameChangedEvent(value));
                                      },
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'اسم الوحدة مطلوب';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: Spacings.medium,
                              children: [
                                Expanded(
                                  child: fluent.InfoLabel(
                                    label: 'الوحدة',
                                    child: fluent.ComboboxFormField<UnitType>(
                                      value: unitSelected,
                                      placeholder:
                                          const fluent.Text('حدد وحدة الصنف'),
                                      isExpanded: true,
                                      validator: (value) {
                                        return null;
                                      },
                                      items: state.status != .ready ? [] : UnitType.values
                                          .where((type) => type.isBasic)
                                          .map((unit) {
                                            return fluent.ComboBoxItem<
                                              UnitType
                                            >(
                                              value: unit,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  fluent.Text(
                                                    unit.fullUnitName,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  fluent.Text(
                                                    unit.symbolUnit,
                                                    style: colors.body.copyWith(
                                                      color: colors
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          _markChanged();
                                          setState(() => unitSelected = value);
                                          _bloc.add(
                                            MainCategoryUnitTypeChangedEvent(
                                              value,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: fluent.InfoLabel(
                                    label: 'نوع الصنف',
                                    child: fluent.ComboboxFormField<
                                      CategoryDefineType
                                    >(
                                      value: categoryTypeSelected,
                                      placeholder:
                                          const fluent.Text('اختر نوع الصنف'),
                                      isExpanded: true,
                                      items: state.status != .ready ? [] :  CategoryDefineType.values.map((
                                        type,
                                      ) {
                                        return fluent.ComboBoxItem<
                                          CategoryDefineType
                                        >(
                                          value: type,
                                          child: fluent.Text(
                                            type.displayName(),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          _markChanged();
                                          setState(
                                            () => categoryTypeSelected = value,
                                          );
                                          _bloc.add(
                                            MainCategoryTypeChangedEvent(value),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Spacings.medium),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: colors.onSurfaceVariant,
                                  width: 1,
                                ),
                                borderRadius: Radiuses.smallAll,
                              ),
                              padding: Paddings.mediumAll,
                              child: Column(
                                spacing: Spacings.small,
                                children: [
                                  ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: categoryNameController,
                                    builder: (context, textValue, child) {
                                      return TextWidget(
                                        text: 'خصائص ${textValue.text}',
                                        alignment: Alignment.center,
                                        style: colors.subTitle,
                                      );
                                    },
                                  ),
                                  if (properties.isNotEmpty)
                                    const SizedBox(height: 10),
                                  if (properties.isNotEmpty)
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: properties.length,
                                      itemBuilder: (_, index) {
                                        if(properties[index].id > 0) return buildProperty(properties[index]);
                                        return _buildUnitModelDismissibleWidget(
                                          properties[index],
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(height: 10);
                                      },
                                    ),
                                  if (properties.isEmpty)
                                    const TextWidget(text: 'لا يوجد اي خصائص'),
                                  const SizedBox(height: Spacings.medium),
                                  fluent.FilledButton(
                                    onPressed: _onAddNewProperty,
                                    child: fluent.Text('اضافة خصائص جديدة'),
                                  ),
                                ],
                              ),
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
                  onPressed: state.status == MainCategoryFormStatus.saving
                      ? null
                      : _onSaveButtonClicked,
                  child: state.status == MainCategoryFormStatus.saving
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
      ),
    );
  }

  Widget buildProperty(_PropertyModel property) {
    final colors = AppStyle.of(context);
    final state = _bloc.state;
    return Container(
      padding: Paddings.mediumAll,
      decoration: BoxDecoration(
        borderRadius: Radiuses.smallAll,
        border: Border.all(
          width: 0.50,
          color: colors.outline.withValues(alpha: 0.80),
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        spacing: Spacings.medium,
        children: [
          Row(
            crossAxisAlignment: .start,
            spacing: Spacings.medium,
            children: [
              Expanded(
                child: fluent.InfoLabel(
                  label: 'اسم الخاصية',
                  child: fluent.TextFormBox(
                    enabled: state.status == .ready,
                    style: colors.body.copyWith(fontWeight: FontWeight.bold),
                    textInputAction: TextInputAction.next,
                    controller: property.propertyName,
                    cursorHeight: 20.0,
                    placeholder: 'ادخل اسم الخاصية',
                    prefix: const fluent.Icon(
                      fluent.FluentIcons.category_classification,
                    ),
                    onChanged: (_) => _markChanged(),
                  ),
                ),
              ),
              Expanded(
                child: fluent.InfoLabel(
                  label: 'نوع الوحدة',
                  child: fluent.ComboboxFormField<UnitType>(
                    value: property.unitTypeSelected,
                    placeholder: const fluent.Text('حدد نوع الوحدة'),
                    isExpanded: true,
                    items: state.status != .ready ? [] : getPropertiesTypes(property).map((unitType) {
                      return fluent.ComboBoxItem<UnitType>(
                        value: unitType,
                        child: fluent.Text(unitType.propertyData),
                      );
                    }).toList(),
                    onChanged: (unitType) {
                      if (unitType != null) {
                        property.isInventoryUnit = false;
                        setState(() => property.unitTypeSelected = unitType);
                        _markChanged();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: colors.surfaceContainerHigh,
            child: fluent.Checkbox(
              checked: property.isSingle,
              onChanged: state.status != .ready ? null : (value) {
                setState(() => property.isSingle = value ?? false);
                _markChanged();
              },
              content: ValueListenableBuilder<TextEditingValue>(
                valueListenable: property.propertyName,
                builder: (_, value, __) {
                  return TextWidget(
                    text:
                        '${value.text} واحد لكل ${categoryTypeSelected.displayName()}',
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitModelDismissibleWidget(_PropertyModel property) {
    final colors = AppStyle.of(context);
    return Dismissible(
      key: ObjectKey(property),
      background: Container(
        padding: Paddings.mediumAll,
        decoration: BoxDecoration(
          borderRadius: Radiuses.smallAll,
          color: colors.error,
          border: Border.all(width: 0.50),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            fluent.Icon(Icons.delete, color: colors.onError),
            const SizedBox(width: 5),
            TextWidget(
              text: 'ازالة',
              style: colors.bodyStrong.copyWith(color: colors.onError),
            ),
          ],
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: buildProperty(property),
      confirmDismiss: (dismiss) async {
        return await makeSure(
          context: context,
          title: 'إزالة الخاصية',
          content:
              'هل انت متأكد من إزالة الخاصية ${property.propertyName.text}',
        );
      },
      onDismissed: (_) {
        setState(() => properties.remove(property));
      },
    );
  }

  void _onAddNewProperty() {
    properties.add(_PropertyModel(id: 0));
    if (hasNotDescriptive) {
      properties.last.unitTypeSelected = UnitType.values.first;
    }
    setState(() {});
  }

  void _onSaveButtonClicked() {
    if (!_formKey.currentState!.validate()) return;

    for (var property in properties) {
      if (property.unitTypeSelected == null) {
        error(toast: 'لم يتم تحديد نوع الخاصية', context: context);
        return;
      }
      if (property.propertyName.text.replaceAll(' ', '').isEmpty) {
        error(toast: 'لم يتم تحديد اسم الخاصية', context: context);
        return;
      }
    }

    final categoryProperties = properties
        .map(_toCategoryPropertyEntity)
        .toList();

    // Add default category unit property if it doesn't exist
    if (!categoryProperties.any((p) => p.isCategoryUnit)) {
      categoryProperties.add(
        CategoryPropertyEntity(
          id: 0,
          mainCategoryId: _bloc.state.id,
          propertyName: 'الوحدة',
          unitType: unitSelected,
          isSingle: true,
          isCategoryUnit: true,
          isInventoryUnit: true,
          isPricingUnit: true,
        ),
      );
    }

    final category = MainCategoryEntity(
      id: _bloc.state.id,
      name: categoryNameController.text.trim(),
      type: categoryTypeSelected,
      unitName: unitNameController.text.trim(),
      unitType: unitSelected,
      properties: categoryProperties,
    );
    _bloc.add(SaveMainCategoryEvent(category));
  }

  CategoryPropertyEntity _toCategoryPropertyEntity(_PropertyModel property) {
    final isCatUnit = property.isCategoryUnit(unitSelected);
    return CategoryPropertyEntity(
      id: property.id,
      mainCategoryId: _bloc.state.id,
      propertyName: property.propertyName.text.isEmpty
          ? property.unitTypeSelected?.propertyName ?? ''
          : property.propertyName.text,
      unitType: property.unitTypeSelected ?? UnitType.piece,
      isSingle: isCatUnit ? true : property.isSingle,
      isCategoryUnit: isCatUnit,
      isInventoryUnit: property.isInventoryUnit,
      isPricingUnit: property.isPricingUnit,
    );
  }
}

class _PropertyModel {
  int id;
  final propertyName = TextEditingController();
  UnitType? unitTypeSelected;
  bool isSingle = false;
  bool isInventoryUnit = false;
  bool isPricingUnit = false;

  _PropertyModel({required this.id});

  factory _PropertyModel.fromEntity(CategoryPropertyEntity entity) {
    final property = _PropertyModel(id: entity.id);
    property.propertyName.text = entity.propertyName;
    property.unitTypeSelected = entity.unitType;
    property.isSingle = entity.isSingle;
    property.isInventoryUnit = entity.isInventoryUnit;
    property.isPricingUnit = entity.isPricingUnit;
    return property;
  }

  bool isCategoryUnit(UnitType unitType) {
    if (unitTypeSelected == null) return false;
    return unitTypeSelected! == unitType;
  }
}
